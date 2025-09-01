import Foundation

public struct WorkQueue {
    private var nextID: UInt64 = 0
    private var queue = [UInt64]()
    private var currentTask: Task<Void, Error>?
    
    public init() {
        
    }
    
    public mutating func schedule<R: Sendable>(_ work: () async throws -> R) async throws -> R {
        let workID = nextID
        nextID += 1
        queue.append(workID)

        while queue.first != workID {
            if let currentTask {
                try await currentTask.value
            } else {
                // We're not up yet, but next task hasn't set up
                await Task.yield()
            }
        }

        // We're up now, set up a Task others can wait on
        let (condition, signal) = Condition.makeCondition()
        currentTask = Task { await condition.wait() }

        // Do our work
        let returnValue = try await work()
        
        // Remove ourselves from the queue
        queue.removeFirst()
        currentTask = nil
        
        // Finish the Task others were waiting on
        signal.signal()
        
        return returnValue
    }
}
