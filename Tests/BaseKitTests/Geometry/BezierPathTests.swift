import Testing
@testable import BaseKit

struct BezierPathTests {
    @Test
    func testBoundsWithEllipse() {
        let ellipse = BezierPath(ellipseIn: Rect(x: 25, y: 50, width: 50, height: 75))
        let bounds = ellipse.bounds
        let expected = Rect(x: 25, y: 50, width: 50, height: 75)
        #expect(bounds == expected)
    }
    
    @Test
    func testBoundsWithRectangle() {
        let rect = BezierPath(rect: Rect(x: 25, y: 50, width: 50, height: 75))
        let bounds = rect.bounds
        let expected = Rect(x: 25, y: 50, width: 50, height: 75)
        #expect(bounds == expected)
    }

    @Test
    func testBoundsWithRotatedCircle() {
        var circle = BezierPath(ellipseIn: Rect(x: 25, y: 50, width: 50, height: 50))
        circle.transform(Transform(rotate: Real.pi / 4.0, anchor: Point(x: 50, y: 75)))
        let bounds = circle.bounds
        let expected = Rect(x: 25, y: 50, width: 50, height: 50)
        #expect(bounds.isClose(to: expected, threshold: 1e-6))
    }

    @Test
    func testBoundsWithRotatedSquare() {
        let center = Point(x: 50, y: 75)
        var square = BezierPath(rect: Rect(x: 25, y: 50, width: 50, height: 50))
        square.transform(Transform(rotate: Real.pi / 4.0, anchor: center))
        let bounds = square.bounds
        let radius: Real = 35.35533906
        let expected = Rect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        #expect(bounds.isClose(to: expected, threshold: 1e-6))
    }
}
