public struct ReorderXML: XMLUpdate {
    private let from: XMLIndex
    private let to: XMLIndex
    
    public init(from: XMLIndex, to: XMLIndex) {
        self.from = from
        self.to = to
    }
    
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        [
            .reorder(XMLReorderChange(parentID: parentID, fromIndex: from, toIndex: to))
        ]
    }
    
    public var body: Never { fatalError() }
}
