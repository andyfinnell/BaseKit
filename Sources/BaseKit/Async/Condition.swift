/// Signal is used in conjunction with Condition. Together they allow
/// one Task to wait on anther Task.
public final class Signal {
    private let stream: AsyncStream<Void>.Continuation
    
    /// Private init, don't call directly. Instead, use Conditiona.makeCondition()
    fileprivate init(stream: AsyncStream<Void>.Continuation) {
        self.stream = stream
    }
    
    /// Signal the waiter (who has the Condition) that they're good to go
    public func signal() {
        stream.finish()
    }
}

/// Condition allows two async Tasks to coordinate. Use `makeCondition()` to
/// create a Condition/Signal pair. The Task that wants to wait on something to
/// happen takes the Condition, the Task that notifies of the condition takes
/// the Signal.
public struct Condition {
    private let waiter: () async -> Void
    
    /// Private init; create a closure that will can be waited on
    fileprivate init(waiter: @escaping () async -> Void) {
        self.waiter = waiter
    }
    
    /// Wait on the condition to become true
    public func wait() async {
        await waiter()
    }
    
    /// Construct a Condition/Signal pair. The Task that wants to wait on something to
    /// happen takes the Condition, the Task that notifies of the condition takes
    /// the Signal.
    public static func makeCondition() -> (Condition, Signal) {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        let condition = Condition {
            for await _ in stream {}
        }
        let signal = Signal(stream: continuation)
        return (condition, signal)
    }
}

