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

/// Outcome of an `aio_read`/`aio_write` submission attempt. EAGAIN at submission
/// time means the kernel's AIO queue is full; we don't fail — we leave the
/// operation enqueued in `AsyncIOQueue` so it'll be retried on the next tick.
private enum AsyncIOSubmitOutcome: Sendable {
    case submitted
    case needsRetry
    case failed(Int32)
}

private final class ReadOperation: AsyncIOOperation {
    private struct OperationResult {
        var rawPointer: UnsafeMutableRawPointer?
        var controlBlockPointer: UnsafeMutablePointer<aiocb>?
        /// `true` once `aio_read` has accepted the request. Resets to `false` if
        /// completion or submission later reports EAGAIN, so the polling loop will
        /// retry.
        var isSubmitted: Bool = false
    }

    private enum TickOutcome: Sendable {
        case keepWaiting
        case terminalError(Int32)
        case readSucceeded(Data)
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
        let outcome = mutableBits.withLock { [fileDescriptor, offset, byteCount] mutableBits -> AsyncIOSubmitOutcome in
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
            return Self.attemptSubmit(controlBlockPointer, mutableBits: &mutableBits)
        }

        switch outcome {
        case .submitted, .needsRetry:
            AsyncIOQueue.shared.addOperation(self)
        case .failed(let err):
            throw AsyncRandomAccessFileError.readError(err)
        }
    }

    func checkIfComplete() -> Bool {
        let outcome = mutableBits.withLock { mutableBits -> TickOutcome in
            guard let controlBlockPointer = mutableBits.controlBlockPointer else {
                return .terminalError(0)
            }

            // Pending submission (initial submit got EAGAIN, or completion saw
            // EAGAIN and reset us): try `aio_read` again.
            if !mutableBits.isSubmitted {
                switch Self.attemptSubmit(controlBlockPointer, mutableBits: &mutableBits) {
                case .submitted, .needsRetry:
                    return .keepWaiting
                case .failed(let err):
                    return .terminalError(err)
                }
            }

            // Submitted: check completion status.
            let aioErr = aio_error(controlBlockPointer)
            if aioErr == EINPROGRESS {
                return .keepWaiting
            }
            if aioErr == EAGAIN {
                mutableBits.isSubmitted = false
                return .keepWaiting
            }
            if aioErr == -1 {
                let err = errno
                if err == EAGAIN {
                    mutableBits.isSubmitted = false
                    return .keepWaiting
                }
                return .terminalError(err)
            }
            if aioErr != 0 {
                return .terminalError(aioErr)
            }

            // aio_error == 0: operation completed; pull the return value.
            let returnValue = aio_return(controlBlockPointer)
            if returnValue == -1 {
                let err = errno
                if err == EAGAIN {
                    mutableBits.isSubmitted = false
                    return .keepWaiting
                }
                return .terminalError(err)
            }

            guard let rawPointer = mutableBits.rawPointer else {
                return .terminalError(0)
            }
            mutableBits.rawPointer = nil
            let readData = Data(
                bytesNoCopy: rawPointer, count: returnValue,
                deallocator: .custom({ ptr, _ in ptr.deallocate() }))
            return .readSucceeded(readData)
        }

        switch outcome {
        case .keepWaiting:
            return false
        case .terminalError(let err):
            completion(.failure(AsyncRandomAccessFileError.readError(err)))
            return true
        case .readSucceeded(let data):
            completion(.success(data))
            return true
        }
    }

    private static func attemptSubmit(
        _ controlBlockPointer: UnsafeMutablePointer<aiocb>,
        mutableBits: inout OperationResult
    ) -> AsyncIOSubmitOutcome {
        let result = aio_read(controlBlockPointer)
        if result == 0 {
            mutableBits.isSubmitted = true
            return .submitted
        }
        let err = errno
        if err == EAGAIN {
            return .needsRetry
        }
        return .failed(err)
    }
}

private final class WriteOperation: AsyncIOOperation {
    private struct OperationResult {
        var dataToWrite: Data
        var controlBlockPointer: UnsafeMutablePointer<aiocb>?
        var externalDataToWrite: UnsafeMutableRawBufferPointer?
        /// `true` once `aio_write` has accepted the request. See `ReadOperation`.
        var isSubmitted: Bool = false
    }

    private enum TickOutcome: Sendable {
        case keepWaiting
        case terminalError(Int32)
        case writeSucceeded(byteCount: Int)
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
        let outcome = mutableBits.withLock { [fileDescriptor, offset] mutableBits -> AsyncIOSubmitOutcome in
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
            return Self.attemptSubmit(controlBlockPointer, mutableBits: &mutableBits)
        }

        switch outcome {
        case .submitted, .needsRetry:
            AsyncIOQueue.shared.addOperation(self)
        case .failed(let err):
            throw AsyncRandomAccessFileError.writeError(err)
        }
    }

    func checkIfComplete() -> Bool {
        let outcome = mutableBits.withLock { mutableBits -> TickOutcome in
            guard let controlBlockPointer = mutableBits.controlBlockPointer else {
                return .terminalError(0)
            }

            if !mutableBits.isSubmitted {
                switch Self.attemptSubmit(controlBlockPointer, mutableBits: &mutableBits) {
                case .submitted, .needsRetry:
                    return .keepWaiting
                case .failed(let err):
                    return .terminalError(err)
                }
            }

            let aioErr = aio_error(controlBlockPointer)
            if aioErr == EINPROGRESS {
                return .keepWaiting
            }
            if aioErr == EAGAIN {
                mutableBits.isSubmitted = false
                return .keepWaiting
            }
            if aioErr == -1 {
                let err = errno
                if err == EAGAIN {
                    mutableBits.isSubmitted = false
                    return .keepWaiting
                }
                return .terminalError(err)
            }
            if aioErr != 0 {
                return .terminalError(aioErr)
            }

            let returnValue = aio_return(controlBlockPointer)
            if returnValue == -1 {
                let err = errno
                if err == EAGAIN {
                    mutableBits.isSubmitted = false
                    return .keepWaiting
                }
                return .terminalError(err)
            }
            return .writeSucceeded(byteCount: returnValue)
        }

        switch outcome {
        case .keepWaiting:
            return false
        case .terminalError(let err):
            completion(.failure(AsyncRandomAccessFileError.writeError(err)))
            return true
        case .writeSucceeded(let bytesWritten):
            completion(.success(bytesWritten))
            return true
        }
    }

    private static func attemptSubmit(
        _ controlBlockPointer: UnsafeMutablePointer<aiocb>,
        mutableBits: inout OperationResult
    ) -> AsyncIOSubmitOutcome {
        let result = aio_write(controlBlockPointer)
        if result == 0 {
            mutableBits.isSubmitted = true
            return .submitted
        }
        let err = errno
        if err == EAGAIN {
            return .needsRetry
        }
        return .failed(err)
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
