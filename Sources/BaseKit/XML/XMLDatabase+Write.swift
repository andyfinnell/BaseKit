import Foundation

public extension XMLDatabase {
    func text() throws -> String {
        try snapshot.text()
    }
    
    func data() throws -> Data {
        try snapshot.data()
    }
    
    func write(to fileURL: URL) async throws {
        try await snapshot.write(to: fileURL)
    }
}
