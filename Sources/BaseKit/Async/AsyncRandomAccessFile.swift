import Foundation
import os

public enum AsyncRandomAccessFileError: Error, Equatable {
    /// An occurred during the open
    case openError(Int32)
    /// An error occurred during a read
    case readError(Int32)
    /// An error occurred during a write
    case writeError(Int32)
    /// AsyncFileStream only works on files, and that wasn't a file
    case notFileURL
}

public struct AsyncRandomAccessFile: ~Copyable, Sendable {
    private let fileDescriptor: Int32
    private var isClosed = false
    
    // TODO: make mode more user friendly
    
    public init(url: URL, mode: Int32 = O_RDWR | O_CREAT) throws {
        guard url.isFileURL else {
            throw AsyncRandomAccessFileError.notFileURL
        }
        let fileDescriptor = open(url.absoluteURL.path, mode | O_NONBLOCK, 0o666)
        // Once we start setting properties, we can't throw. So check to see if
        //  we need to throw now, then set properties
        if fileDescriptor == -1 {
            throw AsyncRandomAccessFileError.openError(errno)
        }
        self.fileDescriptor = fileDescriptor
    }
    
    public func read(_ byteCount: Int, at offset: off_t) async throws -> Data {
        try await withCheckedThrowingContinuation { [fileDescriptor] continuation in
            let operation = ReadOperation(
                fileDescriptor: fileDescriptor,
                byteCount: byteCount,
                offset: offset) { result in
                    continuation.resume(with: result)
                }
            do {
                try operation.read()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    @discardableResult
    public func write(_ data: Data, at offset: off_t) async throws -> Int {
        try await withCheckedThrowingContinuation { [fileDescriptor] continuation in
            let operation = WriteOperation(
                fileDescriptor: fileDescriptor,
                dataToWrite: data,
                offset: offset) { result in
                    continuation.resume(with: result)
                }
            do {
                try operation.write()
            } catch {
                continuation.resume(throwing: error)
            }
        }

    }

    public func size() throws -> Int64 {
        var stats = stat()
        let error = fstat(fileDescriptor, &stats)
        if error == -1 {
            throw AsyncRandomAccessFileError.readError(errno)
        }
        return stats.st_size
    }

    deinit {
        // Ensure we've closed the file if we're going out of scope
        if !isClosed {
            Darwin.close(fileDescriptor)
        }
    }

    public consuming func close() {
        isClosed = true
        Darwin.close(fileDescriptor)
    }
}

private protocol AsyncIOOperation: Sendable, AnyObject {
    func checkIfComplete() -> Bool
}

private final class ReadOperation: AsyncIOOperation {
    private struct OperationResult {
        var rawPointer: UnsafeMutableRawPointer?
        var controlBlockPointer: UnsafeMutablePointer<aiocb>?
    }
    private let fileDescriptor: Int32
    private let byteCount: Int
    private let offset: off_t
    private let completion: @Sendable (Result<Data, AsyncRandomAccessFileError>) -> Void
    private let mutableBits = OSAllocatedUnfairLock(uncheckedState: OperationResult())
    
    init(fileDescriptor: Int32, byteCount: Int, offset: off_t, completion: @escaping @Sendable (Result<Data, AsyncRandomAccessFileError>) -> Void) {
        self.fileDescriptor = fileDescriptor
        self.byteCount = byteCount
        self.offset = offset
        self.completion = completion
    }
    
    deinit {
        mutableBits.withLock {
            // If we made it this far with rawPointer still around, we still own it and should dealloc
            $0.rawPointer?.deallocate()
            $0.rawPointer = nil
            // We always own the control block pointer
            $0.controlBlockPointer?.deallocate()
            $0.controlBlockPointer = nil
        }
    }
    
    func read() throws {
        let error = mutableBits.withLock { [fileDescriptor, offset, byteCount] mutableBits in
            let rawPointer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 1)
            mutableBits.rawPointer = rawPointer
            let controlBlockPointer = UnsafeMutablePointer<aiocb>.allocate(capacity: 1)
            controlBlockPointer.pointee = aiocb(
                aio_fildes: fileDescriptor,
                aio_offset: offset,
                aio_buf: rawPointer,
                aio_nbytes: byteCount,
                aio_reqprio: 0,
                aio_sigevent: sigevent(
                    sigev_notify: SIGEV_NONE,
                    sigev_signo: 0,
                    sigev_value: sigval(),
                    sigev_notify_function: nil,
                    sigev_notify_attributes: nil
                ),
                aio_lio_opcode: 0
            )
            mutableBits.controlBlockPointer = controlBlockPointer
            
            return aio_read(controlBlockPointer)
        }
        
        if error == -1 {
            throw AsyncRandomAccessFileError.readError(errno)
        }
        
        AsyncIOQueue.shared.addOperation(self)
    }
    
    func checkIfComplete() -> Bool {
        guard isComplete() else {
            return false
        }
        readCompleted()
        return true
    }

    private func isComplete() -> Bool {
        mutableBits.withLock { mutableBits -> Bool in
            guard let controlBlockPointer = mutableBits.controlBlockPointer else {
                return false
            }
            
            let err = aio_error(controlBlockPointer)
            return err == 0
        }
    }
    
    private func readCompleted() {
        let (error, data) = mutableBits.withLock { mutableBits -> (Int32, Data?) in
            guard let controlBlockPointer = mutableBits.controlBlockPointer else {
                return (0, nil)
            }
                        
            let err = aio_error(controlBlockPointer)
            if err == -1 {
                return (errno, nil)
            } else if err != 0 {
                return (err, nil)
            }
            
            let returnValue = aio_return(controlBlockPointer)
            if returnValue == -1 {
                return (errno, nil)
            }
            let bytesRead = returnValue
            
            // At this point we want to transfer ownership of the data
            guard let rawPointer = mutableBits.rawPointer else {
                return (0, nil)
            }
            mutableBits.rawPointer = nil
            let readData = Data(bytesNoCopy: rawPointer, count: bytesRead, deallocator: .custom({ ptr, _ in
                ptr.deallocate()
            }))
            return (0, readData)
        }
        
        if let data {
            completion(.success(data))
        } else {
            completion(.failure(AsyncRandomAccessFileError.readError(error)))
        }
    }
}

private final class WriteOperation: AsyncIOOperation {
    private struct OperationResult {
        var dataToWrite: Data
        var controlBlockPointer: UnsafeMutablePointer<aiocb>?
        var externalDataToWrite: UnsafeMutableRawBufferPointer?
    }

    private let fileDescriptor: Int32
    private let offset: off_t
    private let completion: @Sendable (Result<Int, AsyncRandomAccessFileError>) -> Void
    private let mutableBits: OSAllocatedUnfairLock<OperationResult>
    
    init(fileDescriptor: Int32, dataToWrite: Data, offset: off_t, completion: @escaping @Sendable (Result<Int, AsyncRandomAccessFileError>) -> Void) {
        self.fileDescriptor = fileDescriptor
        self.offset = offset
        self.completion = completion
        self.mutableBits = OSAllocatedUnfairLock(uncheckedState: OperationResult(dataToWrite: dataToWrite))
    }
        
    deinit {
        mutableBits.withLock {
            // We always own the control block pointer
            $0.controlBlockPointer?.deallocate()
            $0.controlBlockPointer = nil
            // If we allocated this, delete it
            $0.externalDataToWrite?.deallocate()
            $0.externalDataToWrite = nil
        }
    }

    func write() throws {
        let error = mutableBits.withLock { [fileDescriptor, offset] mutableBits in
            let byteCount = mutableBits.dataToWrite.count
            let controlBlockPointer = UnsafeMutablePointer<aiocb>.allocate(capacity: 1)
            controlBlockPointer.pointee = mutableBits.dataToWrite.withUnsafeMutableBytes { (rawBufferPointer: UnsafeMutableRawBufferPointer) in
                let unsafeMutablePointer: UnsafeMutableRawBufferPointer
                if byteCount > 16 {
                    // This is probably not inline data, so use it as is. YOLO
                    unsafeMutablePointer = rawBufferPointer
                } else {
                    // This is probably inline data, so make a copy
                    unsafeMutablePointer = UnsafeMutableRawBufferPointer.allocate(byteCount: byteCount, alignment: 16)
                    unsafeMutablePointer.copyBytes(from: rawBufferPointer)
                    mutableBits.externalDataToWrite = unsafeMutablePointer
                }
                return aiocb(
                    aio_fildes: fileDescriptor,
                    aio_offset: offset,
                    aio_buf: unsafeMutablePointer.baseAddress,
                    aio_nbytes: byteCount,
                    aio_reqprio: 0,
                    aio_sigevent: sigevent(
                        sigev_notify: SIGEV_NONE,
                        sigev_signo: 0,
                        sigev_value: sigval(),
                        sigev_notify_function: nil,
                        sigev_notify_attributes: nil
                    ),
                    aio_lio_opcode: 0
                )
            }
            mutableBits.controlBlockPointer = controlBlockPointer
            return aio_write(controlBlockPointer)
        }
        
        if error == -1 {
            throw AsyncRandomAccessFileError.writeError(errno)
        }
        
        AsyncIOQueue.shared.addOperation(self)
    }
    
    func checkIfComplete() -> Bool {
        guard isComplete() else {
            return false
        }
        writeCompleted()
        return true
    }

    private func isComplete() -> Bool {
        mutableBits.withLock { mutableBits -> Bool in
            guard let controlBlockPointer = mutableBits.controlBlockPointer else {
                return false
            }
            
            let err = aio_error(controlBlockPointer)
            return err == 0
        }
    }
    
    private func writeCompleted() {
        let (error, bytesWritten) = mutableBits.withLock { mutableBits -> (Int32, Int) in
            guard let controlBlockPointer = mutableBits.controlBlockPointer else {
                return (0, 0)
            }
                        
            let err = aio_error(controlBlockPointer)
            if err == -1 {
                return (errno, 0)
            } else if err != 0 {
                return (err, 0)
            }
            
            let returnValue = aio_return(controlBlockPointer)
            if returnValue == -1 {
                return (errno, 0)
            }
            let bytesWritten = returnValue
            return (0, bytesWritten)
        }
        
        if error == 0 {
            completion(.success(bytesWritten))
        } else {
            completion(.failure(AsyncRandomAccessFileError.readError(error)))
        }
    }
}

private final class AsyncIOQueue: Sendable {
    private struct MemberData {
        var operations = [any AsyncIOOperation]()
    }
    private let memberData = OSAllocatedUnfairLock(initialState: MemberData())
    
    static let shared = AsyncIOQueue()
    
    init() {
        let delayInMilliseconds: UInt64 = 16
        Task { [weak self] in
            repeat {
                try await Task.sleep(nanoseconds: delayInMilliseconds * 1_000_000)
                self?.checkOperations()
            } while true
        }
    }
    
    func addOperation(_ operation: some AsyncIOOperation) {
        memberData.withLock {
            $0.operations.append(operation)
        }
    }
    
    private func checkOperations() {
        let operations = memberData.withLock { $0.operations }
        guard !operations.isEmpty else {
            return
        }
        
        var operationsToRemove = [any AsyncIOOperation]()
        for operation in operations {
            let isComplete = operation.checkIfComplete()
            if isComplete {
                operationsToRemove.append(operation)
            }
        }
        
        memberData.withLock { [operationsToRemove] in
            $0.operations.removeAll(where: { candidate in
                operationsToRemove.contains(where: { candidate === $0 })
            })
        }
    }
}
