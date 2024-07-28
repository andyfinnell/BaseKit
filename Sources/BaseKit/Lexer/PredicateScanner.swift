
public struct PredicateScanner<Content: Scannable>: Scannable {
    public typealias ScannerOutput = Content.ScannerOutput
    
    private let content: @Sendable () -> Content
    private let predicate: @Sendable (ScannerOutput) -> Bool
    
    public init(
        @ScannerBuilder content: @escaping @Sendable () -> Content,
        predicate: @escaping @Sendable (ScannerOutput) -> Bool
    ) {
        self.content = content
        self.predicate = predicate
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        guard let result = try content().scan(startingAt: input),
              predicate(result.value) else {
            return nil
        }
        return result
    }
}

public extension Scannable {
    func ensure(_ predicate: @escaping @Sendable (ScannerOutput) -> Bool) -> PredicateScanner<Self> {
        PredicateScanner(content: { self }, predicate: predicate)
    }
}
