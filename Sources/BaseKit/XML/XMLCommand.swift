import Foundation

public enum XMLIndex: Hashable {
    case last
    case at(Int)
}

public struct XMLCreateChange {
    public let parentID: XMLID? // nil means root
    public let index: XMLIndex
    public let factory: () -> XMLSnapshot
    
    public init(parentID: XMLID?, index: XMLIndex, factory: @escaping () -> XMLSnapshot) {
        self.parentID = parentID
        self.index = index
        self.factory = factory
    }
}

public struct XMLDestroyChange {
    public let id: XMLID
    
    public init(id: XMLID) {
        self.id = id
    }
}

public struct XMLUpdateContentChange {
    public let valueID: XMLID // can't be an element; only text, comment, whitespace, cdata
    public let content: String
    
    public init(valueID: XMLID, content: String) {
        self.valueID = valueID
        self.content = content
    }
}

public struct XMLAttributeUpsertChange {
    public let elementID: XMLID
    public let attributeName: String
    public let attributeValue: String
    
    public init(elementID: XMLID, attributeName: String, attributeValue: String) {
        self.elementID = elementID
        self.attributeName = attributeName
        self.attributeValue = attributeValue
    }
}

public struct XMLAttributeDestroyChange {
    public let elementID: XMLID
    public let attributeName: String

    
    public init(elementID: XMLID, attributeName: String) {
        self.elementID = elementID
        self.attributeName = attributeName
    }
}

public struct XMLReorderChange {
    public let parentID: XMLID? // nil means root
    public let fromIndex: XMLIndex
    public let toIndex: XMLIndex

    public init(parentID: XMLID?, fromIndex: XMLIndex, toIndex: XMLIndex) {
        self.parentID = parentID
        self.fromIndex = fromIndex
        self.toIndex = toIndex
    }
}

public enum XMLChange {
    case create(XMLCreateChange)
    case destroy(XMLDestroyChange)
    case update(XMLUpdateContentChange)
    case upsertAttribute(XMLAttributeUpsertChange)
    case destroyAttribute(XMLAttributeDestroyChange)
    case reorder(XMLReorderChange)
}

public struct XMLCommand {
    public let name: String
    public let changes: [XMLChange]
    
    public init(name: String, changes: [XMLChange]) {
        self.name = name
        self.changes = changes
    }
}
