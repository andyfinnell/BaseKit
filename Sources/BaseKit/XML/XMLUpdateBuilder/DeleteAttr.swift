public struct DeleteAttr: XMLUpdate {
    private let name: String
    
    public init(_ name: String) {
        self.name = name
    }
        
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        guard let parentID else {
            return [] // TODO: throw error
        }
        return [
            .destroyAttribute(
                XMLAttributeDestroyChange(
                    elementID: parentID,
                    attributeName: name
                )
            )
        ]
    }
    
    public var body: Never { fatalError() }
}
