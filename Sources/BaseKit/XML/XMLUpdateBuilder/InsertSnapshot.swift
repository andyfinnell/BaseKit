/// Inserts a pre-built ``XMLPartialSnapshot`` as a child of the target element.
///
/// Unlike ``InsertXML`` which uses the snapshot builder DSL to construct content,
/// this takes an already-constructed snapshot. Useful for inserting duplicated,
/// pasted, or remapped subtrees.
public struct InsertSnapshot: XMLUpdate {
    private let snapshot: XMLPartialSnapshot
    private let index: XMLIndex
    private let overrideParent: Override<XMLID?>

    public init(_ snapshot: XMLPartialSnapshot, into parentID: XMLID, at index: XMLIndex = .last) {
        self.snapshot = snapshot
        self.index = index
        self.overrideParent = .overrideWith(parentID)
    }

    public func changes(for parentID: XMLID?) -> [XMLChange] {
        let usedParentID = overrideParent.compute(withExisting: parentID)
        let snapshot = self.snapshot
        return [
            .create(XMLCreateChange(
                parentID: usedParentID,
                index: index,
                factory: { _ in snapshot }
            ))
        ]
    }

    public var body: Never { fatalError() }
}
