public struct XMLBuilderContext {
    public let indent: Int
    private let variables: [String: String]
    
    public init(indent: Int = 0, variables: [String: String]) {
        self.indent = indent
        self.variables = variables
    }
    
    public func increaseIndent() -> XMLBuilderContext {
        XMLBuilderContext(indent: indent + 1, variables: variables)
    }

    public func decreaseIndent() -> XMLBuilderContext {
        XMLBuilderContext(indent: max(0, indent - 1), variables: variables)
    }

    var indentString: String {
        String(repeating: " ", count: (indent * 2))
    }
    
    var asXMLFormatContext: XMLFormatContext {
        XMLFormatContext(variables: variables)
    }
}

public protocol XMLImpl {
    func attributes(context: XMLBuilderContext) -> [XMLAttribute: String]
    func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue]
}

public protocol XML: XMLImpl {
    associatedtype Body: XML
    
    @XMLSnapshotBuilder
    var body: Body { get }
}

public extension XML {
    func attributes(context: XMLBuilderContext) -> [XMLAttribute: String] {
        body.attributes(context: context)
    }
    
    func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue] {
        body.values(
            for: parentID,
            context: context,
            storingInto: &storage,
            registeringReferenceInto: &references
        )
    }
}

extension Never: XML {
    public func attributes(context: XMLBuilderContext) -> [XMLAttribute: String] { [:] }
    public func values(
        for parentID: XMLID?,
        context: XMLBuilderContext,
        storingInto storage: inout [XMLID: XMLValue],
        registeringReferenceInto references: inout [XMLID: XMLReferenceIDFuture]
    ) -> [XMLValue] { [] }
    
    public var body: Never { fatalError() }
}
