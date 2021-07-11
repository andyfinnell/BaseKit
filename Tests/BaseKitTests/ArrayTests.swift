import Foundation
import XCTest
import BaseKit

final class ArrayTests: XCTestCase {
    func testPopFirstWhenIsEmpty() {
        var subject = [Int]()
        XCTAssertNil(subject.popFirst())
    }
    
    func testPopFirstWhenNotIsEmpty() {
        var subject = [1, 2]
        let result = subject.popFirst()
        
        XCTAssertEqual(result, 1)
        XCTAssertEqual(subject, [2])
    }
    
    func testInitOptionalWhenNil() {
        let optional: Int? = nil
        XCTAssertEqual(Array(optional: optional), [Int]())
    }
    
    func testInitOptionalWhenNotNil() {
        let optional: Int? = 42
        XCTAssertEqual(Array(optional: optional), [42])
    }
    
    func testSubscriptIndexSet() {
        let subject = [1, 2, 3, 4, 5]
        let indexSet = IndexSet([0, 2, 4, 6, 8, 10])
        XCTAssertEqual(subject[indexSet], [1, 3, 5])
    }
    
    func testSubscriptClosedRange() {
        let subject = [1, 2, 3, 4, 5]
        XCTAssertEqual(subject[2..<10], [3, 4, 5])
    }
    
    func testAtWhenInRange() {
        let subject = [1, 2, 3, 4, 5]
        XCTAssertEqual(subject.at(1), 2)
    }
    
    func testAtWhenOutOfRange() {
        let subject = [1, 2, 3, 4, 5]
        XCTAssertNil(subject.at(10))
    }
    
    func testPenulimateWhenExists() {
        let subject = [1, 2, 3, 4, 5]
        XCTAssertEqual(subject.penultimate, 4)
    }
    
    func testPenulimateWhenTooShort() {
        let subject = [1]
        XCTAssertNil(subject.penultimate)
    }
    
    func testRemoveFirstMatchingWhenMatch() {
        var subject = [1, 2, 3, 4, 5]
        let result = subject.removeFirstMatching({ $0 == 2 })
        XCTAssertEqual(result, 2)
        XCTAssertEqual(subject, [1, 3, 4, 5])
    }
    
    func testRemoveFirstMatchingWhenNoMatch() {
        var subject = [1, 2, 3, 4, 5]
        let result = subject.removeFirstMatching({ $0 == 6 })
        XCTAssertNil(result)
        XCTAssertEqual(subject, [1, 2, 3, 4, 5])
    }
}
