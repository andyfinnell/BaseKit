
public struct TupleXML<each X: XML>: XML {
    let xml: (repeat each X)
    
    public init(_ xml: (repeat each X)) {
        self.xml = xml
    }
    
    public var attributes: [String: String] {
        var allAttributes = [String: String]()
        for child in repeat (each xml) {
            allAttributes.merge(child.attributes, uniquingKeysWith: { _, new in new })
        }
        return allAttributes
    }
    
    public func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue] {
        var allValues = [XMLValue]()
        for child in repeat (each xml) {
            allValues.append(contentsOf: child.values(for: parentID, context: context, storingInto: &storage))
        }
        return allValues
    }
    
    public var body: Never { fatalError() }
}
