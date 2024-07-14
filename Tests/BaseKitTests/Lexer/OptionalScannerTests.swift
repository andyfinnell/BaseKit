import BaseKit
import XCTest

final class OptionalScannerTests: XCTestCase {
    func testMatch() throws {
        let subject = Scanner {
            OptionalScanner {
                "jim"
            }
            "bob"
        }
        let result = try "jimbob".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result?.0, "jim")
        XCTAssertEqual(result?.1, "bob")
    }
    
    func testNoMatch() throws {
        let subject = Scanner {
            OptionalScanner {
                "jim"
            }
            "bob"
        }
        let result = try "bob".wholeMatch(ofScanner: subject)
        XCTAssertNil(result?.0)
        XCTAssertEqual(result?.1, "bob")
    }
}
