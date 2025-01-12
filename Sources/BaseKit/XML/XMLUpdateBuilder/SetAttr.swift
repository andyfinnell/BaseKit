public struct SetAttr: XMLUpdate {
    private let name: XMLAttribute
    private let value: @Sendable (XMLUpdateContext) -> String
        
    public init<V: XMLFormattable & Sendable>(_ name: XMLAttribute, _ value: V) {
        self.name = name
        self.value = { value.xmlFormatted(using: $0.asXMLFormatContext) }
    }
    
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        guard let parentID else {
            return [] // TODO: throw error
        }
        return [
            .upsertAttribute(
                XMLAttributeUpsertChange(
                    elementID: parentID,
                    attributeName: name,
                    attributeValue: value
                )
            )
        ]
    }
    
    public var body: Never { fatalError() }
}
