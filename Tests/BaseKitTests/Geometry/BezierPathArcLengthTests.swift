import Foundation
import Testing
@testable import BaseKit

struct BezierPathArcLengthTests {
    @Test func negativeArcLengthReturnsNil() {
        var path = BezierPath()
        path.move(to: .zero)
        path.addLine(to: Point(x: 100, y: 0))
        #expect(path.pointAndTangent(atArcLength: -1) == nil)
    }

    @Test func arcLengthBeyondTotalReturnsNil() {
        var path = BezierPath()
        path.move(to: .zero)
        path.addLine(to: Point(x: 100, y: 0))
        #expect(path.pointAndTangent(atArcLength: 100.001) == nil)
    }

    @Test func emptyPathReturnsNil() {
        let path = BezierPath()
        #expect(path.pointAndTangent(atArcLength: 0) == nil)
    }

    // MARK: - Lines

    @Test func startOfHorizontalLine() {
        var path = BezierPath()
        path.move(to: .zero)
        path.addLine(to: Point(x: 100, y: 0))
        let result = path.pointAndTangent(atArcLength: 0)
        #expect(result != nil)
        guard let (point, tangent) = result else { return }
        #expect(point.x.isClose(to: 0, threshold: 1e-9))
        #expect(point.y.isClose(to: 0, threshold: 1e-9))
        #expect(tangent.x.isClose(to: 1, threshold: 1e-9))
        #expect(tangent.y.isClose(to: 0, threshold: 1e-9))
    }

    @Test func midpointOfHorizontalLine() {
        var path = BezierPath()
        path.move(to: Point(x: 10, y: 20))
        path.addLine(to: Point(x: 110, y: 20))
        let result = path.pointAndTangent(atArcLength: 50)
        #expect(result != nil)
        guard let (point, tangent) = result else { return }
        #expect(point.x.isClose(to: 60, threshold: 1e-9))
        #expect(point.y.isClose(to: 20, threshold: 1e-9))
        #expect(tangent.x.isClose(to: 1, threshold: 1e-9))
        #expect(tangent.y.isClose(to: 0, threshold: 1e-9))
    }

    @Test func endpointOfHorizontalLine() {
        var path = BezierPath()
        path.move(to: .zero)
        path.addLine(to: Point(x: 100, y: 0))
        let result = path.pointAndTangent(atArcLength: 100)
        #expect(result != nil)
        guard let (point, _) = result else { return }
        #expect(point.x.isClose(to: 100, threshold: 1e-9))
        #expect(point.y.isClose(to: 0, threshold: 1e-9))
    }

    @Test func verticalLineHasUpwardTangent() {
        var path = BezierPath()
        path.move(to: .zero)
        path.addLine(to: Point(x: 0, y: 50))
        let result = path.pointAndTangent(atArcLength: 25)
        #expect(result != nil)
        guard let (point, tangent) = result else { return }
        #expect(point.y.isClose(to: 25, threshold: 1e-9))
        #expect(tangent.x.isClose(to: 0, threshold: 1e-9))
        #expect(tangent.y.isClose(to: 1, threshold: 1e-9))
    }

    @Test func diagonalLineTangentIsUnitDiagonal() {
        var path = BezierPath()
        path.move(to: .zero)
        path.addLine(to: Point(x: 30, y: 40))
        let result = path.pointAndTangent(atArcLength: 25)
        #expect(result != nil)
        guard let (point, tangent) = result else { return }
        // arc-length 25 of total 50 = midpoint.
        #expect(point.x.isClose(to: 15, threshold: 1e-9))
        #expect(point.y.isClose(to: 20, threshold: 1e-9))
        // Unit tangent of (30, 40) is (0.6, 0.8).
        #expect(tangent.x.isClose(to: 0.6, threshold: 1e-9))
        #expect(tangent.y.isClose(to: 0.8, threshold: 1e-9))
    }

    // MARK: - Polyline crossings

    @Test func arcLengthCrossesIntoSecondSegment() {
        var path = BezierPath()
        path.move(to: .zero)
        path.addLine(to: Point(x: 100, y: 0))
        path.addLine(to: Point(x: 100, y: 50))
        // Second segment starts at arc-length 100 with downward tangent.
        let result = path.pointAndTangent(atArcLength: 120)
        #expect(result != nil)
        guard let (point, tangent) = result else { return }
        #expect(point.x.isClose(to: 100, threshold: 1e-9))
        #expect(point.y.isClose(to: 20, threshold: 1e-9))
        #expect(tangent.x.isClose(to: 0, threshold: 1e-9))
        #expect(tangent.y.isClose(to: 1, threshold: 1e-9))
    }

