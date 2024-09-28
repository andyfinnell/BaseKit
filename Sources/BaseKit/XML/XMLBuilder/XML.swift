public struct XMLBuilderContext {
    public let indent: Int
    
    public init(indent: Int = 0) {
        self.indent = indent
    }
    
    public func increaseIndent() -> XMLBuilderContext {
        XMLBuilderContext(indent: indent + 1)
    }

    public func decreaseIndent() -> XMLBuilderContext {
        XMLBuilderContext(indent: max(0, indent - 1))
    }

    var indentString: String {
        String(repeating: " ", count: (indent * 2))
    }
}

public protocol XMLImpl {
    var attributes: [String: String] { get }
    func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue]
}

public protocol XML: XMLImpl {
    associatedtype Body: XML
    
    var body: Body { get }
}

public extension XML {
    var attributes: [String: String] {
        body.attributes
    }
    
    func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue] {
        body.values(for: parentID, context: context, storingInto: &storage)
    }
}

extension Never: XML {
    public var attributes: [String: String] { [:] }
    public func values(for parentID: XMLID?, context: XMLBuilderContext, storingInto storage: inout [XMLID: XMLValue]) -> [XMLValue] { [] }
    
    public var body: Never { fatalError() }
}
