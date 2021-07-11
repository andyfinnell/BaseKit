import Foundation

// Designed for mutation, not immutable

enum FilesystemNode: Equatable {
    case file(FilesystemFile)
    case folder(FilesystemFolder)
}

final class FilesystemFile {
    var data: Data
    
    init(data: Data = Data()) {
        self.data = data
    }
}

extension FilesystemFile: Equatable {
    static func == (lhs: FilesystemFile, rhs: FilesystemFile) -> Bool {
        return lhs.data == rhs.data
    }
}

final class FilesystemFolder {
    private(set) var contents = [String: FilesystemNode]()
    
    func add(node: FilesystemNode, forName name: String) {
        contents[name] = node
    }
    
    func remove(name: String) {
        contents.removeValue(forKey: name)
    }
    
    func removeAll() {
        contents.removeAll()
    }
}

extension FilesystemFolder: Equatable {
    static func == (lhs: FilesystemFolder, rhs: FilesystemFolder) -> Bool {
        return lhs.contents == rhs.contents
    }
}
