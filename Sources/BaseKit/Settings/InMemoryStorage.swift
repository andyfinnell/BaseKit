import Foundation

/// Test-only `CodableStorage` that holds its value in memory and broadcasts
/// changes to all live `makeStream()` subscribers — no filesystem access.
///
/// Note: this lives in the BaseKit main target rather than a test target
/// because it is consumed from multiple test modules (BaseKitTests and
/// downstream packages' tests). Production code must not use it.
public final actor InMemoryStorage<Value: Codable & Sendable>: CodableStorage {
    private var value: Value?
    private var listeners: [UUID: AsyncStream<Value>.Continuation] = [:]

    public init(initial: Value? = nil) {
        self.value = initial
    }

    public func makeStream() async -> AsyncStream<Value> {
        let (stream, continuation) = AsyncStream<Value>.makeStream()
        let id = UUID()
        listeners[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { [weak self] in await self?.removeListener(id) }
        }
        if let value {
            continuation.yield(value)
        }
        return stream
    }

    public func store(_ value: Value) async throws {
        self.value = value
        for continuation in listeners.values {
            continuation.yield(value)
        }
    }

    private func removeListener(_ id: UUID) {
        listeners.removeValue(forKey: id)
    }
}
