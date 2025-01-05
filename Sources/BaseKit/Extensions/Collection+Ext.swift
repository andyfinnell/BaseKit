public extension Collection {
    var only: Self.Iterator.Element? {
        if count == 1 {
            return first
        }
        return nil
    }
}

public extension RangeReplaceableCollection {
    mutating func prepend<C : Collection>(contentsOf newElements: C) where C.Iterator.Element == Iterator.Element {
        insert(contentsOf: newElements, at: startIndex)
    }
}

public extension Collection where Element: Equatable {
    func allEqual() -> Bool {
        guard let first, count > 1 else {
            return true // if no elements, or just 1 then must be equal
        }
        return !contains(where: { $0 != first })
    }
}
