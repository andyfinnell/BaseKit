public struct DeleteAttr: XMLUpdate {
    private let name: XMLAttribute
    
    public init(_ name: XMLAttribute) {
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
