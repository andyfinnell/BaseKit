import Foundation

public extension XMLDatabase {
    convenience init(contentsOf fileURL: URL, undoManager: UndoManager?) async throws {
        let snapshot = try await XMLSnapshot(contentsOf: fileURL)
        self.init(snapshot: snapshot, undoManager: undoManager)
    }
    
    convenience init(text: String, undoManager: UndoManager?) throws {
        let snapshot = try XMLSnapshot(text: text)
        self.init(snapshot: snapshot, undoManager: undoManager)
    }
    
    convenience init(data: Data, undoManager: UndoManager?) throws {
        let snapshot = try XMLSnapshot(data: data)
        self.init(snapshot: snapshot, undoManager: undoManager)
    }
    
    convenience init(snapshot: XMLSnapshot, undoManager: UndoManager?) {
        self.init(roots: snapshot.roots, values: snapshot.values, undoManager: undoManager)
    }
}
