import Foundation
import XCTest
import BaseKit

final class DictionaryTests: XCTestCase {
    func testRemovingOneKey() {
        let subject = [1: "one", 2: "two", 3: "three"]
        XCTAssertEqual(subject.removing(1), [2: "two", 3: "three"])
    }
    
    func testRemovingSequenceOfKeys() {
        let subject = [1: "one", 2: "two", 3: "three", 4: "four", 5: "five"]
        XCTAssertEqual(subject.removing([1, 4, 5]), [2: "two", 3: "three"])
    }
    
    func testAddingKeyValue() {
        let subject = [1: "one", 2: "two"]
        XCTAssertEqual(subject.adding("three", for: 3), [1: "one", 2: "two", 3: "three"])
    }
}
