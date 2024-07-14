
public struct ChoiceOfScanner<Content: Scannable>: Scannable {
    public typealias ScannerOutput = Content.ScannerOutput
    
    private let content: @Sendable () -> Content
    
    public init(@AlternateBuilder content: @escaping @Sendable () -> Content) {
        self.content = content
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        try content().scan(startingAt: input)
    }
}
