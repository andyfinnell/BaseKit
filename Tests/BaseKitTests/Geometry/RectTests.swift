import BaseKit
import Testing


struct RectTests {
    @Test
    func testInset() {
        let subject = Rect(x: 25, y: 60, width: 100, height: 70)
        #expect(subject.insetBy(dx: 25, dy: 10) == Rect(x: 50, y: 70, width: 50, height: 50))
    }
    
    @Test
    func testCenterInside() {
        let containingRect = Rect(x: 25, y: 50, width: 100, height: 50)
        let subject = Rect(x: 25, y: 50, width: 50, height: 50)
        #expect(subject.center(inside: containingRect) == Rect(x: 50, y: 50, width: 50, height: 50))
    }
    
    @Test
    func testCenterOn() {
        let containedRect = Rect(x: 25, y: 50, width: 50, height: 50)
        let subject = Rect(x: 25, y: 50, width: 100, height: 50)
        #expect(subject.center(on: containedRect) == Rect(x: 0, y: 50, width: 100, height: 50))
    }
}
