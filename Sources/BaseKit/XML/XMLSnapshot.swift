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
    init<Content: XML>(@XMLSnapshotBuilder builder: () -> Content) {
        let built = builder()
        var storage = [XMLID: XMLValue]()
        let context = XMLBuilderContext(
            indent: 0,
            variables: [:]
        )
        var allRootValues = [XMLValue]()
        
        let prefixString = "\(context.indentString)"
        let prefixText = XMLText(id: XMLID(), parentID: nil, characters: prefixString)
        storage[prefixText.id] = .text(prefixText)
        allRootValues.append(.text(prefixText))

        var refIDs = [XMLID: XMLReferenceIDFuture]()
        allRootValues.append(
            contentsOf: built.values(
                for: nil,
                context: context,
                storingInto: &storage,
                registeringReferenceInto: &refIDs
            )
        )
        
        roots = allRootValues.map(\.id)
        values = storage
    }
}
