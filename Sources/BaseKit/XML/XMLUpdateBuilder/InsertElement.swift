/// Inserts a bare XML element as a child of the target element.
///
/// Unlike ``InsertXML``, this does not add any formatting whitespace
/// around the content — it creates exactly one element node with
/// the given attributes and child text nodes.
///
/// Pass explicit `id` and `childIDs` when the caller needs to know
/// the new node IDs before the command executes. When omitted, fresh
/// IDs are generated inside the factory.
public struct InsertElement: XMLUpdate {
    private let explicitID: XMLID?
    private let name: XMLName
    private let attributes: [XMLAttribute: String]
    private let children: [Child]
    private let index: XMLIndex
    private let overrideParent: Override<XMLID?>

    /// A child text node to create inside the element.
    public struct Child: Sendable {
        let explicitID: XMLID?
        let text: String

        /// Creates a child text node. Pass an `id` to use a pre-specified ID.
        public init(id: XMLID? = nil, text: String) {
            self.explicitID = id
            self.text = text
        }
    }

    public init(
        id: XMLID? = nil,
        name: XMLName,
        attributes: [XMLAttribute: String] = [:],
        children: [Child] = [],
        into parentID: XMLID,
        at index: XMLIndex = .last
    ) {
        self.explicitID = id
        self.name = name
        self.attributes = attributes
        self.children = children
        self.index = index
        self.overrideParent = .overrideWith(parentID)
    }

    public func changes(for parentID: XMLID?) -> [XMLChange] {
        let usedParentID = overrideParent.compute(withExisting: parentID)
        let explicitID = self.explicitID
        let name = self.name
        let attributes = self.attributes
        let children = self.children
        return [
            .create(XMLCreateChange(
                parentID: usedParentID,
                index: index,
                factory: { @Sendable _ in
                    let elementID = explicitID ?? XMLID()

                    var childIDs: [XMLID] = []
                    var values: [XMLID: XMLValue] = [:]

                    for child in children {
                        let childID = child.explicitID ?? XMLID()
                        childIDs.append(childID)
                        values[childID] = .text(XMLText(
                            id: childID,
                            parentID: elementID,
                            characters: child.text
                        ))
                    }

                    values[elementID] = .element(XMLElement(
                        id: elementID,
                        parentID: usedParentID,
                        name: name,
                        namespaceURI: nil,
                        qualifiedName: nil,
                        attributes: attributes,
                        children: childIDs
                    ))

                    return XMLPartialSnapshot(
                        roots: [elementID],
                        values: values
                    )
                }
            ))
        ]
    }

    public var body: Never { fatalError() }
}
