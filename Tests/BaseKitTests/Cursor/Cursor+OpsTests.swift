import Foundation
import XCTest
@testable import BaseKit

final class CursorOpsTests: XCTestCase {
    private let text = """
plus_one(number) ->
    number + 1

# This is a comment
my_func(arg1, arg2) ->
    plus_one(arg1)
    plus_one(arg2)

"""
    private lazy var source = Source(text: text, filename: "test.tn")

    func testEqualElement() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = Cursor(source: source, index: source.endIndex)
        XCTAssertTrue(cursor1 == "p")
        XCTAssertFalse(cursor2 == "p")
    }
    
    func testNotEqualElement() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = Cursor(source: source, index: source.endIndex)
        XCTAssertTrue(cursor1 != "l")
        XCTAssertTrue(cursor2 != "l")
    }

    func testMatchingElement() {
        let cursor1 = Cursor(source: source, index: source.startIndex)
        let cursor2 = Cursor(source: source, index: source.endIndex)
        switch cursor1 {
        case "p":
            XCTAssertTrue(cursor1 == "p")
        case "l":
            XCTFail("expected to get a p")
        default:
            XCTFail("expected to get a p")
        }
        
        switch cursor2 {
        case "p":
            XCTFail("expected to get no match")
        case "\n":
            XCTFail("expected to get no match")
        default:
            XCTAssertNil(cursor2.element)
        }
    }
}
