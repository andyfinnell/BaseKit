public struct Attr<V: XMLFormattable>: XML {
    private let name: XMLAttribute
    private let value: V?
        
    public init(_ name: XMLAttribute, _ value: V) {
        self.name = name
        self.value = value
    }
    
    public init(
        _ name: XMLAttribute,
        _ value: V,
        `default` defaultValue: V
    ) where V: Equatable {
        self.name = name
        self.value = value != defaultValue ? value : nil
    }
    
    public func attributes(context: XMLBuilderContext) -> [XMLAttribute: String] {
        if let value {
            [name: value.xmlFormatted(using: context.asXMLFormatContext)]
        } else {
            [:]
        }
    }
    
    public func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue] {
        []
    }
    
    public var body: Never { fatalError() }
}
