public struct SetAttr: XMLUpdate {
    private let name: String
    private let value: String
    
    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
    
    public init<V: XMLFormattable>(_ name: String, _ value: V) {
        self.name = name
        self.value = value.xmlFormatted()
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
