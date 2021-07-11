import Foundation
import XCTest
@testable import BaseKit

final class FilesystemPathTests: XCTestCase {
    func testSantize() {
        XCTAssertEqual(FilesystemPath.sanitize(string: "bob/jimbob"), "bobjimbob")
    }
    
    func testAppending() {
        let subject = FilesystemPath(components: ["one", "two"])
        let result = subject.appending(name: "three")
        
        XCTAssertEqual(result, FilesystemPath(components: ["one", "two", "three"]))
        XCTAssertEqual(subject, FilesystemPath(components: ["one", "two"]))
    }
    
    func testRemovingLastComponentWhenNoComponents() {
        let subject = FilesystemPath(components: [])
        let result = subject.removingLastComponent()
        
        XCTAssertEqual(result, FilesystemPath(components: []))
    }
    
    func testRemovingLastComponentWhenOneOrMoreComponents() {
        let subject = FilesystemPath(components: ["one", "two"])
        let result = subject.removingLastComponent()
    
        XCTAssertEqual(result, FilesystemPath(components: ["one"]))
        XCTAssertEqual(subject, FilesystemPath(components: ["one", "two"]))
    }
    
    func testLastComponentWhenNoComponents() {
        let subject = FilesystemPath(components: [])
        let result = subject.lastComponent()
    
        XCTAssertNil(result)
    }
    
    func testLastComponentWhenOneOrMoreComponents() {
        let subject = FilesystemPath(components: ["one", "two"])
        let result = subject.lastComponent()
    
        XCTAssertEqual(result, "two")
        XCTAssertEqual(subject, FilesystemPath(components: ["one", "two"]))
    }
}
