public struct FlatMapScanner<WrappedOutput: Sendable, Wrapped: Sendable, Content: Scannable>: Scannable where Content.ScannerOutput == Optional<Wrapped> {
    public typealias ScannerOutput = Optional<WrappedOutput>
    
    private let content: @Sendable () -> Content
    private let transform: @Sendable (Wrapped) -> ScannerOutput
    
    public init(
        @ScannerBuilder content: @escaping @Sendable () -> Content,
        transform: @escaping @Sendable (Wrapped) -> ScannerOutput
    ) {
        self.content = content
        self.transform = transform
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        guard let result = try content().scan(startingAt: input) else {
            return nil
        }
        return result.flatMap(transform)
    }
}

public extension Scannable {
    func flatMap<Wrapped: Sendable, U: Sendable>(_ transform: @escaping @Sendable (Wrapped) -> U?) -> FlatMapScanner<U, Wrapped, Self> where ScannerOutput == Optional<Wrapped> {
        FlatMapScanner(content: { self }, transform: transform)
    }
}
