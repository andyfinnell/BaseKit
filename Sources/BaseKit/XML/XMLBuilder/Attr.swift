public struct Attr: XML {
    private let name: String
    private let value: String?
    
    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
    
    public init<V: XMLFormattable>(_ name: String, _ value: V) {
        self.name = name
        self.value = value.xmlFormatted()
    }

    public init(_ name: String, _ value: String, `default` defaultValue: String) {
        self.name = name
        self.value = value != defaultValue ? value : nil
    }
    
    public init<V: XMLFormattable & Equatable>(_ name: String, _ value: V, `default` defaultValue: V) {
        self.name = name
        self.value = value != defaultValue ? value.xmlFormatted() : nil
    }
    
    public var attributes: [String: String] {
        if let value {
            [name: value]
        } else {
            [:]
        }
    }
    
    public func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue] { [] }
    
    public var body: Never { fatalError() }
}
