import XCTest
import BaseKit

func XCTAssertClose(
    _ got: Double,
    _ expected: Double,
    threshold: Double = 0.000001,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssert(
        got >= (expected - threshold) && got <= (expected + threshold),
        "Expected \(got) to be close to \(expected)",
        file: file,
        line: line
    )
}

func XCTAssertClose(
    _ got: Point?,
    _ expected: Point,
    threshold: Double = 0.000001,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertNotNil(got, "Point shouldn't be nil")
    guard let got else {
        return
    }
    XCTAssert(
        got.x >= (expected.x - threshold) && got.x <= (expected.x + threshold),
        "Expected \(got) to be close to \(expected)",
        file: file,
        line: line
    )
    XCTAssert(
        got.y >= (expected.y - threshold) && got.y <= (expected.y + threshold),
        "Expected \(got) to be close to \(expected)",
        file: file,
        line: line
    )
}
