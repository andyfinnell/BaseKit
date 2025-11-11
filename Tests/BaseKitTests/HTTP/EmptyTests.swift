import Foundation
import XCTest
@testable import BaseKit

final class EmptyTests: XCTestCase {    
    func test_equals() {
        XCTAssertTrue(Empty() == Empty())
    }
}

