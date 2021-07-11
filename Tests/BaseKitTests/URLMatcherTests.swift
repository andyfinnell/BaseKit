import Foundation
import XCTest
@testable import BaseKit

final class URLMatcherTests: XCTestCase {
    
    func testExact_noMatch() {
        let subject = URLMatcher(patterns: [.exact("https://example.com")])
        let result = subject.match(url: URL(string: "https://example.org")!)
        XCTAssertNil(result)
    }
    
    func testExact_match() {
        let subject = URLMatcher(patterns: [.exact("https://example.com")])
        let result = subject.match(url: URL(string: "https://example.com")!)

        XCTAssertEqual(result?.url, URL(string: "https://example.com")!)
        XCTAssertEqual(result!.matches, [String: String]())
    }
    
    func testRegex_noMatch() {
        let subject = URLMatcher(patterns: [.exact("https://example.com/"), .regex(try! NSRegularExpression(pattern: "[0-9a-f]+"), name: "hex")])
        let result = subject.match(url: URL(string: "https://example.com/zzaa")!)
        XCTAssertNil(result)
    }
    
    func testRegex_match() {
        let subject = URLMatcher(patterns: [.exact("https://example.com/"), .regex(try! NSRegularExpression(pattern: "[0-9a-f]+"), name: "hex")])
        let result = subject.match(url: URL(string: "https://example.com/0deadbeef")!)
        
        XCTAssertEqual(result?.url, URL(string: "https://example.com/0deadbeef")!)
        XCTAssertEqual(result!.matches, ["hex": "0deadbeef"])
    }
    
    func testSegment_noMatch() {
        let subject = URLMatcher(patterns: [.exact("https://example.com/"), .segment(name: "token"), .exact("/register")])
        let result = subject.match(url: URL(string: "https://example.com//register")!)
        XCTAssertNil(result)
    }
    
    func testSegment_match() {
        let subject = URLMatcher(patterns: [.exact("https://example.com/"), .segment(name: "token"), .exact("/register")])
        let result = subject.match(url: URL(string: "https://example.com/valid-token/register")!)
        XCTAssertEqual(result?.url, URL(string: "https://example.com/valid-token/register")!)
        XCTAssertEqual(result!.matches, ["token": "valid-token"])
    }
}
