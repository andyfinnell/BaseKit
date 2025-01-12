import Foundation

public extension XMLSnapshot {
    init(contentsOf fileURL: URL) async throws {
        let data = try await Data(asyncContentsOf: fileURL)
        try self.init(data: data)
    }
    
    init(text: String) throws {
        let data = Data(text.utf8)
        try self.init(data: data)
    }
    
    init(data: Data) throws {
        let parser = XMLParser(data: data)
        parser.shouldReportNamespacePrefixes = true
        
        let xmlData = XMLReaderData()
        parser.delegate = xmlData
        let success = parser.parse()
        if !success {
            throw XMLError.parsingError(parser.parserError)
        }
        
        self.init(roots: xmlData.roots, values: xmlData.values)
    }
}

private final class XMLReaderData: NSObject {
    private(set) var roots = [XMLID]()
    private(set) var values = [XMLID: XMLValue]()
    private var elementStack = [XMLElement]()
    
    func appendChild(_ value: XMLValue) {
        values[value.id] = value

        if let element = elementStack.last {
            elementStack.removeLast()
            let newElement = element.appendingChild(value.id)
            elementStack.append(newElement)
        } else {
            roots.append(value.id)
        }
    }
    
    var parentID: XMLID? {
        elementStack.last?.id
    }
}

extension XMLReaderData: XMLParserDelegate {
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String]
    ) {
        let element = XMLElement(
            id: XMLID(),
            parentID: parentID,
            name: XMLName(elementName),
            namespaceURI: namespaceURI,
            qualifiedName: qName,
            attributes: attributeDict.reduce(into: [XMLAttribute: String]()) { sum, pair in
                let (key, value) = pair
                sum[XMLAttribute(key)] = value
            },
            children: []
        )
        elementStack.append(element)
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard let element = elementStack.last else {
            return
        }
        elementStack.removeLast()
        appendChild(.element(element))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        appendChild(.text(XMLText(id: XMLID(), parentID: parentID, characters: string)))
    }

    func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
        appendChild(.ignorableWhitespace(XMLIgnorableWhitespace(id: XMLID(), parentID: parentID, text: whitespaceString)))
    }

    func parser(_ parser: XMLParser, foundComment comment: String) {
        appendChild(.comment(XMLComment(id: XMLID(), parentID: parentID, text: comment)))
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard let string = String(data: CDATABlock, encoding: .utf8) else {
            // TODO: how to set error; also how to figure out encoding
            return
        }
        appendChild(.cdata(XMLCData(id: XMLID(), parentID: parentID, data: string)))
    }
}
