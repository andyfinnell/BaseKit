import Foundation

public struct RawRepresentableScanner<ScannerOutput: RawRepresentable & Sendable>: Scannable
    where ScannerOutput.RawValue == String, ScannerOutput: CaseIterable {
    
    public init() {}
    
    public func scan(
        startingAt input: Cursor<Source>
    ) throws -> ScannerResult<ScannerOutput>? {
        // Want to check longer cases first (greedy)
        let allCases = ScannerOutput.allCases
            .map { (string: $0.rawValue, value: $0) }
            .sorted { $0.string.count > $1.string.count }
        
        for possible in allCases {
            if let match = try possible.string.scan(startingAt: input) {
                return ScannerResult(remaining: match.remaining, value: possible.value)
            }
        }
        
        return nil
    }

}
