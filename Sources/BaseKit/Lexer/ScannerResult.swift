import Foundation

public struct ScannerResult<T> {
    public let remaining: Cursor<Source>
    public let value: T
    
    public init(remaining: Cursor<Source>, value: T) {
        self.remaining = remaining
        self.value = value
    }
}

extension ScannerResult: Equatable where T: Equatable {}

public extension ScannerResult {
    func map<U>(_ transform: (T) -> U) -> ScannerResult<U> {
        ScannerResult<U>(remaining: remaining, value: transform(value))
    }
}
