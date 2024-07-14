
@resultBuilder
public struct ScannerBuilder {
    public static func buildBlock() -> EmptyScanner {
        EmptyScanner()
    }
    
    public static func buildBlock<S: Scannable>(_ scanner: S) -> S {
        scanner
    }
    
    public static func buildBlock<each S: Scannable>(_ scanners: repeat each S) -> TupleScanner<repeat each S> {
        TupleScanner(scanners: (repeat each scanners))
    }
}
