import Foundation
import XCTest
import BaseKit

final class URLRouterTests: XCTestCase {
    private var subject: URLRouter!
    
    override func setUp() {
        super.setUp()
        subject = URLRouter()
    }
    
    func test_onAnonymous_match() {
        let matchExpectation = expectation(description: "match")
        var finalMatch: URLMatch?
        subject.on(.exact("https://example.com")) { match -> Bool in
            finalMatch = match
            matchExpectation.fulfill()
            return true
        }
        
        let wasHandled = subject.handle(url: URL(string: "https://example.com")!)
        waitForExpectations(timeout: 0.3, handler: nil)
        
        XCTAssertTrue(wasHandled)
        XCTAssertNotNil(finalMatch)
    }
    
    func test_onAnonymous_noMatch() {
        var finalMatch: URLMatch?
        subject.on(.exact("https://example.com")) { match -> Bool in
            finalMatch = match
            return true
        }
        
        let wasHandled = subject.handle(url: URL(string: "https://example.org")!)
        
        XCTAssertFalse(wasHandled)
        XCTAssertNil(finalMatch)
    }

    func test_onNamed_match() {
        let handler = FakeURLHandler()
        handler.handle_expectation = expectation(description: "match")
        subject.on(.exact("https://example.com"), handler: handler)
        
        let wasHandled = subject.handle(url: URL(string: "https://example.com")!)
        waitForExpectations(timeout: 0.3, handler: nil)
        
        XCTAssertTrue(wasHandled)
        XCTAssertTrue(handler.handle_wasCalled)
        XCTAssertNotNil(handler.handle_wasCalled_withMatch)
    }
    
    func test_onNamed_noMatch() {
        let handler = FakeURLHandler()
        subject.on(.exact("https://example.com"), handler: handler)

        let wasHandled = subject.handle(url: URL(string: "https://example.org")!)
        
        XCTAssertFalse(wasHandled)
        XCTAssertFalse(handler.handle_wasCalled)
        XCTAssertNil(handler.handle_wasCalled_withMatch)
    }

}

private class FakeURLHandler: URLHandlerType {
    var handle_wasCalled = false
    var handle_wasCalled_withMatch: URLMatch?
    var handle_stubbed = true
    var handle_expectation: XCTestExpectation?
    
    func handle(match: URLMatch) -> Bool {
        handle_wasCalled = true
        handle_wasCalled_withMatch = match
        handle_expectation?.fulfill()
        return handle_stubbed
    }
}
