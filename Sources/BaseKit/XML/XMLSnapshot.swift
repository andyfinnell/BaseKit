import Foundation

public struct XMLSnapshot: Sendable, Hashable {
    public let roots: [XMLID]
    public let values: [XMLID: XMLValue]
    
    public init(roots: [XMLID], values: [XMLID: XMLValue]) {
        self.roots = roots
        self.values = values
    }
}

public extension XMLSnapshot {
    func subtreeSnapshot(from rootID: XMLID) -> XMLPartialSnapshot? {
        guard values[rootID] != nil else { return nil }
        var subtreeValues = [XMLID: XMLValue]()
        collectSubtree(rootID, into: &subtreeValues)
        return XMLPartialSnapshot(roots: [rootID], values: subtreeValues)
    }

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

private extension XMLSnapshot {
    func collectSubtree(_ id: XMLID, into storage: inout [XMLID: XMLValue]) {
        guard let value = values[id] else { return }
        storage[id] = value
        for childID in value.children {
            collectSubtree(childID, into: &storage)
        }
    }
}
