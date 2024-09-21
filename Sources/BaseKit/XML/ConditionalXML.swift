
public struct ConditionalXML<True: XML, False: XML>: XML {
    public enum Value {
        case `true`(True)
        case `false`(False)
    }
    private let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public var attributes: [String: String] {
        switch value {
        case let .true(value):
            value.attributes
        case let .false(value):
            value.attributes
        }
    }
    
    public func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue] {
        switch value {
        case let .true(value):
            value.values(for: parentID, context: context, storingInto: &storage)
        case let .false(value):
            value.values(for: parentID, context: context, storingInto: &storage)
        }
    }
    
    public var body: Never { fatalError() }
}
