import Foundation

public extension XMLDatabase {
    convenience init(contentsOf fileURL: URL) async throws {
        let snapshot = try await XMLSnapshot(contentsOf: fileURL)
        self.init(snapshot: snapshot)
    }
    
    convenience init(text: String) throws {
        let snapshot = try XMLSnapshot(text: text)
        self.init(snapshot: snapshot)
    }
    
    convenience init(data: Data) throws {
        let snapshot = try XMLSnapshot(data: data)
        self.init(snapshot: snapshot)
    }
    
    convenience init(snapshot: XMLSnapshot) {
        self.init(roots: snapshot.roots, values: snapshot.values)
    }
}
