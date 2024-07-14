import Foundation
import BaseKit
import XCTest

final class RawRepresentableScannerTests: XCTestCase {
    enum MyEnum: String, CaseIterable {
        case frank
        case bob
        case bobby
    }
    
    func testMatch() throws {
        let subject = RawRepresentableScanner<MyEnum>()
        let result = try "bobby".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result, MyEnum.bobby)
    }

    func testMatchShort() throws {
        let subject = RawRepresentableScanner<MyEnum>()
        let result = try "bob".wholeMatch(ofScanner: subject)
        XCTAssertEqual(result, MyEnum.bob)
    }

    func testNoMatch() throws {
        let subject = RawRepresentableScanner<MyEnum>()
        let result = try "jim".wholeMatch(ofScanner: subject)
        XCTAssertNil(result)
    }
}
