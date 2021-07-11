import Foundation

public class PersistentFilesystem {
    public init(rootURL: URL) throws {
        self.rootURL = rootURL
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    }
    
    private let rootURL: URL
    
    public static func temporary(_ path: String) -> Filesystem {
        let rootUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(path)
        return (try? PersistentFilesystem(rootURL: rootUrl))
            ?? MemoryFilesystem()
    }
}

extension PersistentFilesystem: Filesystem {
    public func read(_ path: FilesystemPath) throws -> Data {
        let url = resolve(path: path)
        return try Data(contentsOf: url)
    }
    
    public func write(_ data: Data, to path: FilesystemPath) throws {
        let url = resolve(path: path)
        let parentUrl = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parentUrl, withIntermediateDirectories: true)
        try data.write(to: url)
    }
    
    public func exists(_ path: FilesystemPath) -> Bool {
        let url = resolve(path: path)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public func delete(_ path: FilesystemPath) throws {
        guard path != FilesystemPath(components: []) else {
            try deleteRootFolder()
            return
        }
        let url = resolve(path: path)
        try FileManager.default.removeItem(at: url)
    }

}

private extension PersistentFilesystem {
    func resolve(path: FilesystemPath) -> URL {
        let safeComponents = path.components.filter { $0 != ".." && $0 != "." }
        return safeComponents.reduce(rootURL) { url, component -> URL in
            return url.appendingPathComponent(component)
        }
    }
    
    func deleteRootFolder() throws {
        let contents = try FileManager.default.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: [], options:[])
        for item in contents {
            try FileManager.default.removeItem(at: item)
        }
    }
}
