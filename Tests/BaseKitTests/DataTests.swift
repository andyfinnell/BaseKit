import Foundation
import XCTest
import BaseKit

final class DataTests: XCTestCase {
    func testContentId() {
        let subject = Data([0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0x0F])
        let expected = "eb3ca3ca1b1abb0ecf34893413b0fcc7158001fc63f659f97e50498f33503ba9"

        XCTAssertEqual(subject.contentId(), ContentId(expected))
    }
}
