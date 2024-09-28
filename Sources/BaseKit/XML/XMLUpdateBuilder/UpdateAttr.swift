public struct UpdateAttr: XMLUpdate {
    private let name: String
    private let operation: Operation
    
    public init(_ name: String, _ value: String, `default` defaultValue: String) {
        self.name = name
        self.operation = value == defaultValue ? .delete : .set(value)
    }
    
    public init<V: XMLFormattable & Equatable>(_ name: String, _ value: V, `default` defaultValue: V) {
        self.name = name
        self.operation = value == defaultValue ? .delete : .set(value.xmlFormatted())
    }
        
    public var body: some XMLUpdate {
        switch operation {
        case .delete:
            DeleteAttr(name)
        case let .set(value):
            SetAttr(name, value)
        }
    }
}

private extension UpdateAttr {
    enum Operation {
        case delete
        case set(String)
    }
}
