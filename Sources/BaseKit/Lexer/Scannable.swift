
public protocol Scannable<ScannerOutput>: Sendable {
    associatedtype ScannerOutput
    
    func scan(
        startingAt input: Cursor<Source>
    ) throws -> ScannerResult<ScannerOutput>?

}
