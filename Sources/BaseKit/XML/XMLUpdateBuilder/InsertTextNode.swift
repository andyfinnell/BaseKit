/// Inserts a bare XML text node as a child of the target element.
///
/// Unlike ``InsertXML``, this does not add any formatting whitespace
/// around the content — it creates exactly one text node.
///
/// Pass an explicit `id` when the caller needs to know the new node's
/// ID before the command executes (e.g. to track it in a segment model).
/// When omitted, a fresh ID is generated inside the factory.
public struct InsertTextNode: XMLUpdate {
    private let explicitID: XMLID?
    private let content: String
    private let index: XMLIndex
    private let overrideParent: Override<XMLID?>

    public init(_ content: String, at index: XMLIndex = .last) {
        self.explicitID = nil
        self.content = content
        self.index = index
        self.overrideParent = .useExisting
    }

    public init(_ content: String, into parentID: XMLID, at index: XMLIndex = .last) {
        self.explicitID = nil
        self.content = content
        self.index = index
        self.overrideParent = .overrideWith(parentID)
    }

    public init(id: XMLID, _ content: String, into parentID: XMLID, at index: XMLIndex = .last) {
        self.explicitID = id
        self.content = content
        self.index = index
        self.overrideParent = .overrideWith(parentID)
    }

    public func changes(for parentID: XMLID?) -> [XMLChange] {
        let usedParentID = overrideParent.compute(withExisting: parentID)
        let content = self.content
        let explicitID = self.explicitID
        return [
            .create(XMLCreateChange(
                parentID: usedParentID,
                index: index,
                factory: { _ in
                    let nodeID = explicitID ?? XMLID()
                    let textNode = XMLText(id: nodeID, parentID: usedParentID, characters: content)
                    return XMLPartialSnapshot(
                        roots: [nodeID],
                        values: [nodeID: .text(textNode)]
                    )
                }
            ))
        ]
    }

    public var body: Never { fatalError() }
}
