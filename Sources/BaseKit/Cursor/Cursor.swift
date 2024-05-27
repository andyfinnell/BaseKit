import Foundation

public struct Cursor<S: CursorSource> {
    public let source: S
    public let index: S.SourceIndex
    private let filters: [AnyCursorFilter<S.Element>]
        
    public init(source: S, index: S.SourceIndex) {
        self.source = source
        self.index = index
        self.filters = []
    }
    
    public var element: S.Element? {
        if index < source.endIndex {
            return source[index]
        } else {
            return nil
        }
    }
        
    public func advance() -> Cursor<S> {
        advanceOnce().advanceIfExcluded()
    }

    public func advance(by count: Int) -> Cursor<S> {
        (0..<count).reduce(self) { partialResult, _ in
            partialResult.advance()
        }
    }

    public func regress() -> Cursor<S> {
        var cursor = regressOnce()
        while cursor.isExcluded() && cursor.index != source.startIndex {
            cursor = cursor.regressOnce()
        }
        if cursor.isExcluded() && cursor.index == source.startIndex {
            cursor = cursor.advance()
        }
        return cursor
    }
    
    public func mode(_ filter: AnyCursorFilter<S.Element>, block: (Cursor<S>) throws -> Cursor<S>) rethrows -> Cursor<S> {
        return try block(pushFilter(filter).advanceIfExcluded()).popFilter()
    }
}

extension Cursor: Comparable {
    public static func < (lhs: Cursor, rhs: Cursor) -> Bool {
        return lhs.index < rhs.index
    }
    
    public static func ==(lhs: Cursor, rhs: Cursor) -> Bool {
        return lhs.index == rhs.index
    }
}

extension Cursor: CustomStringConvertible {
    public var description: String {
        "\(index)"
    }
}

extension Cursor: Hashable {
    public func hash(into hasher: inout Hasher) {
        // Note: not great, but trying to specify that index is Hashable creates
        //   a compiler crash.
        hasher.combine(source.filename)
    }
}

public extension Cursor {
    var isStart: Bool {
        return index == source.startIndex
    }
    
    var notStart: Bool {
        return index != source.startIndex
    }
    
    var isEnd: Bool {
        return element == nil
    }
    
    var notEnd: Bool {
        return element != nil
    }
}

private extension Cursor {
    init(source: S, index: S.SourceIndex, filters: [AnyCursorFilter<S.Element>]) {
        self.source = source
        self.index = index
        self.filters = filters
    }

    func pushFilter(_ filter: AnyCursorFilter<S.Element>) -> Cursor<S> {
        return Cursor(source: source,
                      index: index,
                      filters: filters + [filter])
    }
    
    func popFilter() -> Cursor<S> {
        return Cursor(source: source,
                      index: index,
                      filters: filters.dropLast())
    }
    
    func update(index: S.SourceIndex) -> Cursor<S> {
        return Cursor(source: source,
                      index: index,
                      filters: filters)
    }

    func isExcluded() -> Bool {
        if filters.isEmpty {
            return false // if no filters, nothing to exclude
        }
        guard let value = element else {
            return false // always include eof so we stop
        }
        return filters.contains(where: { !$0.isIncluded(value) })
    }
    
    func advanceOnce() -> Cursor<S> {
        guard index < source.endIndex else {
            return update(index: source.endIndex)
        }

        let nextIndex = source.index(after: index)
        return update(index: nextIndex)
    }
    
    func advanceIfExcluded() -> Cursor<S> {
        var cursor = self
        while cursor.isExcluded() {
            cursor = cursor.advanceOnce()
        }
        return cursor
    }
    
    func regressOnce() -> Cursor<S> {        
        guard let priorIndex = source.index(before: index) else {
            return update(index: source.startIndex)
        }
        return update(index: priorIndex)
    }

}
