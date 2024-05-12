import Foundation

public extension XMLSnapshot {
    func text() throws -> String {
        let writer = makeWriter()
        try writer.write()
        return writer.texts.joined(separator: "")
    }
    
    func data() throws -> Data {
        let allText = try text()
        return Data(allText.utf8)
    }
    
    func write(to fileURL: URL) async throws {
        let data = try data()
        try await data.asyncWrite(to: fileURL)
    }
}

private extension XMLSnapshot {
    func makeWriter() -> XMLDatabaseWriter {
        XMLDatabaseWriter(roots: roots, values: values)
    }
}

private final class XMLDatabaseWriter {
    private var roots: [XMLID]
    private var values: [XMLID: XMLValue]
    private(set) var texts = [String]()
    
    init(roots: [XMLID], values: [XMLID: XMLValue]) {
        self.roots = roots
        self.values = values
    }

    func write() throws {
        for root in roots {
            try write(root)
        }
    }
}

private extension XMLDatabaseWriter {
    func write(_ id: XMLID) throws {
        guard let value = values[id] else {
            throw XMLError.valueNotFound(id)
        }
        try write(value)
    }
    
    func write(_ value: XMLValue) throws {
        switch value {
        case let .element(element):
            try write(element)
        case let .text(text):
            try write(text)
        case let .cdata(cdata):
            try write(cdata)
        case let .comment(comment):
            try write(comment)
        case let .ignorableWhitespace(whitespace):
            try write(whitespace)
        }
    }
    
    func write(_ element: XMLElement) throws {
        write("<\(element.qualifiedName ?? element.name)")
        let attributeKeys = element.attributes.keys.sorted()
        for key in attributeKeys {
            guard let value = element.attributes[key] else {
                continue
            }
            write(" \(key)=\"")
            writeEncoded(value)
            write("\"")
        }
        
        if element.children.isEmpty {
            write(" />")
        } else {
            write(">")
                        
            for childID in element.children {
                try write(childID)
            }
            
            write("</\(element.qualifiedName ?? element.name)>")
        }
    }
    
    func write(_ text: XMLText) throws {
        writeEncoded(text.characters)
    }
    
    func write(_ cdata: XMLCData) throws {
        write("<![CDATA[")
        write(cdata.data)
        write("]]>")
    }
    
    func write(_ comment: XMLComment) throws {
        write("<!-- \(comment.text) -->")
    }
    
    func write(_ whitespace: XMLIgnorableWhitespace) throws {
        write(whitespace.text)
    }
    
    func writeEncoded(_ string: String) {
        write(string.encodeXMLEntities())
    }
    
    func write(_ string: String) {
        texts.append(string)
    }
}
