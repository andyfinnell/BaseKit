public struct DeleteXML: XMLUpdate {
    private let id: XMLID
    
    public init(with id: XMLID) {
        self.id = id
    }
    
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        return [
            .destroy(XMLDestroyChange(id: id))
        ]
    }
    
    public var body: Never { fatalError() }
}
