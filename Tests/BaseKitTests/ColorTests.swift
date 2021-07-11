import Foundation
import XCTest
import BaseKit

final class ColorTests: XCTestCase {
        
    func testInitHex_invalid() {
        XCTAssertThrowsError(try Color(hex: "#%^&@#$"))
    }
    
    func testInitHex_noAlpha() throws {
        let color = try Color(hex: "#aabbcc")
        
        XCTAssertEqual(color.red, Double(0xaa) / 255.0)
        XCTAssertEqual(color.green, Double(0xbb) / 255.0)
        XCTAssertEqual(color.blue, Double(0xcc) / 255.0)
        XCTAssertEqual(color.alpha, 1.0)
    }
    
    func testInitHex_alpha() throws {
        let color = try Color(hex: "#aabbccdd")
        
        XCTAssertEqual(color.red, Double(0xaa) / 255.0)
        XCTAssertEqual(color.green, Double(0xbb) / 255.0)
        XCTAssertEqual(color.blue, Double(0xcc) / 255.0)
        XCTAssertEqual(color.alpha, Double(0xdd) / 255.0)
    }
}

