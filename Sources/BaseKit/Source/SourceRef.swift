import Foundation

public struct SourceRef<T> {
    public let value: T
    public let range: CursorRange<Source>?
    
    public init(value: T, range: CursorRange<Source>?) {
        self.value = value
        self.range = range
    }
}

extension SourceRef: Equatable where T: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

