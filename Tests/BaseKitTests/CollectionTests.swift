import Foundation
import XCTest
import BaseKit

final class CollectionTests: XCTestCase {
    func testOnly() {
        XCTAssertNil([Int]().only)
        XCTAssertNil([1, 2].only)
        XCTAssertEqual([1].only, 1)
    }
    
    func testPrependContents() {
        var subject = [1, 2]
        
        subject.prepend(contentsOf: [3, 4])
        
        XCTAssertEqual(subject, [3, 4, 1, 2])
    }
}
