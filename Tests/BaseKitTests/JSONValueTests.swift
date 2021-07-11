import Foundation
import XCTest
import BaseKit

final class JSONValueTests: XCTestCase {
    func testDecode() throws {
        let fixture = """
        {
            "name": "Frank",
            "is_person": true,
            "favorite_numbers": [7, 13, 42],
            "missing": null
        }
        """.data(using: .utf8)!

        let actualValue = try JSONDecoder().decode(JSONValue.self, from: fixture)
        let expectedValue = JSONValue.object([
            "name": .string("Frank"),
            "is_person": .boolean(true),
            "favorite_numbers": .array([
                .number(7), .number(13), .number(42)
            ]),
            "missing": .null
        ])
        
        XCTAssertEqual(actualValue, expectedValue)
    }
    
    func testEncode() throws {
        let fixture = JSONValue.object([
            "name": .string("Frank"),
            "is_person": .boolean(true),
            "favorite_numbers": .array([
                .number(7), .number(13), .number(42)
            ]),
            "missing": .null
        ])

        let actualValue = try JSONEncoder().encode(fixture)
        let roundtrippedValue = try JSONDecoder().decode(JSONValue.self, from: actualValue)

        XCTAssertEqual(roundtrippedValue, fixture)
    }
}
