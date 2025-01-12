
public struct ArrayXML<Element: XML>: XML {
    private let elements: [Element]
    
    public init(_ elements: [Element]) {
        self.elements = elements
    }
    
    public func attributes(context: XMLBuilderContext) -> [XMLAttribute: String] {
        elements.reduce(into: [XMLAttribute: String]()) { sum, element in
            sum.merge(element.attributes(context: context), uniquingKeysWith: { _, new in new })
        }
    }
    
    public func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue] {
        elements.flatMap {
            $0.values(
                for: parentID,
                context: context,
                storingInto: &storage,
                registeringReferenceInto: &references
            )
        }
    }
    
    public var body: Never { fatalError() }
}
