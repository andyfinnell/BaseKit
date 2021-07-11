import Foundation
import XCTest
import BaseKit

final class CharacterTests: XCTestCase {
    struct TestType: Codable, Equatable {
        let value: Character
    }
        
    func testCodable() throws {
        let testValue = TestType(value: "a")
        let data = try JSONEncoder().encode(testValue)
        let decodedValue = try JSONDecoder().decode(TestType.self, from: data)
        
        XCTAssertEqual(testValue, decodedValue)
    }
}
