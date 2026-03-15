import Foundation

public struct XMLReferenceIDFuture: Sendable, Hashable {
    public let name: String
    public let template: String
    
    public init(name: String, template: String) {
        self.name = name
        self.template = template
    }
}

public struct XMLPartialSnapshot: Sendable {
    public let roots: [XMLID]
    public let values: [XMLID: XMLValue]
    public let referenceIDs: [XMLID: XMLReferenceIDFuture]

    public init(
        roots: [XMLID],
        values: [XMLID: XMLValue],
        referenceIDs: [XMLID: XMLReferenceIDFuture] = [:]
    ) {
        self.roots = roots
        self.values = values
        self.referenceIDs = referenceIDs
    }
}

public extension XMLPartialSnapshot {
    init(_ values: XMLValue...) {
        self.init(values: values)
    }
    
    init(values: [XMLValue]) {
        roots = values.map { $0.id }
        self.values = values.reduce(into: [XMLID: XMLValue]()) { sum, value in
            sum[value.id] = value
        }
        referenceIDs = [:]
    }

    init<Content: XML>(parentID: XMLID?, createContext: XMLCreateContext, @XMLSnapshotBuilder builder: () -> Content) {
        let built = builder()
        var storage = [XMLID: XMLValue]()
        let context = XMLBuilderContext(
            indent: createContext.indent,
            variables: createContext.variables
        )
        var allRootValues = [XMLValue]()
        
        let prefixString: String
        if createContext.isFirst {
            prefixString = "\n\(context.indentString)"
        } else {
            prefixString = "\(context.indentString)"
        }
        let prefixText = XMLText(id: XMLID(), parentID: parentID, characters: prefixString)
        storage[prefixText.id] = .text(prefixText)
        allRootValues.append(.text(prefixText))

        var refIDs = [XMLID: XMLReferenceIDFuture]()
        allRootValues.append(
            contentsOf: built.values(
                for: parentID,
                context: context,
                storingInto: &storage,
                registeringReferenceInto: &refIDs
            )
        )
        
        if createContext.isLast {
            let postfixString = "\n\(context.decreaseIndent().indentString)"
            let postfixText = XMLText(id: XMLID(), parentID: parentID, characters: postfixString)
            storage[postfixText.id] = .text(postfixText)
            allRootValues.append(.text(postfixText))
        }
        
        roots = allRootValues.map(\.id)
        values = storage
        referenceIDs = refIDs
    }

    /// Creates a deep copy of this snapshot with fresh XMLIDs.
    /// Returns the remapped snapshot and the mapping from old IDs to new IDs.
    func remappingIDs(newParentID: XMLID?) -> (snapshot: XMLPartialSnapshot, idMapping: [XMLID: XMLID]) {
        var idMapping = [XMLID: XMLID]()
        for id in values.keys {
            idMapping[id] = XMLID()
        }

        var newValues = [XMLID: XMLValue]()
        for (oldID, value) in values {
            guard let newID = idMapping[oldID] else { continue }
            let isRoot = roots.contains(oldID)
            let resolvedParentID: XMLID? = isRoot ? newParentID : value.parentID.flatMap { idMapping[$0] }

            switch value {
            case let .element(element):
                let newChildren = element.children.compactMap { idMapping[$0] }
                let newElement = XMLElement(
                    id: newID,
                    parentID: resolvedParentID,
                    name: element.name,
                    namespaceURI: element.namespaceURI,
                    qualifiedName: element.qualifiedName,
                    attributes: element.attributes,
                    children: newChildren
                )
                newValues[newID] = .element(newElement)
            case let .text(text):
                newValues[newID] = .text(XMLText(id: newID, parentID: resolvedParentID, characters: text.characters))
            case let .cdata(cdata):
                newValues[newID] = .cdata(XMLCData(id: newID, parentID: resolvedParentID, data: cdata.data))
            case let .comment(comment):
                newValues[newID] = .comment(XMLComment(id: newID, parentID: resolvedParentID, text: comment.text))
            case let .ignorableWhitespace(ws):
                newValues[newID] = .ignorableWhitespace(XMLIgnorableWhitespace(id: newID, parentID: resolvedParentID, text: ws.text))
            }
        }

        let newRoots = roots.compactMap { idMapping[$0] }

        // Elements with SVG id attributes need new unique reference IDs
        var newReferenceIDs = [XMLID: XMLReferenceIDFuture]()
        for (oldID, value) in values {
            if case let .element(element) = value, let refID = element.attributes[.id] {
                if let newID = idMapping[oldID] {
                    newReferenceIDs[newID] = XMLReferenceIDFuture(name: "clone-\(refID)", template: refID)
                }
            }
        }

        return (
            XMLPartialSnapshot(roots: newRoots, values: newValues, referenceIDs: newReferenceIDs),
            idMapping
        )
    }
}
