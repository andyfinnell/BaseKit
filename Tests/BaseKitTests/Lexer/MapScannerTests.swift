import BaseKit
import XCTest

final class MapScannerTests: XCTestCase {
    func testMatch() throws {
        let subject = MapScanner {
            "red"
        } transform: { _ in
            Color.red
        }
        let result = try "red".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result, Color.red)
    }
    
    func testNoMatch() throws {
        let subject = MapScanner {
            "red"
        } transform: { _ in
            Color.red
        }
        let result = try "blue".wholeMatch(ofScanner: subject)
        XCTAssertNil(result)
    }
}
