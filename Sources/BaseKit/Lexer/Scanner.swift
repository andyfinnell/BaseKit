
public struct Scanner<Content: Scannable>: Scannable {
    public typealias ScannerOutput = Content.ScannerOutput
    
    private let content: @Sendable () -> Content
    
    public init(@ScannerBuilder _ content: @escaping @Sendable () -> Content) {
        self.content = content
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<Content.ScannerOutput>? {
        try content().scan(startingAt: input)
    }
}
