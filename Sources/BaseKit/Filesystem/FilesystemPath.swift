import Foundation

public struct FilesystemPath: Hashable {
    let components: [String]
    
    public init() {
        self.components = []
    }
    
    public init(_ components: [String]) {
        self.components = components
    }
    
    public init(_ components: String...) {
        self.components = components
    }
}

public extension FilesystemPath {
    static func sanitize(string: String) -> String {
        return string.replacingOccurrences(of: "/", with: "")
    }
    
    func appending(name: String) -> FilesystemPath {
        return FilesystemPath(components + [name])
    }
    
    func removingLastComponent() -> FilesystemPath {
        return FilesystemPath(Array(components.dropLast()))
    }
    
    func lastComponent() -> String? {
        return components.last
    }
}
