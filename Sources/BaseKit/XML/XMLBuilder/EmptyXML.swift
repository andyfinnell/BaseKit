
public struct EmptyXML: XML {
    public init() {}
    
    public func attributes(context: XMLBuilderContext) -> [String: String] { [:] }
    public func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue], registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
) -> [XMLValue] { [] }

    public var body: Never { fatalError() }
}
