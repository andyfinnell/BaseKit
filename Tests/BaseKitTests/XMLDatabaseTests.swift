import Foundation
import XCTest
import BaseKit
import TestKit

final class XMLDatabaseTests: XCTestCase {
    private var subject: XMLDatabase!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let svgString = """
            <svg version="1.1"
                 width="300" height="200"
                 xmlns="http://www.w3.org/2000/svg">
            
              <rect width="100%" height="100%" fill="red" />
            
              <circle cx="150" cy="100" r="80" fill="green" />
            
              <text x="150" y="125" font-size="60" text-anchor="middle" fill="white">SVG</text>
            
            </svg>
            """
        subject = try XMLDatabase(text: svgString)
    }
    
    func testReadWriteRoundTrip() throws {
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
    }
    
    func testCommitAddObject() throws {
        let rootID = subject.rootValues.first?.id
        let whitespace1ID = XMLID()
        let elementID = XMLID()
        let whitespace2ID = XMLID()
        
        let addRect = XMLCommand(
            name: "Add rect",
            changes: [
                .create(
                    XMLCreateChange(parentID: rootID,
                                    index: .last,
                                    factory: { _ in
                                        XMLPartialSnapshot(
                                            XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: whitespace1ID, parentID: rootID, text: "  ")),
                                            XMLValue.element(
                                                XMLElement(
                                                    id: elementID,
                                                    parentID: rootID,
                                                    name: "rect",
                                                    namespaceURI: nil,
                                                    qualifiedName: nil,
                                                    attributes: ["width": "50", "height": "25", "fill": "blue"],
                                                    children: []
                                                )
                                            ),
                                            XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: whitespace2ID, parentID: rootID, text: "\n\n"))
                                        )
                                    }
                                   )
                ),
            ]
        )
        let (_, changes) = try subject.perform(addRect)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            
              <rect fill="blue" height="25" width="50" />
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(rootID!),
            XMLDatabaseChange.value(whitespace1ID),
            XMLDatabaseChange.value(elementID),
            XMLDatabaseChange.value(whitespace2ID),
        ])
        XCTAssertEqual(changes, expectedIDs)
    }
    
    func testCommitUpsertElementWhenNotExisting() throws {
        let rootID = subject.rootValues.first?.id
        let whitespace1ID = XMLID()
        let elementID = XMLID()
        let whitespace2ID = XMLID()
        let colorWhitespace1ID = XMLID()
        let colorID = XMLID()
        let colorWhitespace2ID = XMLID()
        
        let addDefs = XMLCommand(
            name: "Add definitions",
            changes: [
                .upsert(
                    XMLUpsertChange(
                        parentID: rootID,
                        index: .at(0),
                        factory: { _ in
                            XMLPartialSnapshot(
                                XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: whitespace1ID, parentID: rootID, text: "\n  ")),
                                XMLValue.element(
                                    XMLElement(
                                        id: elementID,
                                        parentID: rootID,
                                        name: "defs",
                                        namespaceURI: nil,
                                        qualifiedName: nil,
                                        attributes: [:],
                                        children: []
                                    )
                                ),
                                XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: whitespace2ID, parentID: rootID, text: "\n"))
                            )
                        },
                        existingElementQuery: .name("defs"),
                        changesFactory: { defsElement in
                            return [
                                XMLChange.create(
                                    XMLCreateChange(
                                        parentID: defsElement.id,
                                        index: .last,
                                        factory: { _ in
                                            XMLPartialSnapshot(
                                                XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: colorWhitespace1ID, parentID: defsElement.id, text: "\n    ")),
                                                XMLValue.element(
                                                    XMLElement(
                                                        id: colorID,
                                                        parentID: defsElement.id,
                                                        name: "solidColor",
                                                        namespaceURI: nil,
                                                        qualifiedName: nil,
                                                        attributes: [
                                                            "solid-color": "#FFF",
                                                        ],
                                                        children: []
                                                    )
                                                ),
                                                XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: colorWhitespace2ID, parentID: defsElement.id, text: "\n  "))
                                            )
                                            
                                        })
                                )
                            ]
                        }
                    )
                ),
            ]
        )
        let (_, changes) = try subject.perform(addDefs)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <solidColor solid-color="#FFF" />
              </defs>
            
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(rootID!),
            XMLDatabaseChange.value(whitespace1ID),
            XMLDatabaseChange.value(elementID),
            XMLDatabaseChange.value(whitespace2ID),
            XMLDatabaseChange.value(colorWhitespace1ID),
            XMLDatabaseChange.value(colorID),
            XMLDatabaseChange.value(colorWhitespace2ID),
            
        ])
        XCTAssertEqual(changes, expectedIDs)
    }
    
    func testCommitUpsertElementWhenExisting() throws {
        let svgString = """
            <svg version="1.1"
                 width="300" height="200"
                 xmlns="http://www.w3.org/2000/svg">
            
              <defs>
              </defs>
            
              <rect width="100%" height="100%" fill="red" />
            
              <circle cx="150" cy="100" r="80" fill="green" />
            
              <text x="150" y="125" font-size="60" text-anchor="middle" fill="white">SVG</text>
            
            </svg>
            """
        subject = try XMLDatabase(text: svgString)

        let rootID = subject.rootValues.first?.id
        let defsID = subject[.element("svg").element("defs")]!.id
        let whitespace1ID = XMLID()
        let elementID = XMLID()
        let whitespace2ID = XMLID()
        let colorWhitespace1ID = XMLID()
        let colorID = XMLID()
        let colorWhitespace2ID = XMLID()
        
        let addDefs = XMLCommand(
            name: "Add definitions",
            changes: [
                .upsert(
                    XMLUpsertChange(
                        parentID: rootID,
                        index: .at(0),
                        factory: { _ in
                            XMLPartialSnapshot(
                                XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: whitespace1ID, parentID: rootID, text: "\n  ")),
                                XMLValue.element(
                                    XMLElement(
                                        id: elementID,
                                        parentID: rootID,
                                        name: "defs",
                                        namespaceURI: nil,
                                        qualifiedName: nil,
                                        attributes: [:],
                                        children: []
                                    )
                                ),
                                XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: whitespace2ID, parentID: rootID, text: "\n"))
                            )
                        },
                        existingElementQuery: .name("defs"),
                        changesFactory: { defsElement in
                            return [
                                XMLChange.create(
                                    XMLCreateChange(
                                        parentID: defsElement.id,
                                        index: .last,
                                        factory: { _ in
                                            XMLPartialSnapshot(
                                                XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: colorWhitespace1ID, parentID: defsElement.id, text: "  ")),
                                                XMLValue.element(
                                                    XMLElement(
                                                        id: colorID,
                                                        parentID: defsElement.id,
                                                        name: "solidColor",
                                                        namespaceURI: nil,
                                                        qualifiedName: nil,
                                                        attributes: [
                                                            "solid-color": "#FFF",
                                                        ],
                                                        children: []
                                                    )
                                                ),
                                                XMLValue.ignorableWhitespace(XMLIgnorableWhitespace(id: colorWhitespace2ID, parentID: defsElement.id, text: "\n  "))
                                            )
                                            
                                        })
                                )
                            ]
                        }
                    )
                ),
            ]
        )
        let (_, changes) = try subject.perform(addDefs)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <defs>
                <solidColor solid-color="#FFF" />
              </defs>
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(defsID),
            XMLDatabaseChange.value(colorWhitespace1ID),
            XMLDatabaseChange.value(colorID),
            XMLDatabaseChange.value(colorWhitespace2ID),
            
        ])
        XCTAssertEqual(changes, expectedIDs)
    }

    func testCommitDestroyObject() throws {
        let rootID = subject.rootValues.first?.id
        let text = subject[XMLPath.element("svg").element("text")]
        let textText = subject[XMLPath.element("svg").element("text").text()]
        
        let deleteText = XMLCommand(
            name: "Delete rect",
            changes: [
                .destroy(XMLDestroyChange(id: text!.id))
            ]
        )
        let (_, changes) = try subject.perform(deleteText)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(rootID!),
            XMLDatabaseChange.value(text!.id),
            XMLDatabaseChange.value(textText!.id),
        ])
        XCTAssertEqual(changes, expectedIDs)
    }
    
    func testCommitUpdateContentText() throws {
        let textText = subject[XMLPath.element("svg").element("text").text()]
        let updateText = XMLCommand(
            name: "Update text",
            changes: [
                .update(XMLUpdateContentChange(valueID: textText!.id, content: "Hello world!"))
            ]
        )
        let (_, changes) = try subject.perform(updateText)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">Hello world!</text>
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(textText!.id),
        ])
        XCTAssertEqual(changes, expectedIDs)
    }
    
    func testCommitAttributeInsert() throws {
        let circle = subject[XMLPath.element("svg").element("circle")]
        let updateCircle = XMLCommand(
            name: "Update position",
            changes: [
                .upsertAttribute(XMLAttributeUpsertChange(elementID: circle!.id, attributeName: "x", attributeValue: { _ in "25" })),
                .upsertAttribute(XMLAttributeUpsertChange(elementID: circle!.id, attributeName: "y", attributeValue: { _ in "15" })),
            ]
        )
        let (_, changes) = try subject.perform(updateCircle)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" x="25" y="15" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(circle!.id),
        ])
        XCTAssertEqual(changes, expectedIDs)
    }
    
    func testCommitAttributeUpdate() throws {
        let text = subject[XMLPath.element("svg").element("text")]
        let updateText = XMLCommand(
            name: "Update font size",
            changes: [
                .upsertAttribute(XMLAttributeUpsertChange(elementID: text!.id, attributeName: "font-size", attributeValue: { _ in "72" }))
            ]
        )
        let (_, changes) = try subject.perform(updateText)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="72" text-anchor="middle" x="150" y="125">SVG</text>
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(text!.id),
        ])
        XCTAssertEqual(changes, expectedIDs)
    }
    
    func testCommitAttributeRemove() throws {
        let text = subject[XMLPath.element("svg").element("text")]
        let updateText = XMLCommand(
            name: "Remove text anchor",
            changes: [
                .destroyAttribute(XMLAttributeDestroyChange(elementID: text!.id, attributeName: "text-anchor"))
            ]
        )
        let (_, changes) = try subject.perform(updateText)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="60" x="150" y="125">SVG</text>
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(text!.id),
        ])
        XCTAssertEqual(changes, expectedIDs)
    }
    
    func testCommitReorder() throws {
        let svg = subject[XMLPath.element("svg")]
        let updateText = XMLCommand(
            name: "Reorder elements",
            changes: [
                .reorder(XMLReorderChange(parentID: svg?.id, fromIndex: .at(5), toIndex: .at(3))),
                .reorder(XMLReorderChange(parentID: svg?.id, fromIndex: .at(5), toIndex: .at(4))),
            ]
        )
        let (_, changes) = try subject.perform(updateText)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
        
        let expectedIDs = Set([
            XMLDatabaseChange.value(svg!.id),
        ])
        XCTAssertEqual(changes, expectedIDs)
    }
    
    func testUndo() throws {
        let text = subject[XMLPath.element("svg").element("text")]
        
        let deleteText = XMLCommand(
            name: "Delete rect",
            changes: [
                .destroy(XMLDestroyChange(id: text!.id))
            ]
        )
        let (undoCommand, _) = try subject.perform(deleteText)
        
        _ = try subject.perform(undoCommand)
        
        let output = try subject.text()
        
        let expected = """
            <svg height="200" version="1.1" width="300" xmlns="http://www.w3.org/2000/svg">
            
              <rect fill="red" height="100%" width="100%" />
            
              <circle cx="150" cy="100" fill="green" r="80" />
            
              <text fill="white" font-size="60" text-anchor="middle" x="150" y="125">SVG</text>
            
            </svg>
            """
        
        XCTAssertEqual(output, expected)
    }
    
    func testSubscript() throws {
        assertElement(subject[XMLPath.element("svg")], withName: "svg")
        assertText(subject[XMLPath.element("svg").text(at: 1)], withContent: "\n\n  ")
        XCTAssertNil(subject[XMLPath.element("svg").whitespace()])
    }
    
    private func assertElement(_ value: XMLValue?, withName name: String, file: StaticString = #filePath, line: UInt = #line) {
        guard case let .element(element) = value else {
            XCTFail("Expected \(String(describing: value)) to be an element with name \(name)", file: file, line: line)
            return
        }
        XCTAssertEqual(element.name, name, "Expected \(element) to hae name \(name)", file: file, line: line)
    }
    
    private func assertText(_ value: XMLValue?, withContent content: String, file: StaticString = #filePath, line: UInt = #line) {
        guard case let .text(text) = value else {
            XCTFail("Expected \(String(describing: value)) to be text with content \(content)", file: file, line: line)
            return
        }
        XCTAssertEqual(text.characters, content, "Expected \(text) to have content \(content)", file: file, line: line)
    }
}
