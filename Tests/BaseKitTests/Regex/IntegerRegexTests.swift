import XCTest
import BaseKit

final class IntegerRegexTests: XCTestCase {
    func testBase10() throws {
        let result = try "15".wholeMatch(ofScanner: IntegerRegex())
        XCTAssertEqual(result, 15)
    }
    
    func testBase10NoMatch() throws {
        let result = try "five".wholeMatch(ofScanner: IntegerRegex())
        XCTAssertNil(result)
    }
    
    func testBase10OneCharacter() throws {
        let result = try "15".prefixMatch(ofScanner: IntegerRegex(numberOfDigits: 1))
        XCTAssertEqual(result, 1)
    }

    func testBase16() throws {
        let result = try "1A".wholeMatch(ofScanner: IntegerRegex(radix: 16))
        XCTAssertEqual(result, 26)
    }
    
    func testBase16NoMatch() throws {
        let result = try "six".wholeMatch(ofScanner: IntegerRegex(radix: 16))
        XCTAssertNil(result)
    }
    
    func testBase16OneCharacter() throws {
        let result = try "15".prefixMatch(ofScanner: IntegerRegex(numberOfDigits: 1, radix: 16))
        XCTAssertEqual(result, 1)
    }

    func testBase16TwoCharacter() throws {
        let result = try "154".prefixMatch(ofScanner: IntegerRegex(numberOfDigits: 2, radix: 16))
        XCTAssertEqual(result, 21)
    }

}
