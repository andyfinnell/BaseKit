import Testing
@testable import BaseKit

struct BezierPathSimplifyTests {
    // MARK: - Empty and degenerate paths

    @Test func emptyPathReturnsEmpty() {
        let path = BezierPath()
        let result = path.simplified(tolerance: 2.5)
        #expect(result.isEmpty)
    }

    @Test func singleMoveToReturnsSameElement() {
        let path = BezierPath(elements: [.move(to: Point(x: 10, y: 20))])
        let result = path.simplified(tolerance: 2.5)
        #expect(result.count == 1)
    }

    @Test func moveAndSingleLineProducesCurve() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 100, y: 0)),
        ])
        let result = path.simplified(tolerance: 2.5)
        // Should produce a move + a single cubic that approximates a straight line
        #expect(result.count >= 2)
    }

    // MARK: - Line-based paths

    @Test func straightLineProducesCloseApproximation() {
        // A straight line sampled into many segments should simplify
        // back to something close to a straight line
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        for i in 1...20 {
            path.addLine(to: Point(x: Double(i) * 5.0, y: 0))
        }
        let result = path.simplified(tolerance: 2.5)

        // Should need very few segments for a straight line
        #expect(result.count < path.count)
    }

    @Test func zigzagLineSimplifies() {
        // A zigzag pattern — should simplify but still have multiple segments
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        for i in 1...10 {
            let y: Double = i.isMultiple(of: 2) ? 0 : 50
            path.addLine(to: Point(x: Double(i) * 20, y: y))
        }
        let result = path.simplified(tolerance: 1.0)

        // Should produce a move + multiple curves
        #expect(result.count > 2)
    }

    // MARK: - Curve-based paths

    @Test func circleApproximationRoundTrips() {
        let original = BezierPath(ellipseIn: Rect(x: 0, y: 0, width: 100, height: 100))
        let result = original.simplified(tolerance: 0.5)

        // Should produce a reasonable approximation (move + curves + close)
        #expect(!result.isEmpty)

        // The simplified path should have similar bounds
        let originalBounds = original.bounds
        let resultBounds = result.bounds
        #expect(abs(originalBounds.minX - resultBounds.minX) < 2.0)
        #expect(abs(originalBounds.minY - resultBounds.minY) < 2.0)
        #expect(abs(originalBounds.maxX - resultBounds.maxX) < 2.0)
        #expect(abs(originalBounds.maxY - resultBounds.maxY) < 2.0)
    }

    @Test func closedPathStaysClosed() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 100, y: 0))
        path.addLine(to: Point(x: 100, y: 100))
        path.addLine(to: Point(x: 0, y: 100))
        path.closeSubpath()

        let result = path.simplified(tolerance: 2.5)

        // Should still end with closeSubpath
        #expect(result.elements.last == .closeSubpath)
    }

    // MARK: - Tolerance behavior

    @Test func tighterToleranceProducesMoreSegments() {
        let path = BezierPath(ellipseIn: Rect(x: 0, y: 0, width: 100, height: 100))
        let loose = path.simplified(tolerance: 10.0)
        let tight = path.simplified(tolerance: 0.1)

        #expect(tight.count >= loose.count)
    }

    // MARK: - Multi-subpath handling

    @Test func multipleSubpathsSimplifiedIndependently() {
        var path = BezierPath()
        // Subpath 1
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 50, y: 0))
        path.addLine(to: Point(x: 50, y: 50))
        path.closeSubpath()
        // Subpath 2
        path.move(to: Point(x: 200, y: 200))
        path.addLine(to: Point(x: 250, y: 200))
        path.addLine(to: Point(x: 250, y: 250))
        path.closeSubpath()

        let result = path.simplified(tolerance: 2.5)

        // Should have two move-to elements (one per subpath)
        let moveCount = result.elements.filter {
            if case .move = $0 { return true }
            return false
        }.count
        #expect(moveCount == 2)

        // Should have two closeSubpath elements
        let closeCount = result.elements.filter { $0 == .closeSubpath }.count
        #expect(closeCount == 2)
    }
}
