import Foundation

public enum XMLIndex: Hashable, Sendable {
    case last
    case at(Int)
}

public struct XMLCreateContext: Sendable {
    public let indent: Int
    public let isFirst: Bool
    public let isLast: Bool
    let variables: [String: String]
    
    public init(indent: Int, isFirst: Bool, isLast: Bool, variables: [String: String]) {
        self.indent = indent
        self.isFirst = isFirst
        self.isLast = isLast
        self.variables = variables
    }
}

public struct XMLCreateChange: Sendable {
    public let parentID: XMLID? // nil means root
    public let index: XMLIndex
    public let factory: @Sendable (XMLCreateContext) -> XMLPartialSnapshot
    
    public init(parentID: XMLID?, index: XMLIndex, factory: @escaping @Sendable (XMLCreateContext) -> XMLPartialSnapshot) {
        self.parentID = parentID
        self.index = index
        self.factory = factory
    }
}

public struct XMLDestroyChange: Sendable {
    public let id: XMLID
    
    public init(id: XMLID) {
        self.id = id
    }
}

public struct XMLUpdateContentChange: Sendable {
    public let valueID: XMLID // can't be an element; only text, comment, whitespace, cdata
    public let content: String
    
    public init(valueID: XMLID, content: String) {
        self.valueID = valueID
        self.content = content
    }
}

public enum XMLUpsertQuery: Sendable {
    case name(String)
}

public struct XMLUpsertChange: Sendable {
    public let parentID: XMLID? // nil means root
    public let index: XMLIndex
    public let factory: @Sendable (XMLCreateContext) -> XMLPartialSnapshot
    public let existingElementQuery: XMLUpsertQuery
    public let changesFactory: @Sendable (XMLElement) -> [XMLChange]
    
    public init(
        parentID: XMLID?,
        index: XMLIndex,
        factory: @Sendable @escaping (XMLCreateContext) -> XMLPartialSnapshot,
        existingElementQuery: XMLUpsertQuery,
        changesFactory: @Sendable @escaping (XMLElement) -> [XMLChange]
    ) {
        self.parentID = parentID
        self.index = index
        self.factory = factory
        self.existingElementQuery = existingElementQuery
        self.changesFactory = changesFactory
    }
}

public struct XMLUpdateContext: Sendable {
    private let variables: [String: String]
    
    public init(variables: [String : String]) {
        self.variables = variables
    }
    
    var asXMLFormatContext: XMLFormatContext {
        XMLFormatContext(variables: variables)
    }
}

public struct XMLAttributeUpsertChange: Sendable {
    public let elementID: XMLID
    public let attributeName: String
    public let attributeValue: @Sendable (XMLUpdateContext) -> String
    
    public init(
        elementID: XMLID,
        attributeName: String,
        attributeValue: @escaping @Sendable (XMLUpdateContext) -> String
    ) {
        self.elementID = elementID
        self.attributeName = attributeName
        self.attributeValue = attributeValue
    }
}

public struct XMLAttributeDestroyChange: Sendable {
    public let elementID: XMLID
    public let attributeName: String

    public init(elementID: XMLID, attributeName: String) {
        self.elementID = elementID
        self.attributeName = attributeName
    }
}

public struct XMLReorderChange: Sendable {
    public let parentID: XMLID? // nil means root
    public let fromIndex: XMLIndex
    public let toIndex: XMLIndex

    public init(parentID: XMLID?, fromIndex: XMLIndex, toIndex: XMLIndex) {
        self.parentID = parentID
        self.fromIndex = fromIndex
        self.toIndex = toIndex
    }
}

public enum XMLChange: Sendable {
    case create(XMLCreateChange)
    case destroy(XMLDestroyChange)
    case update(XMLUpdateContentChange)
    case upsert(XMLUpsertChange)
    case upsertAttribute(XMLAttributeUpsertChange)
    case destroyAttribute(XMLAttributeDestroyChange)
    case reorder(XMLReorderChange)
}

public struct XMLCommand: Sendable {
    public let name: String
    public let changes: [XMLChange]
    
    public init(name: String, changes: [XMLChange]) {
        self.name = name
        self.changes = changes
    }
    
    public init<X: XMLUpdate>(_ name: String, @XMLUpdateBuilder changes: () -> X) {
        self.name = name
        self.changes = changes().changes(for: nil)
    }
}
