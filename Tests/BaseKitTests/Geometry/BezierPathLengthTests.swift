import Foundation
import Testing
@testable import BaseKit

struct BezierPathLengthTests {
    @Test func emptyPathHasZeroLength() {
        let path = BezierPath()
        #expect(path.totalLength == 0)
    }

    @Test func moveOnlyHasZeroLength() {
        var path = BezierPath()
        path.move(to: Point(x: 50, y: 50))
        #expect(path.totalLength == 0)
    }

    @Test func singleHorizontalLine() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 100, y: 0))
        #expect(path.totalLength == 100)
    }

    @Test func singleVerticalLine() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 0, y: 200))
        #expect(path.totalLength == 200)
    }

    @Test func diagonalLine() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 3, y: 4))
        #expect(path.totalLength == 5)
    }

    @Test func multipleLineSegments() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 100, y: 0))
        path.addLine(to: Point(x: 100, y: 50))
        #expect(path.totalLength == 150)
    }

    @Test func closedRectangle() {
        let path = BezierPath(rect: Rect(x: 0, y: 0, width: 100, height: 50))
        #expect(path.totalLength == 300)
    }

    @Test func closeSubpathAddsReturnSegment() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 100, y: 0))
        path.addLine(to: Point(x: 100, y: 50))
        path.closeSubpath()
        // 100 + 50 + sqrt(100^2 + 50^2)
        let expected = 100.0 + 50.0 + sqrt(100.0 * 100.0 + 50.0 * 50.0)
        #expect(path.totalLength.isClose(to: expected, threshold: 1e-10))
    }

    @Test func straightLineCubicBezier() {
        // A cubic bezier with control points on the line should approximate the line length
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addCurve(
            to: Point(x: 100, y: 0),
            controlPoint1: Point(x: 33, y: 0),
            controlPoint2: Point(x: 66, y: 0)
        )
        #expect(path.totalLength.isClose(to: 100, threshold: 0.1))
    }

    @Test func curvedBezierLongerThanChord() {
        // A curved bezier should be longer than the straight-line distance between endpoints
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addCurve(
            to: Point(x: 100, y: 0),
            controlPoint1: Point(x: 25, y: 80),
            controlPoint2: Point(x: 75, y: 80)
        )
        let chordLength = 100.0
        #expect(path.totalLength > chordLength)
    }

    @Test func circleApproximation() {
        // An ellipse path approximates a circle; circumference = 2 * pi * r
        let r = 50.0
        let path = BezierPath(ellipseIn: Rect(x: 0, y: 0, width: r * 2, height: r * 2))
        let expectedCircumference = 2.0 * Real.pi * r
        #expect(path.totalLength.isClose(to: expectedCircumference, threshold: 0.5))
    }

    @Test func multipleSubpaths() {
        var path = BezierPath()
        // First subpath: horizontal line of length 100
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 100, y: 0))
        // Second subpath: vertical line of length 50
        path.move(to: Point(x: 200, y: 0))
        path.addLine(to: Point(x: 200, y: 50))
        #expect(path.totalLength == 150)
    }
}
