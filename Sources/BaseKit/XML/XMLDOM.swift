import Foundation

public enum XMLIDType {}
public typealias XMLID = Identifier<UUID, XMLIDType>

public struct XMLElement: Hashable, Identifiable, Sendable {
    public let id: XMLID
    public let parentID: XMLID?
    public let name: XMLName
    public let namespaceURI: String?
    public let qualifiedName: String?
    public let attributes: [XMLAttribute: String]
    public let children: [XMLID]
    
    public init(
        id: XMLID,
        parentID: XMLID?,
        name: XMLName,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes: [XMLAttribute : String],
        children: [XMLID]
    ) {
        self.id = id
        self.parentID = parentID
        self.name = name
        self.namespaceURI = namespaceURI
        self.qualifiedName = qualifiedName
        self.attributes = attributes
        self.children = children
    }
    
    func appendingChild(_ childID: XMLID) -> XMLElement {
        XMLElement(
            id: id,
            parentID: parentID,
            name: name,
            namespaceURI: namespaceURI,
            qualifiedName: qualifiedName,
            attributes: attributes,
            children: children + [childID]
        )
    }
    
    func reorderChild(from index1: XMLIndex, to index2: XMLIndex) -> XMLElement {
        var reorderedChildren = children
        reorderedChildren.reorder(from: index1, to: index2)
        return XMLElement(
            id: id,
            parentID: parentID,
            name: name,
            namespaceURI: namespaceURI,
            qualifiedName: qualifiedName,
            attributes: attributes,
            children: reorderedChildren
        )
    }
    
    func insertChildren(contentsOf childIDs: [XMLID], at index: XMLIndex) -> XMLElement {
        var updatedChildren = children
        updatedChildren.insert(contentsOf: childIDs, at: index)
        return XMLElement(
            id: id,
            parentID: parentID,
            name: name,
            namespaceURI: namespaceURI,
            qualifiedName: qualifiedName,
            attributes: attributes,
            children: updatedChildren
        )
    }
    
    func removeChild(_ childID: XMLID) throws -> (XMLElement, XMLIndex) {
        var updatedChildren = children
        let removedIndex = try updatedChildren.remove(where: { $0 == childID })
        let updatedElement = XMLElement(
            id: id,
            parentID: parentID,
            name: name,
            namespaceURI: namespaceURI,
            qualifiedName: qualifiedName,
            attributes: attributes,
            children: updatedChildren
        )
        return (updatedElement, .at(removedIndex))
    }
    
    func attribute(for name: XMLAttribute) -> String? {
        attributes[name]
    }
    
    func updateAttribute(_ value: String, for attributeName: XMLAttribute) -> XMLElement {
        var changedAttributes = attributes
        changedAttributes[attributeName] = value
        return XMLElement(
            id: id,
            parentID: parentID,
            name: name,
            namespaceURI: namespaceURI,
            qualifiedName: qualifiedName,
            attributes: changedAttributes,
            children: children
        )
    }
    
    func removeAttribute(for attributeName: XMLAttribute) -> XMLElement {
        var changedAttributes = attributes
        changedAttributes.removeValue(forKey: attributeName)
        return XMLElement(
            id: id,
            parentID: parentID,
            name: name,
            namespaceURI: namespaceURI,
            qualifiedName: qualifiedName,
            attributes: changedAttributes,
            children: children
        )
    }
}

public struct XMLText: Hashable, Identifiable, Sendable {
    public let id: XMLID
    public let parentID: XMLID?
    public let characters: String
    
    public init(id: XMLID, parentID: XMLID?, characters: String) {
        self.id = id
        self.parentID = parentID
        self.characters = characters
    }
    
    func updateContent(_ content: String) -> XMLText {
        XMLText(id: id, parentID: parentID, characters: content)
    }
}

public struct XMLCData: Hashable, Identifiable, Sendable {
    public let id: XMLID
    public let parentID: XMLID?
    public let data: String
    
    public init(id: XMLID, parentID: XMLID?, data: String) {
        self.id = id
        self.parentID = parentID
        self.data = data
    }
    
    func updateContent(_ content: String) -> XMLCData {
        XMLCData(id: id, parentID: parentID, data: content)
    }
}

public struct XMLComment: Hashable, Identifiable, Sendable {
    public let id: XMLID
    public let parentID: XMLID?
    public let text: String
    
    public init(id: XMLID, parentID: XMLID?, text: String) {
        self.id = id
        self.parentID = parentID
        self.text = text
    }
    
