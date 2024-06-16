/// This class allows you to bottleneck how many blocks can run concurrently.
/// It's useful when you don't want to overwhelm a system or resource, such
/// as the network or CPU.
public final class ConcurrencyLimiter: Sendable {
    private let counter: Counter
    
    /// Concurrency is the maximum number of blocks that can be run
    public init(concurrency: Int) {
        counter = Counter(concurrency: concurrency)
    }
    
    /// Execute the given block on the calling Task. It may wait first if there
    /// are already the maxium blocks running.
    public func run<Value>(_ block: @escaping () async throws -> Value) async throws -> Value {
        let condition = await counter.enterLimiting()
        await condition.wait()
        
        do {
            let value = try await block()
            await counter.exitLimiting()
            return value
        } catch {
            await counter.exitLimiting()
            throw error
        }
    }
    
    /// Execute the given block on the calling Task. It may wait first if there
    /// are already the maxium blocks running.
    public func run<Value>(_ block: @escaping () async -> Value) async -> Value {
        let condition = await counter.enterLimiting()
        await condition.wait()
        
        let value = await block()
        await counter.exitLimiting()
        return value
    }
}

private extension ConcurrencyLimiter {
    /// Counter does all the limiting in an async-safe way. It effectively uses
    /// a FIFO priority.
    final actor Counter {
        /// The maximum amount of currency allowed
        private let concurrency: Int
        /// How many blocks are currently in flight
        private var inflightCount = 0
        /// Pending (blocked) blocks in a FIFO queue.
        private var pending = [Signal]()
        
        init(concurrency: Int) {
            self.concurrency = concurrency
        }
        
        deinit {
            // Don't leave anyone hanging. Make a copy to avoid any re-entrancy
            // This is just insurance, don't expected this is the happy path.
            let localPending = pending
            pending.removeAll()
            for local in localPending {
                local.signal()
            }
        }
        
        /// Should be called before a block begins executing to do bookkeeping
        /// and to return a Condition the caller should wait on.
        func enterLimiting() -> Condition {
            let shouldWait = inflightCount >= concurrency
            
            let (condition, signal) = Condition.makeCondition()
            if shouldWait {
                pending.append(signal)
            } else {
                // immediately signal and let it run
                inflightCount += 1 // only count when they start going
                signal.signal()
            }
            
            // Don't wait now because we're in the actor. Let the caller do it
            //  in their context.
            return condition
        }
        
        /// Must be called when the block finishes executing so the next block
        /// can be allowed to run.
        func exitLimiting() {
            inflightCount -= 1
            let shouldUnblock = inflightCount < concurrency
            
            guard shouldUnblock, let firstPending = pending.first else {
                return
            }
            pending.removeFirst()
            inflightCount += 1 // only count when they start going
            firstPending.signal()
        }
    }
}
