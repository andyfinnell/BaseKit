import Foundation
@testable import BaseKit
import Testing

struct XMLEntityEncodingTests {

    // MARK: - encodeXMLEntities

    @Test
    func encodesAmpersand() {
        #expect("a&b".encodeXMLEntities() == "a&amp;b")
    }

    @Test
    func encodesLessThan() {
        #expect("a<b".encodeXMLEntities() == "a&lt;b")
    }

    @Test
    func encodesGreaterThan() {
        #expect("a>b".encodeXMLEntities() == "a&gt;b")
    }

    @Test
    func encodesDoubleQuote() {
        #expect("a\"b".encodeXMLEntities() == "a&quot;b")
    }

    @Test
    func doesNotEncodeSingleQuote() {
        #expect("it's".encodeXMLEntities() == "it's")
    }

    @Test
    func plainTextUnchanged() {
        #expect("hello world".encodeXMLEntities() == "hello world")
    }

    @Test
    func encodesMultipleEntitiesInOneString() {
        #expect("a&b<c>d\"e".encodeXMLEntities() == "a&amp;b&lt;c&gt;d&quot;e")
    }

    @Test
    func emptyStringUnchanged() {
        #expect("".encodeXMLEntities() == "")
    }

    // MARK: - Round-trip: write → parse

    @Test
    func attributeWithSingleQuoteRoundTrips() throws {
        let snapshot = makeSnapshot {
            Element(.rect) {
                Attr(XMLAttribute("font-family"), "'Avenir Next'")
            }
        }
        let xml = try snapshot.text()

        #expect(xml.contains("font-family=\"'Avenir Next'\""))

        let parsed = try XMLSnapshot(text: xml)
        let element = try #require(findElement(named: .rect, in: parsed))
        #expect(element.attributes[XMLAttribute("font-family")] == "'Avenir Next'")
    }

    @Test
    func attributeWithAmpersandRoundTrips() throws {
        let snapshot = makeSnapshot {
            Element(.rect) {
                Attr(XMLAttribute("title"), "A&B")
            }
        }
        let xml = try snapshot.text()

        #expect(xml.contains("title=\"A&amp;B\""))

        let parsed = try XMLSnapshot(text: xml)
        let element = try #require(findElement(named: .rect, in: parsed))
        #expect(element.attributes[XMLAttribute("title")] == "A&B")
    }

    @Test
    func attributeWithDoubleQuoteRoundTrips() throws {
        let snapshot = makeSnapshot {
            Element(.rect) {
                Attr(.id, "say\"hello")
            }
        }
        let xml = try snapshot.text()

        #expect(xml.contains("id=\"say&quot;hello\""))

        let parsed = try XMLSnapshot(text: xml)
        let element = try #require(findElement(named: .rect, in: parsed))
        #expect(element.attributes[.id] == "say\"hello")
    }

    @Test
    func attributeWithAngleBracketsRoundTrips() throws {
        let snapshot = makeSnapshot {
            Element(.rect) {
                Attr(XMLAttribute("title"), "a<b>c")
            }
        }
        let xml = try snapshot.text()

        #expect(xml.contains("title=\"a&lt;b&gt;c\""))

        let parsed = try XMLSnapshot(text: xml)
        let element = try #require(findElement(named: .rect, in: parsed))
        #expect(element.attributes[XMLAttribute("title")] == "a<b>c")
    }

    @Test
    func textContentWithSingleQuoteRoundTrips() throws {
        let snapshot = makeSnapshot {
            Element(.text) {
                Text("it's monty python's flying circus")
            }
        }
        let xml = try snapshot.text()

        #expect(xml.contains("it's monty python's flying circus"))

        let parsed = try XMLSnapshot(text: xml)
        let content = try #require(textContent(of: .text, in: parsed))
        #expect(content == "it's monty python's flying circus")
    }

    @Test
    func textContentWithAmpersandRoundTrips() throws {
        let snapshot = makeSnapshot {
            Element(.text) {
                Text("Tom & Jerry")
            }
        }
        let xml = try snapshot.text()

        #expect(xml.contains("Tom &amp; Jerry"))

        let parsed = try XMLSnapshot(text: xml)
        let content = try #require(textContent(of: .text, in: parsed))
        #expect(content == "Tom & Jerry")
    }

    @Test
    func textContentWithAngleBracketsRoundTrips() throws {
        let snapshot = makeSnapshot {
            Element(.text) {
                Text("a < b > c")
            }
        }
        let xml = try snapshot.text()

        #expect(xml.contains("a &lt; b &gt; c"))

        let parsed = try XMLSnapshot(text: xml)
        let content = try #require(textContent(of: .text, in: parsed))
        #expect(content == "a < b > c")
    }
}

private extension XMLEntityEncodingTests {
    func makeSnapshot(@XMLSnapshotBuilder content: () -> some XML) -> XMLSnapshot {
        let partial = XMLPartialSnapshot(
            parentID: nil,
            createContext: XMLCreateContext(indent: 0, isFirst: false, isLast: false, variables: [:]),
            builder: content
        )
        return XMLSnapshot(roots: partial.roots, values: partial.values)
    }

    func findElement(named name: XMLName, in snapshot: XMLSnapshot) -> BaseKit.XMLElement? {
        snapshot.values.values.compactMap { value -> BaseKit.XMLElement? in
            if case let .element(e) = value, e.name == name { return e }
            return nil
        }.first
    }

    func textContent(of elementName: XMLName, in snapshot: XMLSnapshot) -> String? {
        guard let element = findElement(named: elementName, in: snapshot) else {
            return nil
        }
        return element.children.compactMap { childID -> String? in
            guard let value = snapshot.values[childID],
                  case let .text(t) = value else { return nil }
            return t.characters
        }.joined()
    }
}
