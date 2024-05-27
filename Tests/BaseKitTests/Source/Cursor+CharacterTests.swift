import Foundation
import XCTest
@testable import BaseKit

final class CursorCharacterTests: XCTestCase {
    private let text = """
plus_one(number) ->
    number + 1

# This is a comment
my_func(arg1, arg2) ->
    plus_one(arg1)
    plus_one(arg2)

"""
    private lazy var source = Source(text: text, filename: "test.tn")

    func testIsAtStartOfLine() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = cursor1.advance()
        let cursor3 = (0..<20).reduce(cursor1) { c, _ in c.advance() }
        let cursor4 = cursor3.advance()
        XCTAssertTrue(cursor1.isAtStartOfLine)
        XCTAssertFalse(cursor2.isAtStartOfLine)
        XCTAssertTrue(cursor3.isAtStartOfLine)
        XCTAssertFalse(cursor4.isAtStartOfLine)
    }
    
    func testIsNewLine() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = cursor1.advance()
        let cursor3 = (0..<19).reduce(cursor1) { c, _ in c.advance() }
        let cursor4 = cursor3.advance()
        XCTAssertFalse(cursor1.isNewline)
        XCTAssertFalse(cursor2.isNewline)
        XCTAssertTrue(cursor3.isNewline)
        XCTAssertFalse(cursor4.isNewline)
    }
    
    func testNotNewLine() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = cursor1.advance()
        let cursor3 = (0..<19).reduce(cursor1) { c, _ in c.advance() }
        let cursor4 = cursor3.advance()
        XCTAssertTrue(cursor1.notNewline)
        XCTAssertTrue(cursor2.notNewline)
        XCTAssertFalse(cursor3.notNewline)
        XCTAssertTrue(cursor4.notNewline)
    }
    
    func testIsWhitespace() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = (0..<16).reduce(cursor1) { c, _ in c.advance() }
        let cursor3 = (0..<19).reduce(cursor1) { c, _ in c.advance() }
        let cursor4 = cursor3.regress()
        XCTAssertFalse(cursor1.isWhitespace)
        XCTAssertTrue(cursor2.isWhitespace)
        XCTAssertTrue(cursor3.isWhitespace)
        XCTAssertFalse(cursor4.isWhitespace)
    }

    func testNotWhitespace() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = (0..<16).reduce(cursor1) { c, _ in c.advance() }
        let cursor3 = (0..<19).reduce(cursor1) { c, _ in c.advance() }
        let cursor4 = cursor3.regress()
        XCTAssertTrue(cursor1.notWhitespace)
        XCTAssertFalse(cursor2.notWhitespace)
        XCTAssertFalse(cursor3.notWhitespace)
        XCTAssertTrue(cursor4.notWhitespace)
    }

    func testNotIn() {
        let set = Set<Character>(["p"])
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = cursor1.advance()
        XCTAssertFalse(cursor1.not(in: set))
        XCTAssertTrue(cursor2.not(in: set))
    }
    
    func testIn() {
        let set = Set<Character>(["p"])
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = cursor1.advance()
        XCTAssertTrue(cursor1.in(set))
        XCTAssertFalse(cursor2.in(set))
    }
    
    func testScan() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        var output = ""
        let cursor2 = cursor1.scan(into: &output)
        XCTAssertEqual(output, "p")
        _ = cursor2.scan(into: &output)
        XCTAssertEqual(output, "pl")
    }

}
