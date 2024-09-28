import Foundation

public struct XMLSnapshot: Sendable {
    public let roots: [XMLID]
    public let values: [XMLID: XMLValue]
    
    public init(roots: [XMLID], values: [XMLID: XMLValue]) {
        self.roots = roots
        self.values = values
    }
}

public extension XMLSnapshot {
    init(_ values: XMLValue...) {
        self.init(values: values)
    }
    
    init(values: [XMLValue]) {
        roots = values.map { $0.id }
        self.values = values.reduce(into: [XMLID: XMLValue]()) { sum, value in
            sum[value.id] = value
        }
    }
    
    init<Content: XML>(parentID: XMLID?, createContext: XMLCreateContext, @XMLSnapshotBuilder builder: () -> Content) {
        let built = builder()
        var storage = [XMLID: XMLValue]()
        let context = XMLBuilderContext(indent: createContext.indent)
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

        allRootValues.append(contentsOf: built.values(for: parentID, context: context, storingInto: &storage))
        
        if createContext.isLast {
            let postfixString = "\n\(context.decreaseIndent().indentString)"
            let postfixText = XMLText(id: XMLID(), parentID: parentID, characters: postfixString)
            storage[postfixText.id] = .text(postfixText)
            allRootValues.append(.text(postfixText))
        }
        
        roots = allRootValues.map(\.id)
        values = storage
    }
}
