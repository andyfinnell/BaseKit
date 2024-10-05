public struct Text: XML {
    private let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public func attributes(context: XMLBuilderContext) -> [String: String] { [:] }
    public func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue] {
        let id = XMLID()
        let text = XMLText(id: id, parentID: parentID, characters: value)
        storage[id] = .text(text)
        return [.text(text)]
    }
    
    public var body: Never { fatalError() }
}
