import BaseKit
import XCTest

final class CharacterSetScannerTests: XCTestCase {
    func testCharacterSetMatch() throws {
        let result = try "4".wholeMatch(ofScanner: CharacterSet.decimalDigits)
        XCTAssertEqual(result, "4")
    }
    
    func testCharacterSetNoMatch() throws {
        let result = try "f".wholeMatch(ofScanner: CharacterSet.decimalDigits)
        XCTAssertNil(result)
    }

    func testSetOfCharactersMatch() throws {
        let result = try "4".wholeMatch(ofScanner: Set<Character>(["4", "5"]))
        XCTAssertEqual(result, "4")
    }
    
    func testSetOfCharactersNoMatch() throws {
        let result = try "f".wholeMatch(ofScanner: Set<Character>(["4", "5"]))
        XCTAssertNil(result)
    }

}
