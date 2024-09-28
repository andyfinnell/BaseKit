
public struct ArrayXML<Element: XML>: XML {
    private let elements: [Element]
    
    public init(_ elements: [Element]) {
        self.elements = elements
    }
    
    public var attributes: [String: String] {
        elements.reduce(into: [String: String]()) { sum, element in
            sum.merge(element.attributes, uniquingKeysWith: { _, new in new })
        }
    }
    
    public func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue] {
        elements.flatMap { $0.values(for: parentID, context: context, storingInto: &storage) }
    }
    
    public var body: Never { fatalError() }
}
