public struct Element<Content: XML>: XML {
    private let idOverride: XMLID?
    private let name: XMLName
    private let content: () -> Content
    
    public init(_ name: XMLName, id idOverride: XMLID? = nil, @XMLSnapshotBuilder content: @escaping () -> Content) {
        self.idOverride = idOverride
        self.name = name
        self.content = content
    }
    
    public func attributes(context: XMLBuilderContext) -> [XMLAttribute: String] { [:] }

    public func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue] {
        let childContent = content()
        let attrs = childContent.attributes(context: context)
        let id = idOverride ?? XMLID()
        let childContext = context.increaseIndent()
        let childValues = childContent.values(
            for: id,
            context: childContext,
            storingInto: &storage,
            registeringReferenceInto: &references
        )

        // Mixed-content elements (those with author-supplied Text siblings)
        // must preserve their character data exactly — inserting pretty-print
        // whitespace between siblings would corrupt SVG 1.1 §10.15 xml:space
        // normalization and similar character-data-sensitive parsers. Use the
        // children as authored.
        let hasAuthoredText = childValues.contains { value in
            if case .text = value { return true }
            return false
        }
        let allChildValues: [XMLValue]
        if hasAuthoredText {
            allChildValues = childValues
        } else {
            allChildValues = indented(
                childValues, in: id,
                childContext: childContext, context: context,
                storage: &storage)
        }
        
        let element = XMLElement(
            id: id,
            parentID: parentID,
            name: name,
            namespaceURI: nil,
            qualifiedName: nil,
            attributes: attrs,
            children: allChildValues.map(\.id)
        )
        storage[id] = .element(element)
        return [.element(element)]
    }
    
    public var body: Never { fatalError() }
}

private extension Element {
    func indented(
        _ childValues: [XMLValue],
        in id: XMLID,
        childContext: XMLBuilderContext,
        context: XMLBuilderContext,
        storage: inout [XMLID: XMLValue]
    ) -> [XMLValue] {
        var allChildValues = [XMLValue]()
        var isIndented = false
        for (i, childValue) in childValues.enumerated() {
            switch childValue {
            case .cdata, .element, .comment:
                // These should go on a line on their own
                let isLast = i == (childValues.count - 1)

                if !isIndented {
                    let prefixText = XMLText(id: XMLID(), parentID: id, characters: "\n\(childContext.indentString)")
                    storage[prefixText.id] = .text(prefixText)
                    allChildValues.append(.text(prefixText))
                }

                allChildValues.append(childValue)

                let postfixString: String
                if isLast {
                    postfixString = "\n\(context.indentString)"
                } else {
                    postfixString = "\n\(childContext.indentString)"
                }
                let postfixText = XMLText(id: XMLID(), parentID: id, characters: postfixString)
                storage[postfixText.id] = .text(postfixText)
                allChildValues.append(.text(postfixText))
                isIndented = true

            case .text, .ignorableWhitespace:
                allChildValues.append(childValue)
                isIndented = false
            }
        }
        return allChildValues
    }
}
