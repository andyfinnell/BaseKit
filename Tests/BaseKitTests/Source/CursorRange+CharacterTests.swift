import Foundation
import XCTest
@testable import BaseKit

final class CursorRangeCharacterTests: XCTestCase {
    private let text = """
plus_one(number) ->
    number + 1

# This is a comment
my_func(arg1, arg2) ->
    plus_one(arg1)
    plus_one(arg2)

"""
    private lazy var source = Source(text: text, filename: "test.tn")

    func testString() {
        let rangeAll = CursorRange(start: Cursor(source: source, index: source.startIndex),
                                   end: Cursor(source: source, index: source.endIndex))
        XCTAssertEqual(rangeAll.string, text)
        
        let start = Cursor(source: source, index: source.startIndex)
        let stop = (0..<8).reduce(start) { c, _ in c.advance() }
        let rangeBeginning = CursorRange(start: start, end: stop)
        XCTAssertEqual(rangeBeginning.string, "plus_one")
    }
}
