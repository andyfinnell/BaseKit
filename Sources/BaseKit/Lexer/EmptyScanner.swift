
public struct EmptyScanner: Scannable {
    public typealias ScannerOutput = Void
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<Void>? {
        ScannerResult(remaining: input, value: ())
    }
}
