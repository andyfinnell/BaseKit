import Foundation
import XCTest
@testable import BaseKit

final class URLHandlerTests: XCTestCase {
    func test_handle() {
        var handler_wasCalled = false
        var handler_wasCalled_withMatch: URLMatch?
        let subject = URLHandler { match -> Bool in
            handler_wasCalled = true
            handler_wasCalled_withMatch = match
            return true
        }
        
        let match = URLMatch(url: URL(string: "https://www.example.com")!, matches: [:])
        let returnValue = subject.handle(match: match)
        
        XCTAssertTrue(handler_wasCalled)
        XCTAssertEqual(handler_wasCalled_withMatch?.url, URL(string: "https://www.example.com")!)
        XCTAssertEqual(handler_wasCalled_withMatch!.matches, [String: String]())
        XCTAssertTrue(returnValue)
    }
}
