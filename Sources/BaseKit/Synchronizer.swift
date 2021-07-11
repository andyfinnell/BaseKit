import Foundation

public final class Synchronizer {
    public init() {
    }
    
    public func synchronized(_ f: () -> ()) {
        queue.sync(execute: f)
    }
    
    private var queue = DispatchQueue(label: "synchronizer", attributes: [])
}
