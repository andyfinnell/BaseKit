import Foundation
import XCTest
@testable import BaseKit

final class CursorTests: XCTestCase {
    private struct TestFilter: CursorFilter {
        typealias Element = Character
        
        private let skipSet = Set<Character>(["p", "_", "(", "\n"])
        
        func isIncluded(_ element: Character) -> Bool {
            !skipSet.contains(element)
        }
    }
    private let skipFilter = AnyCursorFilter(TestFilter())
    
    private let text = """
plus_one(number) ->
    number + 1

# This is a comment
my_func(arg1, arg2) ->
    plus_one(arg1)
    plus_one(arg2)

"""
    private lazy var source = Source(text: text, filename: "test.tn")

    func testElement() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = Cursor(source: source, index: source.endIndex)
        
        XCTAssertEqual(cursor1.element, "p")
        XCTAssertNil(cursor2.element)
    }
    
    func testAdvance() {
        let cursor1 = Cursor(source: source, index: source.startIndex).advance()
        let cursor2 = Cursor(source: source, index: source.endIndex).advance()
        
        XCTAssertEqual(cursor1.element, "l")
        XCTAssertTrue(cursor1 > Cursor(source: source, index: source.startIndex))
        XCTAssertNil(cursor2.element)
        XCTAssertEqual(cursor2, Cursor(source: source, index: source.endIndex))
    }
    
    func testRegress() {
        let cursor1 = Cursor(source: source, index: source.startIndex).regress()
        let cursor2 = Cursor(source: source, index: source.endIndex).regress()
        
        XCTAssertEqual(cursor1.element, "p")
        XCTAssertEqual(cursor1, Cursor(source: source, index: source.startIndex))
        XCTAssertEqual(cursor2.element, "\n")
        XCTAssertTrue(cursor2 < Cursor(source: source, index: source.endIndex))
    }
        
    func testMode() {
        let start = Cursor(source: source, index: source.startIndex)
        let end = Cursor(source: source, index: source.endIndex)
        
        let result = start.mode(skipFilter) { cursor1 in
            XCTAssertEqual(cursor1.element, "l")
            
            let cursor2 = cursor1.advance()
            XCTAssertEqual(cursor2.element, "u")

            let cursor3 = cursor2.advance()
            XCTAssertEqual(cursor3.element, "s")

            let cursor4 = cursor3.advance()
            XCTAssertEqual(cursor4.element, "o")

            let cursor5 = cursor4.regress()
            XCTAssertEqual(cursor5.element, "s")
            XCTAssertEqual(cursor5, cursor3)
            
            var c = cursor5
            while c.notEnd {
                c = c.advance()
            }
            XCTAssert(c.isEnd)
            XCTAssertEqual(c, end)
            
            return cursor2
        }
        
        let expected = (0..<2).reduce(start) { c, _ in c.advance() }
        XCTAssertEqual(result.element, "u")
        XCTAssertEqual(result, expected)
    }
    
    func testEquality() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = cursor1.advance()
        
        XCTAssertTrue(cursor1 == Cursor(source: source, index: source.startIndex))
        XCTAssertTrue(cursor1 != cursor2)
        XCTAssertFalse(cursor1 == cursor2)
    }
    
    func testComparison() {
        let start = Cursor(source: source, index: source.startIndex)
        let end = Cursor(source: source, index: source.endIndex)

        XCTAssert(start < end)
        let cursor1 = start
        let cursor2 = cursor1.advance()
        XCTAssertTrue(cursor1 < cursor2)
        XCTAssertTrue(cursor2 > cursor1)
    }

    func testIsStart() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = cursor1.advance()

        XCTAssertTrue(cursor1.isStart)
        XCTAssertFalse(cursor2.isStart)
    }
    
    func testNotStart() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = cursor1.advance()

        XCTAssertFalse(cursor1.notStart)
        XCTAssertTrue(cursor2.notStart)
    }

    func testIsEnd() {
        let cursor1 = Cursor(source: source, index: source.endIndex)
        let cursor2 = cursor1.regress()

        XCTAssertTrue(cursor1.isEnd)
        XCTAssertFalse(cursor2.isEnd)
    }

    func testNotEnd() {
        let cursor1 = Cursor(source: source, index: source.endIndex)
        let cursor2 = cursor1.regress()

        XCTAssertFalse(cursor1.notEnd)
        XCTAssertTrue(cursor2.notEnd)
    }

}
