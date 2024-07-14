import BaseKit
import XCTest

final class TupleScannerTests: XCTestCase {
    func testMatch() throws {
        let subject = Scanner {
            "#"
            IntegerRegex(numberOfDigits: 1, radix: 16)
        }
        let result = try "#A".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result?.0, "#")
        XCTAssertEqual(result?.1, 10)
    }
    
    func testNoMatch() throws {
        let subject = Scanner {
            "#"
            IntegerRegex(numberOfDigits: 1, radix: 16)
        }
        let result = try "#Q".wholeMatch(ofScanner: subject)
        XCTAssertNil(result)
    }
}
