import Foundation

public struct FilesystemPath: Hashable {
    let components: [String]
}

public extension FilesystemPath {
    static func sanitize(string: String) -> String {
        return string.replacingOccurrences(of: "/", with: "")
    }
    
    func appending(name: String) -> FilesystemPath {
        return FilesystemPath(components: components + [name])
    }
    
    func removingLastComponent() -> FilesystemPath {
        return FilesystemPath(components: Array(components.dropLast()))
    }
    
    func lastComponent() -> String? {
        return components.last
    }
}
