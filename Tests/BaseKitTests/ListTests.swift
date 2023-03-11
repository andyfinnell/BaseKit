import Foundation
import XCTest
import BaseKit

final class ListTests: XCTestCase {
    func testInitWhenNoParametersItIsConstructable() {
        let l = List<Int>()
        XCTAssertEqual(l, List<Int>.unit)
    }
    
    func testInitWhenGivenArrayLiteralItConstructsEquivalentList() {
        let l: List<Int> = [1, 2, 3, 4, 5]
        XCTAssertEqual(l, List.element(data: 1, next:
                                .element(data: 2, next:
                                .element(data: 3, next:
                                .element(data: 4, next:
                                .element(data: 5, next: .unit))))))
    }
    
    func testInitWhenGivenSequenceItConstructsEquivalentList() {
        let a = [1, 2, 3, 4, 5]
        let l = List(a)
        XCTAssertEqual(l, List.element(data: 1, next:
                                .element(data: 2, next:
                                .element(data: 3, next:
                                .element(data: 4, next:
                                .element(data: 5, next: .unit))))))
    }
    
    func testPopWhenNoElementsItReturnsEmpty() {
        let l = List<Int>.unit
        let newList = l.pop()
        XCTAssertEqual(newList, List<Int>.unit)
    }
    
    func testPopWhenSomeElementsItRemovesTopElement() {
        let l: List<Int> = [1, 2, 3, 4, 5]
        let newList = l.pop()
        XCTAssertEqual(newList, List.element(data: 2, next:
            .element(data: 3, next: .element(data: 4, next:
                .element(data: 5, next: .unit)))))

    }
    
    func testPushItPrependsElementToList() {
        let l = List<Int>()
        let newList = l.push(5)
        XCTAssertEqual(newList, List.element(data: 5, next: .unit))

    }
    
    func testHeadWhenNoElementsItReturnsNil() {
        let l = List<Int>()
        XCTAssertNil(l.head())
    }
    
    func testHeadWhenSomeElementsItReturnsFirstElement() {
        let l: List<Int> = [1, 2]
        let h = l.head()
        XCTAssertEqual(h, 1)
    }
    
    func testCountItReturnsNumberOfElements() {
        let l: List<Int> = [1, 2]
        XCTAssertEqual(l.count, 2)

    }
    
    func testIsEmptyWhenNoElementsItIsTrue() {
        let l = List<Int>()
        XCTAssertTrue(l.isEmpty)
    }
    
    func testIsEmptyWhenSomeElementsItIsFalse() {
        let l: List<Int> = [1, 2]
        XCTAssertFalse(l.isEmpty)
    }
    
    func testLastWhenNoElementsItReturnsNil() {
        let l = List<Int>()
        XCTAssertNil(l.last)
    }
    
    func testLastWhenSomeElementsItReturnsLastElement() {
        let l: List<Int> = [1, 2]
        let h = l.last
        XCTAssertEqual(h, 2)
    }
    
    func testIteratorItReturnsEveryElementInList() {
        let l: List<Int> = [1, 2, 3, 4, 5]
        var array = [Int]()
        for num in l {
            array.append(num)
        }
        
        XCTAssertEqual(array, [1, 2, 3, 4, 5])
    }
    
    func testUpdateHeadWhenNoElementsItDoesNothing() {
        let l = List<Int>.unit
        XCTAssertEqual(l.updateHead( { $0 + 42 } ), List<Int>.unit)
    }
    
    func testUpdateHeadWhenSomeElementsItReturnsUpdatedList() {
        let l: List<Int> = [1, 2, 3, 4, 5]
        let expectedList: List<Int> = [43, 2, 3, 4, 5]
        XCTAssertEqual(l.updateHead( { $0 + 42 } ), expectedList)
    }
    
    func testDescriptionItReturnsCustomString() {
        let l: List<Int> = [1, 2, 3, 4, 5]
        XCTAssertEqual(String(describing: l), "[1;2;3;4;5;]")
    }
}
