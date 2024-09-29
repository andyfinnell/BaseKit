public struct InsertXML<Content: XML>: XMLUpdate {
    private let index: XMLIndex
    private let content: @Sendable () -> Content
    private let overrideParent: Override<XMLID?>
    
    public init(
        at index: XMLIndex = .last,
        @XMLSnapshotBuilder content: @Sendable @escaping () -> Content
    ) {
        self.index = index
        self.content = content
        self.overrideParent = .useExisting
    }
    
    public init(
        into parentID: XMLID?,
        at index: XMLIndex = .last,
        @XMLSnapshotBuilder content: @Sendable @escaping () -> Content
    ) {
        self.index = index
        self.content = content
        self.overrideParent = .overrideWith(parentID)
    }

    public func changes(for parentID: XMLID?) -> [XMLChange] {
        let content = self.content
        let usedParentID = overrideParent.compute(withExisting: parentID)
        return [
            .create(XMLCreateChange(parentID: usedParentID, index: index, factory: { createContext in
                XMLSnapshot(parentID: usedParentID, createContext: createContext, builder: content)
            }))
        ]
    }
    
    public var body: Never { fatalError() }
}
