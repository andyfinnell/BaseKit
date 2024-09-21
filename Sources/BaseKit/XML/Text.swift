public struct Text: XML {
    private let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public var attributes: [String: String] { [:] }
    public func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue] {
        let id = XMLID()
        let text = XMLText(id: id, parentID: parentID, characters: value)
        storage[id] = .text(text)
        return [.text(text)]
    }
    
    public var body: Never { fatalError() }
}
