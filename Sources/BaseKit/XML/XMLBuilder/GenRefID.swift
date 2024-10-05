public struct GenRefID: XML {
    private let name: String
    private let template: String
    
    public init(_ name: String, withTemplate template: String) {
        self.name = name
        self.template = template
    }
    
    public func attributes(context: XMLBuilderContext) -> [String: String] {
        [:]
    }
    
    public func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue] {
        if let parentID {
            references[parentID] = XMLReferenceIDFuture(name: name, template: template)
        }
        
        return []
    }
    
    public var body: Never { fatalError() }

}
