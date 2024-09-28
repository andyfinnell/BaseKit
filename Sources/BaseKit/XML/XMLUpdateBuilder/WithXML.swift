public struct WithXML<Content: XMLUpdate>: XMLUpdate {
    private let id: XMLID
    private let content: () -> Content
    
    public init(id: XMLID, @XMLUpdateBuilder content: @escaping () -> Content) {
        self.id = id
        self.content = content
    }
    
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        content().changes(for: id)
    }
    
    public var body: Never { fatalError() }
}
