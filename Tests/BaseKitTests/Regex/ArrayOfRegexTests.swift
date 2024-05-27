import Foundation
import XCTest
import RegexBuilder
@testable import BaseKit

final class ArrayOfRegexTests: XCTestCase {
    private let subject = ArrayOfRegex(separator: Regex {
        OneOrMore {
            CharacterClass(.whitespace)
        }
    }, element: Regex {
        RealNumberRegex()
    })
    
    func testScanScientific() {
        let match = "0 0  1024    720".wholeMatch(of: subject)
        XCTAssertEqual(match?.output, [0, 0, 1024, 720])
    }
}
