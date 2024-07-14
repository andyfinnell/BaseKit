import BaseKit
import XCTest

final class ChoiceOfScannerTests: XCTestCase {
    func testMatch() throws {
        let subject = ChoiceOfScanner {
            "bobby"
            
            "bob"
            
            "alice"
        }
        let result = try "bob".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result, "bob")
    }
    
    func testNoMatch() throws {
        let subject = ChoiceOfScanner {
            "bobby"
            
            "bob"
            
            "alice"
        }
        let result = try "frank".wholeMatch(ofScanner: subject)
        XCTAssertNil(result)
    }

}
