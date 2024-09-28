public struct UpsertXML<Content: XML, Changes: XMLUpdate>: XMLUpdate {
    private let index: XMLIndex
    private let existingElement: XMLUpsertQuery
    private let content: @Sendable () -> Content
    private let changes: @Sendable () -> Changes
    
    public init(
        at index: XMLIndex = .last,
        finding existingElement: XMLUpsertQuery,
        @XMLSnapshotBuilder orCreating content: @Sendable @escaping () -> Content,
        @XMLUpdateBuilder then changes: @Sendable @escaping () -> Changes
    ) {
        self.index = index
        self.existingElement = existingElement
        self.content = content
        self.changes = changes
    }
    
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        let theChanges = changes
        let theContent = content
        return [
            .upsert(
                XMLUpsertChange(
                    parentID: parentID,
                    index: index,
                    factory: { createContext in
                        XMLSnapshot(parentID: parentID, createContext: createContext, builder: theContent)
                    },
                    existingElementQuery: existingElement,
                    changesFactory: { element in
                        theChanges().changes(for: element.id)
                    }
                )
            )
        ]
    }
    
    public var body: Never { fatalError() }
}
