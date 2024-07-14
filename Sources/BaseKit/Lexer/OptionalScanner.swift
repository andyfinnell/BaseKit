
public struct OptionalScanner<Content: Scannable>: Scannable {
    public typealias ScannerOutput = Content.ScannerOutput?
    
    private let content: @Sendable () -> Content
    
    public init(@ScannerBuilder content: @escaping @Sendable () -> Content) {
        self.content = content
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<Content.ScannerOutput?>? {
        if let result = try content().scan(startingAt: input) {
            return ScannerResult(remaining: result.remaining, value: result.value)
        } else {
            return ScannerResult(remaining: input, value: nil)
        }
    }
}
