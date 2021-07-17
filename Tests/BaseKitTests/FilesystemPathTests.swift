import Foundation
import XCTest
@testable import BaseKit

final class FilesystemPathTests: XCTestCase {
    func testSantize() {
        XCTAssertEqual(FilesystemPath.sanitize(string: "bob/jimbob"), "bobjimbob")
    }
    
    func testAppending() {
        let subject = FilesystemPath(["one", "two"])
        let result = subject.appending(name: "three")
        
        XCTAssertEqual(result, FilesystemPath(["one", "two", "three"]))
        XCTAssertEqual(subject, FilesystemPath(["one", "two"]))
    }
    
    func testRemovingLastComponentWhenNoComponents() {
        let subject = FilesystemPath([])
        let result = subject.removingLastComponent()
        
        XCTAssertEqual(result, FilesystemPath([]))
    }
    
    func testRemovingLastComponentWhenOneOrMoreComponents() {
        let subject = FilesystemPath(["one", "two"])
        let result = subject.removingLastComponent()
    
        XCTAssertEqual(result, FilesystemPath(["one"]))
        XCTAssertEqual(subject, FilesystemPath(["one", "two"]))
    }
    
    func testLastComponentWhenNoComponents() {
        let subject = FilesystemPath([])
        let result = subject.lastComponent()
    
        XCTAssertNil(result)
    }
    
    func testLastComponentWhenOneOrMoreComponents() {
        let subject = FilesystemPath(["one", "two"])
        let result = subject.lastComponent()
    
        XCTAssertEqual(result, "two")
        XCTAssertEqual(subject, FilesystemPath(["one", "two"]))
    }
}
