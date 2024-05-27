import Foundation
import XCTest
@testable import BaseKit

final class CursorLookaheadTests: XCTestCase {
    private let text = """
plus_one(number) ->
    number + 1

# This is a comment
my_func(arg1, arg2) ->
    plus_one(arg1)
    plus_one(arg2)

"""
    private lazy var source = Source(text: text, filename: "test.tn")

    func testPrefix() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        XCTAssertEqual(cursor1.prefix(8), "plus_one")
        
        let cursorEnd = Cursor(source: source, index: source.endIndex)
        let cursor2 = (0..<4).reduce(cursorEnd) { c, _ in c.regress() }
        XCTAssertEqual(cursor2.prefix(8), "g2)\n")
    }
    
    func testHasPrefix() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        XCTAssertTrue(cursor1.hasPrefix("plus_one"))
        XCTAssertFalse(cursor1.hasPrefix("frank"))

        let cursorEnd = Cursor(source: source, index: source.endIndex)
        let cursor2 = (0..<4).reduce(cursorEnd) { c, _ in c.regress() }
        XCTAssertTrue(cursor2.hasPrefix("g2)\n"))
        XCTAssertFalse(cursor2.hasPrefix("g2)\nfrank"))
    }

}
