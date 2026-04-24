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

    @Test
    func testBoundsWithMonotonicCubic() {
        // Monotonic x-coordinates produce a negative discriminant in the
        // derivative root finder — no x-axis extrema exist.
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addCurve(
            to: Point(x: 100, y: 100),
            controlPoint1: Point(x: 33, y: 0),
            controlPoint2: Point(x: 66, y: 100)
        )
        let bounds = path.bounds
        #expect(bounds.width.isFinite)
        #expect(bounds.height.isFinite)
        #expect(bounds.minX <= 0 + 1e-9)
        #expect(bounds.maxX >= 100 - 1e-9)
        #expect(bounds.minY <= 0 + 1e-9)
        #expect(bounds.maxY >= 100 - 1e-9)
    }

    @Test
    func testBoundsWithCollinearCubic() {
        // All four control points on a diagonal line — both the quadratic
        // and linear denominators in the root finder vanish.
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addCurve(
            to: Point(x: 100, y: 100),
            controlPoint1: Point(x: 100.0 / 3.0, y: 100.0 / 3.0),
            controlPoint2: Point(x: 200.0 / 3.0, y: 200.0 / 3.0)
        )
        let bounds = path.bounds
        #expect(bounds.width.isFinite)
        #expect(bounds.height.isFinite)
        #expect(bounds.isClose(to: Rect(x: 0, y: 0, width: 100, height: 100), threshold: 1e-6))
    }

    @Test
    func testBoundsWithStrokedOpenPathOutline() {
        // Simulate a stroked vertical line with semicircular caps. The
        // quarter-circle arcs have monotonic x-coordinates, matching the
        // real-world trigger for the NaN bug.
        let left: Real = 45
        let right: Real = 55
        let top: Real = 10
        let bottom: Real = 90
        let k: Real = 0.5522847498 // kappa for quarter-circle approximation
        let r: Real = 5 // half stroke width
        let cx: Real = 50

        var path = BezierPath()
        path.move(to: Point(x: left, y: top))
        path.addLine(to: Point(x: left, y: bottom))
        // Bottom cap (semicircle left → right)
        path.addCurve(
            to: Point(x: cx, y: bottom + r),
            controlPoint1: Point(x: left, y: bottom + r * k),
            controlPoint2: Point(x: cx - r * k, y: bottom + r)
        )
        path.addCurve(
            to: Point(x: right, y: bottom),
            controlPoint1: Point(x: cx + r * k, y: bottom + r),
            controlPoint2: Point(x: right, y: bottom + r * k)
        )
        path.addLine(to: Point(x: right, y: top))
        // Top cap (semicircle right → left)
        path.addCurve(
            to: Point(x: cx, y: top - r),
            controlPoint1: Point(x: right, y: top - r * k),
            controlPoint2: Point(x: cx + r * k, y: top - r)
        )
        path.addCurve(
            to: Point(x: left, y: top),
            controlPoint1: Point(x: cx - r * k, y: top - r),
            controlPoint2: Point(x: left, y: top - r * k)
        )
        path.closeSubpath()

        let bounds = path.bounds
        #expect(bounds.width.isFinite)
        #expect(bounds.height.isFinite)
        let expected = Rect(x: left, y: top - r, width: right - left, height: bottom - top + 2 * r)
        #expect(bounds.isClose(to: expected, threshold: 1e-6))
    }

    @Test
    func testComputeBoundingBoxMonotonicXCoords() {
        // x-coords strictly monotonic (negative discriminant),
        // y-coords have extrema.
        let points = [
            Point(x: 0, y: 0),
            Point(x: 10, y: 50),
            Point(x: 20, y: -20),
            Point(x: 30, y: 30),
        ]
        let bbox = Bezier.computeBoundingBoxForCubicBezier(points)
        #expect(bbox.width.isFinite)
        #expect(bbox.height.isFinite)
        #expect(bbox.minX <= 0 + 1e-9)
        #expect(bbox.maxX >= 30 - 1e-9)
    }
}
