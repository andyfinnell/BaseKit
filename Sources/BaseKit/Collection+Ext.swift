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
