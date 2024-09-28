public struct InsertXML<Content: XML>: XMLUpdate {
    private let index: XMLIndex
    private let content: @Sendable () -> Content
    
    public init(
        at index: XMLIndex = .last,
        @XMLSnapshotBuilder content: @Sendable @escaping () -> Content
    ) {
        self.index = index
        self.content = content
    }
    
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        let content = self.content
        return [
            .create(XMLCreateChange(parentID: parentID, index: index, factory: { createContext in
                XMLSnapshot(parentID: parentID, createContext: createContext, builder: content)
            }))
        ]
    }
    
    public var body: Never { fatalError() }
}
