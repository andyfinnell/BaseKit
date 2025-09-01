import Foundation

public extension Data {
    /// Asynchronously read from the contents of the fileURL. This method
    /// will throw an error if it's not a file URL.
    init(asyncContentsOf url: URL) async throws {
        var stream = try url.openForReading()
        self = try await stream.readToEnd()
    }
    
    /// Asynchronously write the contents of self into the fileURL.
    func asyncWrite(to url: URL) async throws {
        var stream = try url.openForWriting()
        try await stream.write(self)
    }
}

/// A phantom type used by AsyncFileStream to restrict methods to read mode
public enum ReadMode {}
/// A phantom type used by AsyncFileStream to restrict methods to write mode
public enum WriteMode {}

/// Errors thrown by AsyncFileStream. Mostly wrap POSIX errors
public enum AsyncFileStreamError: Error, Equatable {
    /// An occurred during the open
    case openError(Int32)
    /// An error occurred during a read
    case readError(Int32)
    /// An error occurred during a write
    case writeError(Int32)
    /// AsyncFileStream only works on files, and that wasn't a file
    case notFileURL
}

public extension URL {
    /// Create an instance from the URL for reading only
    func openForReading() throws -> AsyncFileStream<ReadMode> {
        try AsyncFileStream<ReadMode>(url: self, mode: O_RDONLY)
    }
    
    /// Create an instance from the URL for writing. It will overwrite if the file
    /// already exists or create it if it does not exist.
    func openForWriting() throws -> AsyncFileStream<WriteMode> {
        try AsyncFileStream<WriteMode>(url: self, mode: O_WRONLY | O_TRUNC | O_CREAT)
    }
}

/// Allow async reading or writing to a file.
public struct AsyncFileStream<Mode>: ~Copyable, Sendable {
    private let file: AsyncRandomAccessFile
    private var offset: off_t = 0
        
    /// `url` has to be a file url, or this will throw
    /// `mode` is passed into the POSIX function `open()`
    fileprivate init(url: URL, mode: Int32) throws {
        file = try AsyncRandomAccessFile(url: url, mode: mode)
    }
             
    /// Close the file. Consuming method
    public consuming func close() {
        file.close()
    }
}

/// Methods available in read mode
public extension AsyncFileStream where Mode == ReadMode {
    /// Read the entire contents of the file in one go
    mutating func readToEnd() async throws -> Data {
        try await readData(upToCount: .max)
    }
    
    mutating func readData(upToCount length: Int) async throws -> Data {
        let dataRead = try await file.read(length, at: offset)
        offset += off_t(dataRead.count)
        return dataRead
    }
}

/// Methods available in write mode
public extension AsyncFileStream where Mode == WriteMode {
    /// Write the data out to file async
    mutating func write(_ data: Data) async throws {
        let bytesWritten = try await file.write(data, at: offset)
        offset += off_t(bytesWritten)        
    }
}
