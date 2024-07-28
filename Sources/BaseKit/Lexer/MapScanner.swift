
public struct MapScanner<ScannerOutput: Sendable, Content: Scannable>: Scannable {
    private let content: @Sendable () -> Content
    private let transform: @Sendable (Content.ScannerOutput) -> ScannerOutput
    
    public init(
        @ScannerBuilder content: @escaping @Sendable () -> Content,
        transform: @escaping @Sendable (Content.ScannerOutput) -> ScannerOutput
    ) {
        self.content = content
        self.transform = transform
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        guard let result = try content().scan(startingAt: input) else {
            return nil
        }
        return result.map(transform)
    }
}

public extension Scannable {
    func map<T>(_ transform: @escaping @Sendable (ScannerOutput) -> T) -> MapScanner<T, Self> {
        MapScanner(content: { self }, transform: transform)
    }
}
