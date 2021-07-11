import Foundation
import XCTest
import BaseKit

final class StringTests: XCTestCase {
    func testLeftPaddingWhereNoop() {
        let subject = "abcdefgh"
       
        XCTAssertEqual(subject.leftPadding(toLength: 4, withPad: "##"), "abcdefgh")
    }

    func testLeftPaddingWherePaddingIsMultipleOfFillSpace() {
        let subject = "AA"
        
        XCTAssertEqual(subject.leftPadding(toLength: 8, withPad: "BB"), "BBBBBBAA")
    }

    func testLeftPaddingWherePaddingIsNotAMultipleOfFillSpace() {
        let subject = "AAA"
        
        XCTAssertEqual(subject.leftPadding(toLength: 8, withPad: "BC"), "BCBCBAAA")
    }
    
    func testExtendLeftWhenAtEnd() {
        let subject = "123abc"
        let endIndex = subject.index(before: subject.endIndex)
        let index = subject.extendLeft(endIndex, while: { $0.isLetter })
        let expectedIndex = subject.index(subject.startIndex, offsetBy: 3)
        
        XCTAssertEqual(index, expectedIndex)
        XCTAssertEqual(subject[index], "a")
    }
    
    func testExtendLeftWhenAtStart() {
        let subject = "abcdefg"
        let index = subject.extendLeft(subject.startIndex, while: { $0.isLetter })
        
        XCTAssertEqual(index, subject.startIndex)
    }
    
    func testExtendRightWhenAtEnd() {
        let subject = "123abc"
        let endIndex = subject.index(before: subject.endIndex)
        let index = subject.extendRight(endIndex, while: { $0.isLetter })
        
        XCTAssertEqual(index, endIndex)
        XCTAssertEqual(subject[index], "c")
    }
    
    func testExtendRightWhenAtStart() {
        let subject = "abc123"
        let index = subject.extendRight(subject.startIndex, while: { $0.isLetter })
        let expectedIndex = subject.index(subject.startIndex, offsetBy: 2)

        XCTAssertEqual(index, expectedIndex)
        XCTAssertEqual(subject[index], "c")
    }

    func testTrimSuffixWhenExists() {
        XCTAssertEqual("abcdef".trimSuffix("def"), "abc")
    }
    
    func testTrimSuffixWhenDoesNotExist() {
        XCTAssertEqual("abcdefg".trimSuffix("def"), "abcdefg")
    }
    
    func testTrimSuffixWhenItIsEntireString() {
        XCTAssertEqual("def".trimSuffix("def"), "")
    }
    
    func testCamelCaseWhenSnakecase() {
        XCTAssertEqual("jim_bob_button".camelCase(), "JimBobButton")
    }
    
    func testLowerCamelCaseWhenSnakecase() {
        XCTAssertEqual("Jim_bob_button".lowerCamelCase(), "jimBobButton")
    }
    
    func testIsNotEmpty() {
        XCTAssertFalse("".isNotEmpty)
        XCTAssertTrue("a".isNotEmpty)
    }
    
    func testFirstMatchOfWhenHasMatch() throws {
        let regex = try NSRegularExpression(pattern: "[0-9]+", options: [])
        let subject = "abc123def"
        let match = subject.firstMatch(of: regex)
        
        XCTAssertNotNil(match)
        XCTAssertEqual(match?.range, NSRange(location: 3, length: 3))
    }
    
    func testTrimmedWhenSpace() {
        XCTAssertEqual("abc123def".trimmed(by: 3), "123")
    }
    
    func testTrimmedWhenNotEnoughString() {
        XCTAssertEqual("a".trimmed(by: 3), "")
    }
    
    func testRemoveRegularExpWhenMatch() throws {
        let regex = try NSRegularExpression(pattern: "[0-9]+", options: [])
        let subject = "abc123def456"

        XCTAssertEqual(subject.remove(regex), "abcdef456")
    }
    
    func testRemoveRegularExpWhenNoMatch() throws {
        let regex = try NSRegularExpression(pattern: "[0-9]+", options: [])
        let subject = "abcdefghi"

        XCTAssertEqual(subject.remove(regex), "abcdefghi")
    }

    func testReplacingOccuranceWithString() throws {
        let regex = try NSRegularExpression(pattern: "[0-9]+", options: [])
        let subject = "abc123def456ghi"
        
        XCTAssertEqual(subject.replacingOccurrences(of: regex, with: "haha"), "abchahadefhahaghi")
    }
    
    func testReplacingOccuranceWithClosureTransformWhenMatches() throws {
        let regex = try NSRegularExpression(pattern: "[0-9]+", options: [])
        let subject = "abc123def456ghi"
        
        XCTAssertEqual(subject.replacingOccurrences(of: regex, using: { "_" + $0 + "_" }), "abc_123_def_456_ghi")
    }

    func testReplacingOccuranceWithClosureTransformWhenNoMatches() throws {
        let regex = try NSRegularExpression(pattern: "[0-9]+", options: [])
        let subject = "abcdefghi"
        
        XCTAssertEqual(subject.replacingOccurrences(of: regex, using: { "_" + $0 + "_" }), "abcdefghi")
    }

}
