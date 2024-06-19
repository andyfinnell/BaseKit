import Foundation
import os

public final class AsyncBroadcaster<Element: Sendable>: Sendable {
    private let listeners = OSAllocatedUnfairLock(initialState: [UUID: AsyncStream<Element>.Continuation]())
    
    public init() {}
        
    public func makeStream(initialValue: Element? = nil) -> AsyncStream<Element> {
        let (stream, continuation) = AsyncStream<Element>.makeStream()
        registerListener(continuation)
        if let initialValue {
            continuation.yield(initialValue)
        }
        return stream
    }
    
    public func updateValue(_ newValue: Element) {
        let listeners = self.listeners.withLock { $0 }
        for listener in listeners.values {
            listener.yield(newValue)
        }
    }
}

private extension AsyncBroadcaster {
    func registerListener(_ continuation: AsyncStream<Element>.Continuation) {
        let continuationID = UUID()
        listeners.withLock {
            $0[continuationID] = continuation
        }
        continuation.onTermination = { [weak self] _ in
            self?.removeListener(byID: continuationID)
        }
    }
    
    func removeListener(byID continuationID: UUID) {
        listeners.withLock {
            _ = $0.removeValue(forKey: continuationID)
        }
    }
}
