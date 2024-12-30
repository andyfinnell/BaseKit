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
    
    func at(_ indexSet: IndexSet) -> [Element] {
        indexSet.compactMap { at($0) }
    }
    
    func at(_ range: ClosedRange<Array.Index>) -> [Element] {
        range.compactMap { at($0) }
    }

    func at(_ range: Range<Array.Index>) -> [Element] {
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

    mutating func reorder(from index1: XMLIndex, to index2: XMLIndex) {
        let fromIndex: Int
        switch index1 {
        case let .at(i):
            fromIndex = i
        case .last:
            fromIndex = count - 1
        }
        
        let toIndex: Int
        switch index2 {
        case let .at(i):
            toIndex = i
        case .last:
            toIndex = count - 1
        }
        
        reorder(from: fromIndex, to: toIndex)
    }

    mutating func reorder(from fromIndex: Int, to toIndex: Int) {
        let value = remove(at: fromIndex)
        if toIndex >= fromIndex {
            insert(value, at: toIndex - 1)
        } else {
            insert(value, at: toIndex)
        }
    }

    mutating func insert(contentsOf elements: [Element], at index: XMLIndex) {
        switch index {
        case let .at(i):
            insert(contentsOf: elements, at: i)
        case .last:
            append(contentsOf: elements)
        }
    }

    mutating func remove(where predicate: (Element) -> Bool) throws -> Int {
        guard let index = firstIndex(where: predicate) else {
            throw XMLError.indexOutOfBounds
        }
        remove(at: index)
        return index
    }
    
    func isValidIndex(_ index: Index) -> Bool {
        index >= startIndex && index < endIndex
    }
    
    mutating func checkedRemove(at index: Index) {
        guard isValidIndex(index) else {
            return
        }
        remove(at: index)
    }
    
    func updateSelectionIndex(_ index: Index) -> Index? {
        if isValidIndex(index) {
            return index
        } else {
            let newIndex = count - 1
            if isValidIndex(newIndex) {
                return newIndex
            } else {
                return nil
            }
        }
    }
}
