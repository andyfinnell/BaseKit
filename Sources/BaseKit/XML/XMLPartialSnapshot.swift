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
    let roots: [XMLID]
    let values: [XMLID: XMLValue]
    let referenceIDs: [XMLID: XMLReferenceIDFuture]
    
    init(
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
}