    func updateContent(_ content: String) -> XMLComment {
        XMLComment(id: id, parentID: parentID, text: content)
    }
}

public struct XMLIgnorableWhitespace: Hashable, Identifiable, Sendable {
    public let id: XMLID
    public let parentID: XMLID?
    public let text: String
    
    public init(id: XMLID, parentID: XMLID?, text: String) {
        self.id = id
        self.parentID = parentID
        self.text = text
    }
    
    func updateContent(_ content: String) -> XMLIgnorableWhitespace {
        XMLIgnorableWhitespace(id: id, parentID: parentID, text: content)
    }
}

public enum XMLValue: Hashable, Identifiable, Sendable {
    case element(XMLElement)
    case text(XMLText)
    case cdata(XMLCData)
    case comment(XMLComment)
    case ignorableWhitespace(XMLIgnorableWhitespace)
    
    public var id: XMLID {
        switch self {
        case let .element(element): return element.id
        case let .text(text): return text.id
        case let .cdata(cdata): return cdata.id
        case let .comment(comment): return comment.id
        case let .ignorableWhitespace(whitespace): return whitespace.id
        }
    }
    
    public var parentID: XMLID? {
        switch self {
        case let .element(element): return element.parentID
        case let .text(text): return text.parentID
        case let .cdata(cdata): return cdata.parentID
        case let .comment(comment): return comment.parentID
        case let .ignorableWhitespace(whitespace): return whitespace.parentID
        }
    }
    
    func content() throws -> String {
        switch self {
        case .element:
            throw XMLError.invalidElement
        case let .text(text):
            return text.characters
        case let .cdata(cdata):
            return cdata.data
        case let .comment(comment):
            return comment.text
        case let .ignorableWhitespace(whitespace):
            return whitespace.text
        }
    }
    
    func updateContent(_ content: String) throws -> XMLValue {
        switch self {
        case .element:
            throw XMLError.invalidElement
        case let .text(text):
            return .text(text.updateContent(content))
        case let .cdata(cdata):
            return .cdata(cdata.updateContent(content))
        case let .comment(comment):
            return .comment(comment.updateContent(content))
        case let .ignorableWhitespace(whitespace):
            return .ignorableWhitespace(whitespace.updateContent(content))
        }
    }
    
    var children: [XMLID] {
        switch self {
        case let .element(element):
            return element.children
        case .text, .cdata, .comment, .ignorableWhitespace:
            return []
        }
    }

    func reorderChild(from index1: XMLIndex, to index2: XMLIndex) throws -> XMLValue {
        switch self {
        case let .element(element):
            return .element(element.reorderChild(from: index1, to: index2))
        case .text, .cdata, .comment, .ignorableWhitespace:
            throw XMLError.notAnElement
        }
    }
    
    func insertChildren(contentsOf childIDs: [XMLID], at index: XMLIndex) throws -> XMLValue {
        switch self {
        case let .element(element):
            return .element(element.insertChildren(contentsOf: childIDs, at: index))
        case .text, .cdata, .comment, .ignorableWhitespace:
            throw XMLError.notAnElement
        }
    }
    
    func removeChild(_ childID: XMLID) throws -> (XMLValue, XMLIndex) {
        switch self {
        case let .element(element):
            let (updatedElement, removedIndex) = try element.removeChild(childID)
            return (.element(updatedElement), removedIndex)
        case .text, .cdata, .comment, .ignorableWhitespace:
            throw XMLError.notAnElement
        }
    }
    
    func attribute(for name: XMLAttribute) throws -> String? {
        switch self {
        case let .element(element):
            return element.attribute(for: name)
        case .text, .cdata, .comment, .ignorableWhitespace:
            throw XMLError.notAnElement
        }
    }
    
    func updateAttribute(_ value: String, for attributeName: XMLAttribute) throws -> XMLValue {
        switch self {
        case let .element(element):
            return .element(element.updateAttribute(value, for: attributeName))
        case .text, .cdata, .comment, .ignorableWhitespace:
            throw XMLError.notAnElement
        }
    }
    
    func removeAttribute(for attributeName: XMLAttribute) throws -> XMLValue {
        switch self {
        case let .element(element):
            return .element(element.removeAttribute(for: attributeName))
        case .text, .cdata, .comment, .ignorableWhitespace:
            throw XMLError.notAnElement
        }
    }
    
}
