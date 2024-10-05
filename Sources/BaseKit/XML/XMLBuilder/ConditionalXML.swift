
public struct ConditionalXML<True: XML, False: XML>: XML {
    public enum Value {
        case `true`(True)
        case `false`(False)
    }
    private let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func attributes(context: XMLBuilderContext) -> [String: String] {
        switch value {
        case let .true(value):
            value.attributes(context: context)
        case let .false(value):
            value.attributes(context: context)
        }
    }
    
    public func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue] {
        switch value {
        case let .true(value):
            value.values(for: parentID, context: context, storingInto: &storage, registeringReferenceInto: &references)
        case let .false(value):
            value.values(for: parentID, context: context, storingInto: &storage, registeringReferenceInto: &references)
        }
    }
    
    public var body: Never { fatalError() }
}
