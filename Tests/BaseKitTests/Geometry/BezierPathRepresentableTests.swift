import Testing
@testable import BaseKit

struct BezierPathRepresentableTests {
    @Test
    func testRectDistanceTo() {
        let path = BezierPath(rect: Rect(x: 50, y: 50, width: 100, height: 100))
        let testPoint = Point(x: 153, y: 100)
        let distance = path.distance(to: testPoint)
        #expect(distance.isClose(to: 3.0, threshold: 1e-6))
    }
}
