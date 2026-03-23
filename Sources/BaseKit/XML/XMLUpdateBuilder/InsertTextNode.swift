/// Inserts a bare XML text node as a child of the target element.
///
/// Unlike ``InsertXML``, this does not add any formatting whitespace
/// around the content — it creates exactly one text node.
public struct InsertTextNode: XMLUpdate {
    private let content: String
    private let index: XMLIndex
    private let overrideParent: Override<XMLID?>

    public init(_ content: String, at index: XMLIndex = .last) {
        self.content = content
        self.index = index
        self.overrideParent = .useExisting
    }

    public init(_ content: String, into parentID: XMLID, at index: XMLIndex = .last) {
        self.content = content
        self.index = index
        self.overrideParent = .overrideWith(parentID)
    }

    public func changes(for parentID: XMLID?) -> [XMLChange] {
        let usedParentID = overrideParent.compute(withExisting: parentID)
        let content = self.content
        return [
            .create(XMLCreateChange(
                parentID: usedParentID,
                index: index,
                factory: { _ in
                    let textNode = XMLText(id: XMLID(), parentID: usedParentID, characters: content)
                    return XMLPartialSnapshot(
                        roots: [textNode.id],
                        values: [textNode.id: .text(textNode)]
                    )
                }
            ))
        ]
    }

    public var body: Never { fatalError() }
}
