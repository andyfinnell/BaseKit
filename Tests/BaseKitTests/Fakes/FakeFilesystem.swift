import Foundation
import BaseKit
import TestKit

final class FakeFilesystem: Filesystem {
    lazy var read_fake = FakeMethodCall(FilesystemPath.self, Result<Data, Error>.success(Data()))
    func read(_ path: FilesystemPath) throws -> Data {
        try read_fake.fakeThrows(path)
    }
    
    lazy var write_fake = FakeMethodCall((data: Data, path: FilesystemPath).self, Result<Void, Error>.success(()))
    func write(_ data: Data, to path: FilesystemPath) throws {
        try write_fake.fakeThrows((data, path))
    }
    
    lazy var exists_fake = FakeMethodCall(FilesystemPath.self, false)
    func exists(_ path: FilesystemPath) -> Bool {
        exists_fake.fake(path)
    }
    
    lazy var delete_fake = FakeMethodCall(FilesystemPath.self, Result<Void, Error>.success(()))
    func delete(_ path: FilesystemPath) throws {
        try delete_fake.fakeThrows(path)
    }
}
