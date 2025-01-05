import Foundation
import Testing
import BaseKit

struct CollectionTests {
    @Test
    func testOnly() {
        #expect([Int]().only == nil)
        #expect([1, 2].only == nil)
        #expect([1].only == 1)
    }
    
    @Test
    func testPrependContents() {
        var subject = [1, 2]
        
        subject.prepend(contentsOf: [3, 4])
        
        #expect(subject == [3, 4, 1, 2])
    }
    
    @Test
    func testAllEqual() {
        #expect([Int]().allEqual() == true)
        #expect([1].allEqual() == true)
        #expect([1, 1].allEqual() == true)
        #expect([1, 2].allEqual() == false)
    }
}
