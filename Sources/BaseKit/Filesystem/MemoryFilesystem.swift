import Foundation

public class MemoryFilesystem {
    public init() {
    }
    
    private var rootFolder = FilesystemNode.folder(FilesystemFolder())
    private let section = CriticalSection()
}

extension MemoryFilesystem: Filesystem {
    public func read(_ path: FilesystemPath) throws -> Data {
        return try section.critical {
            let node = try resolve(path: path, createIfNecessary: false)
            guard case let .file(file) = node else {
                throw FilesystemError.badpath
            }
            return file.data
        }
    }
    
    public func write(_ data: Data, to path: FilesystemPath) throws {
        try section.critical {
            let node = try resolve(path: path, createIfNecessary: true)
            switch node {
            case let .file(file):
                file.data = data
            case .folder(_):
                throw FilesystemError.invalidNode
            }
        }
    }
    
    public func exists(_ path: FilesystemPath) -> Bool {
        return section.critical {
            do {
                _ = try resolve(path: path, createIfNecessary: false)
                return true
            } catch {
                return false
            }
        }
    }

    public func delete(_ path: FilesystemPath) throws {
        try section.critical {
            // Special case: root
            guard path != FilesystemPath([]) else {
                deleteRootFolder()
                return
            }
            let parentNode = try resolve(path: path.removingLastComponent(), createIfNecessary: false)
            switch parentNode {
            case .file(_):
                throw FilesystemError.invalidNode
            case let .folder(contents):
                guard let name = path.lastComponent() else {
                    throw FilesystemError.invalidNode
                }
                contents.remove(name: name)
            }
        }
    }
}

private extension MemoryFilesystem {
    func resolve(path: FilesystemPath, createIfNecessary: Bool) throws -> FilesystemNode {
        return try resolve(components: path.components, current: rootFolder, createIfNecessary: createIfNecessary)
    }
    
    func resolve(components: [String], current: FilesystemNode, createIfNecessary: Bool) throws -> FilesystemNode {
        // Check for success -- no components left to resolve
        guard let name = components.first else {
            return current
        }
        
        // We have to have a folder at this point
        guard case let .folder(folder) = current else {
            throw FilesystemError.invalidNode
        }
        
        // Simple case of the node being there
        let remaining = Array(components.suffix(from: 1))
        if let node = folder.contents[name] {
            return try resolve(components: remaining, current: node, createIfNecessary: createIfNecessary)
        }
        
        // See if we're allowed to create a node
        guard createIfNecessary else {
            throw FilesystemError.badpath
        }
        
        let isParent = components.count > 1
        if isParent {
            let newFolder = FilesystemNode.folder(FilesystemFolder())
            folder.add(node: newFolder, forName: name)
            return try resolve(components: remaining, current: newFolder, createIfNecessary: createIfNecessary)
        } else {
            let newFile = FilesystemNode.file(FilesystemFile())
            folder.add(node: newFile, forName: name)
            return newFile
        }
    }
    
    func deleteRootFolder() {
        guard case let .folder(folder) = rootFolder else {
            return
        }
        folder.removeAll()
    }
}
