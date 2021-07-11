import Foundation

public enum FilesystemError: Error {
    case badpath
    case invalidNode
}

public protocol Filesystem {
    func read(_ path: FilesystemPath) throws -> Data
    func write(_ data: Data, to path: FilesystemPath) throws
    func exists(_ path: FilesystemPath) -> Bool
    func delete(_ path: FilesystemPath) throws
}
