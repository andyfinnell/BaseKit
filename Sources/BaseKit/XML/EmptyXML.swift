
public struct EmptyXML: XML {
    public init() {}
    
    public var attributes: [String: String] { [:] }
    public func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue] { [] }

    public var body: Never { fatalError() }
}
