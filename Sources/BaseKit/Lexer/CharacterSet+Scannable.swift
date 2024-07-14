import Foundation

extension CharacterSet: Scannable {
    public typealias ScannerOutput = String
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<String>? {
        if input.notEnd && input.in(self) {
            var output = ""
            let remaining = input.scan(into: &output)
            return ScannerResult(remaining: remaining, value: output)
        } else {
            return nil
        }
    }
}

extension Set: Scannable where Element == Character {
    public typealias ScannerOutput = String
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<String>? {
        if input.notEnd && input.in(self) {
            var output = ""
            let remaining = input.scan(into: &output)
            return ScannerResult(remaining: remaining, value: output)
        } else {
            return nil
        }
    }
}
