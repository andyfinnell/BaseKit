import Foundation
import XCTest
@testable import BaseKit

final class CursorRangeTests: XCTestCase {
    private let text = """
plus_one(number) ->
    number + 1

# This is a comment
my_func(arg1, arg2) ->
    plus_one(arg1)
    plus_one(arg2)

"""
    private lazy var source = Source(text: text, filename: "test.tn")
    private lazy var subject: CursorRange<Source> = {
        let start = Cursor(source: source, index: source.startIndex)
        let stop = (0..<35).reduce(start) { c, _ in c.advance() }
        return CursorRange(start: start, end: stop)
    }()
    
    func testIndexEquality() {
        let index1 = subject.startIndex
        let index2 = subject.index(after: index1)
        
        XCTAssertTrue(index1 == subject.startIndex)
        XCTAssertTrue(index1 != index2)
        XCTAssertFalse(index1 == index2)
    }
    
    func testIndexComparison() {
        XCTAssert(subject.startIndex < subject.endIndex)
        let index1 = subject.startIndex
        let index2 = subject.index(after: index1)
        XCTAssertTrue(index1 < index2)
        XCTAssertTrue(index2 > index1)
    }
    
    func testIndexAfter() {
        let index1 = subject.startIndex
        let index2 = subject.index(after: index1)

        XCTAssert(index1.index < index2.index)
        XCTAssertEqual(index2.line, 1)
        XCTAssertEqual(index2.column, 2)
    }
    
    func testIndexBefore() {
        let index1 = subject.endIndex
        let index2 = subject.index(before: index1)!

        XCTAssert(index1.index > index2.index)
        XCTAssertEqual(index2.line, 2)
        XCTAssertEqual(index2.column, 15)
        
        XCTAssertEqual(index1.line, 3)
        XCTAssertEqual(index1.column, 1)
    }
    
    func testSubscript() {
        let index1 = subject.startIndex
        let index2 = subject.index(after: index1)
        let index3 = subject.index(before: subject.endIndex)!
        let index4 = subject.index(before: index3)!

        XCTAssertEqual(subject[index1], "p")
        XCTAssertEqual(subject[index2], "l")
        XCTAssertEqual(subject[index3], "\n")
        XCTAssertEqual(subject[index4], "1")
    }
    
    func testIteration() {
        var current = subject.startIndex
        var forwardIndices = [Source.Index]()
        while current < subject.endIndex {
            forwardIndices.append(current)
            current = subject.index(after: current)
        }
        
        var backwardIndices = [Source.Index]()
        var next = subject.index(before: subject.endIndex)
        while let i = next {
            backwardIndices.append(i)
            next = subject.index(before: i)
        }

        XCTAssertEqual(forwardIndices, backwardIndices.reversed())
        XCTAssertEqual(forwardIndices.count, 35)
    }

}
