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
    
    func flatMap<W, U>(_ transform: (W) -> U?) -> ScannerResult<U?> where T == Optional<W> {
        if let value {
            return ScannerResult<U?>(remaining: remaining, value: transform(value))
        } else {
            return ScannerResult<U?>(remaining: remaining, value: nil)
        }
    }
}
