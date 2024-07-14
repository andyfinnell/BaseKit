import BaseKit
import XCTest

final class StringScannerTests: XCTestCase {
    func testMatch() throws {
        let result = try "meow".wholeMatch(ofScanner: "meow")
        XCTAssertEqual(result, "meow")
    }

    func testNoMatch() throws {
        let result = try "meow".wholeMatch(ofScanner: "bark")
        XCTAssertNil(result)
    }
}
