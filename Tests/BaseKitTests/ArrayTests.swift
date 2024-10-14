import Foundation
import Testing
import BaseKit

struct ArrayTests {
    @Test
    func testPopFirstWhenIsEmpty() {
        var subject = [Int]()
        #expect(subject.popFirst() == nil)
    }
    
    @Test
    func testPopFirstWhenNotIsEmpty() {
        var subject = [1, 2]
        let result = subject.popFirst()
        
        #expect(result == 1)
        #expect(subject == [2])
    }
    
    @Test
    func testInitOptionalWhenNil() {
        let optional: Int? = nil
        #expect(Array(optional: optional) == [Int]())
    }
    
    @Test
    func testInitOptionalWhenNotNil() {
        let optional: Int? = 42
        #expect(Array(optional: optional) == [42])
    }
    
    @Test
    func testSubscriptIndexSet() {
        let subject = [1, 2, 3, 4, 5]
        let indexSet = IndexSet([0, 2, 4, 6, 8, 10])
        #expect(subject[indexSet] == [1, 3, 5])
    }
    
    @Test
    func testSubscriptClosedRange() {
        let subject = [1, 2, 3, 4, 5]
        #expect(subject.at(2..<10) == [3, 4, 5])
    }
    
    @Test
    func testAtWhenInRange() {
        let subject = [1, 2, 3, 4, 5]
        #expect(subject.at(1) == 2)
    }
    
    @Test
    func testAtWhenOutOfRange() {
        let subject = [1, 2, 3, 4, 5]
        #expect(subject.at(10) == nil)
    }
    
    @Test
    func testPenulimateWhenExists() {
        let subject = [1, 2, 3, 4, 5]
        #expect(subject.penultimate == 4)
    }
    
    @Test
    func testPenulimateWhenTooShort() {
        let subject = [1]
        #expect(subject.penultimate == nil)
    }
    
    @Test
    func testRemoveFirstMatchingWhenMatch() {
        var subject = [1, 2, 3, 4, 5]
        let result = subject.removeFirstMatching({ $0 == 2 })
        #expect(result == 2)
        #expect(subject == [1, 3, 4, 5])
    }
    
    @Test
    func testRemoveFirstMatchingWhenNoMatch() {
        var subject = [1, 2, 3, 4, 5]
        let result = subject.removeFirstMatching({ $0 == 6 })
        #expect(result == nil)
        #expect(subject == [1, 2, 3, 4, 5])
    }
}
