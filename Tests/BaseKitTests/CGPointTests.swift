#if canImport(CoreGraphics)
import Foundation
import CoreGraphics
import XCTest
import BaseKit

final class CGPointTests: XCTestCase {
    func testSubtract() {
        let a = CGPoint(x: 150, y: 75)
        let b = CGPoint(x: 75, y: 25)
        
        XCTAssertEqual(a - b, CGPoint(x: 75, y: 50))
    }
}

#endif
