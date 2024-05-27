import Foundation
import XCTest
@testable import BaseKit

final class RealNumberRegexTests: XCTestCase {
    func testInstantiateNegativeSymbol() {
        let match = "-five".wholeMatch(of: RealNumberRegex())
        XCTAssertNil(match)
    }
    
    func testInstantiateNonDecimal() {
        let match = "five".wholeMatch(of: RealNumberRegex())
        XCTAssertNil(match)
    }
    
    func testScanNegative() {
        let match = "-55".wholeMatch(of: RealNumberRegex())
        XCTAssertEqual(match?.output, -55)
    }
    
    func testScanDecimal() {
        let match = "55".wholeMatch(of: RealNumberRegex())
        XCTAssertEqual(match?.output, 55)
    }
        
    func testScanFractional() {
        let match = "55.55".wholeMatch(of: RealNumberRegex())
        XCTAssertEqual(match?.output, 55.55)
    }

    func testScanFractionAndExponent() {
        let match = "55.55e2".wholeMatch(of: RealNumberRegex())
        XCTAssertEqual(match?.output, 5555)
    }

    func testScanNegativeExponent() {
        let match = "55e-2".wholeMatch(of: RealNumberRegex())
        XCTAssertEqual(match?.output, 0.55)
    }

    func testScanScientific() {
        let match = "1.456e3".wholeMatch(of: RealNumberRegex())
        XCTAssertEqual(match?.output, 1456)
    }
}
