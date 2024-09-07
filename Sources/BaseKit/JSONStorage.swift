import Foundation

public protocol CodableStorage<Value>: Sendable {
    associatedtype Value: Codable
    
    func makeStream() async -> AsyncStream<Value>
    
    func store(_ value: Value) async throws
}

public final actor JSONStorage<Value: Codable>: CodableStorage {
    private let filename: String
    private let defaultValue: () -> Value
    private var listeners = [UUID: AsyncStream<Value>.Continuation]()
    
    public init(filename: String, defaultValue: @escaping () -> Value) {
        self.filename = filename
        self.defaultValue = defaultValue
    }
    
    public func makeStream() async -> AsyncStream<Value> {
        let (stream, continuation) = AsyncStream<Value>.makeStream()
        registerListener(continuation)
        let initialValue = await load()
        continuation.yield(initialValue)
        return stream
    }
    
    public func store(_ value: Value) async throws {
        let encoder = JSONEncoder.standard
        let data = try encoder.encode(value)
        let url = try storageURL()
        try await data.asyncWrite(to: url)
        
        let listeners = self.listeners
        for listener in listeners.values {
            listener.yield(value)
        }
    }
}

private extension JSONStorage {
    func load() async -> Value {
        do {
            let url = try storageURL()
            let data = try await Data(asyncContentsOf: url)
            let decoder = JSONDecoder.standard
            let storage = try decoder.decode(Value.self, from: data)
            return storage
        } catch {
            return defaultValue()
        }
    }
    
    func storageURL() throws -> URL {
        let appSupportFolder = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return appSupportFolder.appendingPathComponent("\(filename).json")
    }
    
    func registerListener(_ continuation: AsyncStream<Value>.Continuation) {
        let continuationID = UUID()
        listeners[continuationID] = continuation
        
        continuation.onTermination = { _ in
            Task { [weak self] in
                await self?.removeListener(byID: continuationID)
            }
        }
    }
    
    func removeListener(byID continuationID: UUID) {
        listeners.removeValue(forKey: continuationID)
    }
}
