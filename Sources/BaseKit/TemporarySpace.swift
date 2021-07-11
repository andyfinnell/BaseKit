import Foundation

public protocol TemporarySpaceFakable {
    func store(_ data: Data) throws -> ContentId
    func fetch(_ temporaryData: ContentId) throws -> Data
}

public final class TemporarySpace: TemporarySpaceFakable {
    private let filesystem: Filesystem
    
    public init(filesystem: Filesystem = PersistentFilesystem.temporary("com.losingfight.basekit.temp-space")) {
        self.filesystem = filesystem
    }
    
    public func store(_ data: Data) throws -> ContentId {
        let contentId = data.contentId()
        let path = FilesystemPath(components: [contentId.value])
        
        if !filesystem.exists(path) {
            try filesystem.write(data, to: path)
        }
        
        return contentId
    }
    
    public func fetch(_ contentId: ContentId) throws -> Data {
        let path = FilesystemPath(components: [contentId.value])
        return try filesystem.read(path)
    }
}
