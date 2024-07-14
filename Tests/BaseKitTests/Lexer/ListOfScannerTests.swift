import BaseKit
import XCTest

final class ListOfScannerTests: XCTestCase {
    func testMatch() throws {
        let subject = ListOfScanner(separator: {
            RepeatScanner { CharacterSet.whitespaces }
            ","
            RepeatScanner { CharacterSet.whitespaces }
        }, element: {
            IntegerRegex()
        })
        let result = try "1, 2, 3, 4".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result, [1, 2, 3, 4])
    }
    
    func testNoMatch() throws {
        let subject = ListOfScanner(separator: {
            RepeatScanner { CharacterSet.whitespaces }
            ","
            RepeatScanner { CharacterSet.whitespaces }
        }, element: {
            IntegerRegex()
        })
        let result = try "one, two, three".wholeMatch(ofScanner: subject)
        XCTAssertNil(result)
    }
}
