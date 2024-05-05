import Foundation

public extension Array {
    init(optional element: Element?) {
        self.init(element.map { [$0] } ?? [])
    }

    mutating func popFirst() -> Element? {
        guard let f = self.first else {
            return nil
        }
        remove(at: 0)
        return f
    }
    
    subscript(indexSet: IndexSet) -> [Element] {
        indexSet.compactMap { at($0) }
    }
    
    subscript(range: ClosedRange<Array.Index>) -> [Element] {
        range.compactMap { at($0) }
    }

    subscript(range: Range<Array.Index>) -> [Element] {
        range.compactMap { at($0) }
    }

    func at(_ index: Index) -> Element? {
        guard index >= startIndex && index < endIndex else {
            return nil
        }
        return self[index]
    }
    
    var penultimate: Element? {
        return at(count - 2)
    }

    @discardableResult
    mutating func removeFirstMatching(_ filter: (Element) -> Bool) -> Element? {
        var firstElement: Element?
        if let index = firstIndex(where: filter) {
            firstElement = self[index]
            remove(at: index)
        }
        return firstElement
    }

}
