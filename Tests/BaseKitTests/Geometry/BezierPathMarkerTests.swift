import Testing
import Foundation
@testable import BaseKit

struct BezierPathMarkerTests {
    @Test
    func simpleLine_producesTwoVertices() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 100, y: 0))

        let vertices = path.markerVertices()
        #expect(vertices.count == 2)
        #expect(vertices[0].position == .start)
        #expect(vertices[0].point == Point(x: 0, y: 0))
        #expect(vertices[0].angle.isClose(to: 0, threshold: 1e-10))
        #expect(vertices[1].position == .end)
        #expect(vertices[1].point == Point(x: 100, y: 0))
        #expect(vertices[1].angle.isClose(to: 0, threshold: 1e-10))
    }

    @Test
    func polyline_producesStartMidEndVertices() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addLine(to: Point(x: 50, y: 0))
        path.addLine(to: Point(x: 100, y: 0))

        let vertices = path.markerVertices()
        #expect(vertices.count == 3)
        #expect(vertices[0].position == .start)
        #expect(vertices[1].position == .mid)
        #expect(vertices[1].point == Point(x: 50, y: 0))
        #expect(vertices[2].position == .end)
    }

    @Test
    func closedRect_allVerticesAreMid() {
        let path = BezierPath(rect: Rect(x: 0, y: 0, width: 100, height: 100))

        let vertices = path.markerVertices()
        #expect(!vertices.isEmpty)
        for vertex in vertices {
            #expect(vertex.position == .mid)
        }
    }

    @Test
    func cubicCurve_tangentFromControlPoints() {
        var path = BezierPath()
        path.move(to: Point(x: 0, y: 0))
        path.addCurve(
            to: Point(x: 100, y: 0),
            controlPoint1: Point(x: 0, y: 50),
            controlPoint2: Point(x: 100, y: 50)
        )

        let vertices = path.markerVertices()
        #expect(vertices.count == 2)
        // Start tangent: from (0,0) to (0,50) = pointing up = π/2
        #expect(vertices[0].angle.isClose(to: .pi / 2.0, threshold: 1e-10))
        // End tangent: from (100,50) to (100,0) = pointing down = -π/2
        #expect(vertices[1].angle.isClose(to: -.pi / 2.0, threshold: 1e-10))
    }

    @Test
    func emptyPath_noVertices() {
        let path = BezierPath()
        let vertices = path.markerVertices()
        #expect(vertices.isEmpty)
    }

    @Test
    func singleMove_noVertices() {
        var path = BezierPath()
        path.move(to: Point(x: 10, y: 20))
        let vertices = path.markerVertices()
        #expect(vertices.isEmpty)
    }
}

private extension Double {
    func isClose(to other: Double, threshold: Double) -> Bool {
        abs(self - other) < threshold
    }
}
