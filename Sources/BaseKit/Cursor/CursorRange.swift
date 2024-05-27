import Foundation

public struct CursorRange<S: CursorSource>: Hashable {
    public let start: Cursor<S>
    public let end: Cursor<S> // exclusive; points to next item after last valid item in range
    
    public init(start: Cursor<S>, end: Cursor<S>) {
        self.start = start
        self.end = end
    }
}

public extension CursorRange {
    var source: S {
        start.source
    }
}

extension CursorRange: CustomStringConvertible {
    public var description: String {
        "\(start)-\(end)"
    }
}

extension CursorRange: CursorSource {
    public typealias SourceIndex = S.SourceIndex
    public typealias Element = S.Element
    
    public var filename: String {
        source.filename
    }
    
    public var startIndex: SourceIndex {
        start.index
    }
    
    public var endIndex: SourceIndex {
        end.index
    }
    
    public func index(after index: SourceIndex) -> SourceIndex {
        guard index < endIndex else {
            return endIndex
        }
        return start.source.index(after: index)
    }
    
    public func index(before index: SourceIndex) -> SourceIndex? {
        guard index > startIndex else {
            return nil
        }
        return start.source.index(before: index)
    }
    
    public subscript(index: SourceIndex) -> S.Element {
        start.source[index]
    }
}
