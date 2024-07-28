
public struct NilCoalescingScanner<Wrapped, Content: Scannable>: Scannable where Content.ScannerOutput == Optional<Wrapped>, Wrapped: Sendable {
    public typealias ScannerOutput = Wrapped
    
    private let content: @Sendable () -> Content
    private let defaultValue: Wrapped
    
    public init(defaultValue: Wrapped, @ScannerBuilder content: @escaping @Sendable () -> Content) {
        self.content = content
        self.defaultValue = defaultValue
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        guard let result = try content().scan(startingAt: input) else {
            return nil
        }
        if let resultValue = result.value {
            return ScannerResult(remaining: result.remaining, value: resultValue)
        } else {
            return ScannerResult(remaining: result.remaining, value: defaultValue)
        }
    }
}
