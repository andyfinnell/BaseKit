import BaseKit
import Testing

struct InsertTextNodeTests {
    private func makeDatabase() throws -> (XMLDatabase, XMLID) {
        let svgString = """
            <svg xmlns="http://www.w3.org/2000/svg">
              <text x="10" y="30">Hello</text>
            </svg>
            """
        let database = try XMLDatabase(text: svgString)
        let rootID = database.rootValues.first!.id
        let textElement = database.childElements(for: database.element(byID: rootID)!).first!
        return (database, textElement.id)
    }

    @Test func insertsTextNodeAsLastChild() throws {
        let (database, textID) = try makeDatabase()

        let command = XMLCommand("insert text") {
            InsertTextNode(" World", into: textID)
        }
        _ = try database.perform(command)

        let children = database.childValues(for: database.element(byID: textID)!)
        let textNodes = children.compactMap { value -> String? in
            if case let .text(text) = value { return text.characters }
            return nil
        }
        #expect(textNodes.contains(" World"))
    }

    @Test func insertsOnlyOneNode() throws {
        let (database, textID) = try makeDatabase()

        let childCountBefore = database.element(byID: textID)!.children.count

        let command = XMLCommand("insert text") {
            InsertTextNode(" World", into: textID)
        }
        _ = try database.perform(command)

        let childCountAfter = database.element(byID: textID)!.children.count
        #expect(childCountAfter == childCountBefore + 1)
    }

    @Test func insertsAtSpecificIndex() throws {
        let (database, textID) = try makeDatabase()

        let command = XMLCommand("insert text") {
            InsertTextNode("Hey ", into: textID, at: .at(0))
        }
        _ = try database.perform(command)

        let children = database.childValues(for: database.element(byID: textID)!)
        guard case let .text(first) = children.first else {
            Issue.record("Expected text node at index 0")
            return
        }
        #expect(first.characters == "Hey ")
    }

    @Test func insertIsUndoable() throws {
        let (database, textID) = try makeDatabase()

        let childCountBefore = database.element(byID: textID)!.children.count

        let command = XMLCommand("insert text") {
            InsertTextNode(" World", into: textID)
        }
        let (undo, _) = try database.perform(command)
        _ = try database.perform(undo)

        let childCountAfter = database.element(byID: textID)!.children.count
        #expect(childCountAfter == childCountBefore)
    }

    @Test func noFormattingWhitespaceAdded() throws {
        let (database, textID) = try makeDatabase()

        let command = XMLCommand("insert text") {
            InsertTextNode("World", into: textID)
        }
        _ = try database.perform(command)

        // The last child should be exactly "World" — no whitespace prefix/suffix nodes
        let children = database.childValues(for: database.element(byID: textID)!)
        guard case let .text(last) = children.last else {
            Issue.record("Expected text node as last child")
            return
        }
        #expect(last.characters == "World")
    }
}