    @Test func closeSubpathContributesArcLength() {
        var path = BezierPath()
        path.move(to: .zero)
        path.addLine(to: Point(x: 100, y: 0))
        path.addLine(to: Point(x: 100, y: 50))
        path.closeSubpath()
        // Closing segment is (100,50) → (0,0), length sqrt(100² + 50²) ≈ 111.803.
        // Midway along the close: arc-length 100 + 50 + 111.803/2 ≈ 205.901.
        let target = 100.0 + 50.0 + sqrt(100.0 * 100.0 + 50.0 * 50.0) / 2.0
        let result = path.pointAndTangent(atArcLength: target)
        #expect(result != nil)
        guard let (point, _) = result else { return }
        #expect(point.x.isClose(to: 50, threshold: 1e-6))
        #expect(point.y.isClose(to: 25, threshold: 1e-6))
    }

    @Test func arcLengthCrossesMoveBoundaryBetweenSubpaths() {
        var path = BezierPath()
        // First subpath: length 100
        path.move(to: .zero)
        path.addLine(to: Point(x: 100, y: 0))
        // Second subpath: length 50, starts at (200, 0)
        path.move(to: Point(x: 200, y: 0))
        path.addLine(to: Point(x: 200, y: 50))
        // Target 125 = 100 (first subpath) + 25 into second subpath.
        let result = path.pointAndTangent(atArcLength: 125)
        #expect(result != nil)
        guard let (point, tangent) = result else { return }
        #expect(point.x.isClose(to: 200, threshold: 1e-9))
        #expect(point.y.isClose(to: 25, threshold: 1e-9))
        #expect(tangent.y.isClose(to: 1, threshold: 1e-9))
    }

    // MARK: - Cubic bezier

    @Test func straightCubicMatchesLineSampling() {
        // A cubic with collinear controls is effectively a straight line.
        var path = BezierPath()
        path.move(to: .zero)
        path.addCurve(
            to: Point(x: 100, y: 0),
            controlPoint1: Point(x: 33, y: 0),
            controlPoint2: Point(x: 66, y: 0)
        )
        let result = path.pointAndTangent(atArcLength: 50)
        #expect(result != nil)
        guard let (point, tangent) = result else { return }
        #expect(point.x.isClose(to: 50, threshold: 0.5))
        #expect(point.y.isClose(to: 0, threshold: 1e-9))
        // Tangent is along +x.
        #expect(tangent.x.isClose(to: 1, threshold: 1e-3))
        #expect(tangent.y.isClose(to: 0, threshold: 1e-3))
    }

    @Test func symmetricArchCubicMidpointIsAtPeak() {
        // Symmetric cubic from (0,0) to (100,0) with controls lifted in
        // y. At parameter t=0.5 the curve is at (50, ymax). The mid
        // arc-length is the same point for a symmetric curve.
        var path = BezierPath()
        path.move(to: .zero)
        path.addCurve(
            to: Point(x: 100, y: 0),
            controlPoint1: Point(x: 25, y: 60),
            controlPoint2: Point(x: 75, y: 60)
        )
        let total = path.totalLength
        let result = path.pointAndTangent(atArcLength: total / 2.0)
        #expect(result != nil)
        guard let (point, tangent) = result else { return }
        #expect(point.x.isClose(to: 50, threshold: 0.5))
        // At the peak of a symmetric arch, the tangent is horizontal.
        #expect(abs(tangent.y) < 0.05)
    }

    @Test func cubicStartTangentMatchesControlDirection() {
        // Tangent at the start of a cubic is along (cp1 − p0).
        var path = BezierPath()
        path.move(to: .zero)
        path.addCurve(
            to: Point(x: 100, y: 100),
            controlPoint1: Point(x: 0, y: 50),
            controlPoint2: Point(x: 50, y: 100)
        )
        let result = path.pointAndTangent(atArcLength: 0)
        #expect(result != nil)
        guard let (_, tangent) = result else { return }
        // Start tangent direction is (0, 50) → unit (0, 1).
        #expect(tangent.x.isClose(to: 0, threshold: 1e-6))
        #expect(tangent.y.isClose(to: 1, threshold: 1e-6))
    }
}
