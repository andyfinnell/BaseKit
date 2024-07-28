
public protocol Scannable<ScannerOutput>: Sendable {
    associatedtype ScannerOutput: Sendable
    
    func scan(
        startingAt input: Cursor<Source>
    ) throws -> ScannerResult<ScannerOutput>?

}
