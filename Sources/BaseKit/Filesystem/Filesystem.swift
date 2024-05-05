import Foundation

public enum FilesystemError: Error {
    case badpath
    case invalidNode
}

// TODO: should be async/await friendly
public protocol Filesystem {
    func read(_ path: FilesystemPath) throws -> Data
    func write(_ data: Data, to path: FilesystemPath) throws
    func exists(_ path: FilesystemPath) -> Bool
    func delete(_ path: FilesystemPath) throws
}
