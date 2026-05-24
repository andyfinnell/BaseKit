import Foundation

public protocol CodableStorage<Value>: Sendable {
    associatedtype Value: Codable & Sendable
    
    func makeStream() async -> AsyncStream<Value>
    
    func store(_ value: Value) async throws
}

public final actor JSONStorage<Value: Codable & Sendable>: CodableStorage {
    /// Tri-state so we can distinguish "haven't read disk yet" from
    /// "read disk and got nothing" — both look like `Value?` of nil otherwise.
    private enum CacheState {
        case unloaded
        case loaded(Value?)
    }

    private let filename: String
    private let defaultValue: (() -> Value)?
    private var cache: CacheState = .unloaded
    private var listeners = [UUID: AsyncStream<Value>.Continuation]()

    public init(filename: String, defaultValue: @escaping () -> Value) {
        self.filename = filename
        self.defaultValue = defaultValue
    }

    public init(filename: String) {
        self.filename = filename
        self.defaultValue = nil
    }

    public func makeStream() async -> AsyncStream<Value> {
        let (stream, continuation) = AsyncStream<Value>.makeStream()
        // Resolve the initial value BEFORE registering the listener so we
        // never observe the order `[stored, initialLoad]` in the stream
        // buffer. If `store()` runs during the disk-read suspension, its
        // value is captured in the cache and returned by `load()` here.
        // Sync calls below (yield + registerListener) run without further
        // suspension on the actor, so no new `store()` can interleave.
        if let initialValue = await load() {
            continuation.yield(initialValue)
        }
        registerListener(continuation)
        return stream
    }

    public func store(_ value: Value) async throws {
        let encoder = JSONEncoder.standard
        let data = try encoder.encode(value)
        let url = try storageURL()
        try await data.asyncWrite(to: url)
        cache = .loaded(value)

        let listeners = self.listeners
        for listener in listeners.values {
            listener.yield(value)
        }
    }
}

private extension JSONStorage {
    func load() async -> Value? {
        if case let .loaded(value) = cache {
            return value
        }
        let value = await readFromDisk()
        cache = .loaded(value)
        return value
    }

    func readFromDisk() async -> Value? {
        do {
            let url = try storageURL()
            let data = try await Data(asyncContentsOf: url)
            let decoder = JSONDecoder.standard
            let storage = try decoder.decode(Value.self, from: data)
            return storage
        } catch {
            return defaultValue?()
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
