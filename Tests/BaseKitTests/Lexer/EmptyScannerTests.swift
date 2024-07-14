@testable import BaseKit
import XCTest

final class EmptyScannerTests: XCTestCase {
    func testEmpty() throws {
        let result: EmptyScanner.ScannerOutput? = try "abc".prefixMatch(ofScanner: EmptyScanner())
        XCTAssertNotNil(result)
    }
}
