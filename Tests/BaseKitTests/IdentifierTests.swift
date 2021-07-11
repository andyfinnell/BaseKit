import Foundation
import XCTest
import BaseKit

final class IdentifierTests: XCTestCase {
    enum TestIdentifierType {}
    typealias TestIdentifier = Identifier<String, TestIdentifierType>
    
    struct TestType: Codable, Equatable {
        let value: TestIdentifier
    }
        
    func testCodable() throws {
        let testValue = TestType(value: TestIdentifier("my-id"))
        let data = try JSONEncoder().encode(testValue)
        let decodedValue = try JSONDecoder().decode(TestType.self, from: data)
        
        XCTAssertEqual(testValue, decodedValue)
    }
    
    func testComparable() {
        let a = TestIdentifier("abc")
        let b = TestIdentifier("def")
        
        XCTAssertTrue(a < b)
    }
}
