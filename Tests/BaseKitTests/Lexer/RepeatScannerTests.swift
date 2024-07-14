import BaseKit
import XCTest

final class RepeatScannerTests: XCTestCase {
    func testMatchesAll() throws {
        let subject = RepeatScanner {
            CharacterSet.decimalDigits
        }
        let result = try "12345".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result, ["1", "2", "3", "4", "5"])
    }
    
    func testMatchesUpToMaximum() throws {
        let subject = RepeatScanner(maximum: .count(3)) {
            CharacterSet.decimalDigits
        }
        let result = try "12345".prefixMatch(ofScanner: subject)
        XCTAssertEqual(result, ["1", "2", "3"])
    }
    
    func testNoMatchMinimum() throws {
        let subject = RepeatScanner(minimum: 6) {
            CharacterSet.decimalDigits
        }
        let result = try "12345".wholeMatch(ofScanner: subject)
        XCTAssertNil(result)
    }
    
    func testMatchesMinimum() throws {
        let subject = RepeatScanner(minimum: 3) {
            CharacterSet.decimalDigits
        }
        let result = try "12345".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result, ["1", "2", "3", "4", "5"])
    }
    
    func testMatchesZero() throws {
        let subject = RepeatScanner {
            CharacterSet.decimalDigits
        }
        let result = try "".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result, [])
    }
}
