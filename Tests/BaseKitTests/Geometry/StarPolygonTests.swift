import BaseKit
import Testing

struct StarPolygonTests {

    private let threshold = 1e-6

    // MARK: - Regular polygons (ratio 1.0)

    @Test
    func triangleHasThreeVertices() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 3
        )
        #expect(points.count == 3)
    }

    @Test
    func triangleFirstVertexAtTop() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 3
        )
        #expect(points[0].isClose(to: Point(x: 0, y: -100), threshold: threshold))
    }

    @Test
    func triangleVerticesEquidistantFromCenter() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 3
        )
        for point in points {
            #expect(point.distance(to: .zero).isClose(to: 100, threshold: threshold))
        }
    }

    @Test
    func squareHasFourVertices() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 4
        )
        #expect(points.count == 4)
        #expect(points[0].isClose(to: Point(x: 0, y: -100), threshold: threshold))
        #expect(points[1].isClose(to: Point(x: 100, y: 0), threshold: threshold))
        #expect(points[2].isClose(to: Point(x: 0, y: 100), threshold: threshold))
        #expect(points[3].isClose(to: Point(x: -100, y: 0), threshold: threshold))
    }

    @Test
    func pentagonHasFiveVertices() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 5
        )
        #expect(points.count == 5)
        #expect(points[0].isClose(to: Point(x: 0, y: -100), threshold: threshold))
        for point in points {
            #expect(point.distance(to: .zero).isClose(to: 100, threshold: threshold))
        }
    }

    // MARK: - Stars

    @Test
    func fivePointedStarHasTenVertices() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 0.382,
            pointCount: 5
        )
        #expect(points.count == 10)
    }

    @Test
    func fivePointedStarAlternatesRadii() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 0.382,
            pointCount: 5
        )
        for i in 0..<5 {
            let outerPoint = points[i * 2]
            let innerPoint = points[i * 2 + 1]
            #expect(outerPoint.distance(to: .zero).isClose(to: 100, threshold: threshold))
            #expect(innerPoint.distance(to: .zero).isClose(to: 38.2, threshold: threshold))
        }
    }

    @Test
    func fivePointedStarFirstVertexAtTop() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 0.382,
            pointCount: 5
        )
        #expect(points[0].isClose(to: Point(x: 0, y: -100), threshold: threshold))
    }

    @Test
    func sixPointedStarHasTwelveVertices() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 0.577,
            pointCount: 6
        )
        #expect(points.count == 12)
        for i in 0..<6 {
            let outerPoint = points[i * 2]
            let innerPoint = points[i * 2 + 1]
            #expect(outerPoint.distance(to: .zero).isClose(to: 100, threshold: threshold))
            #expect(innerPoint.distance(to: .zero).isClose(to: 57.7, threshold: threshold))
        }
    }

    // MARK: - Clamping

    @Test
    func pointCountClampedToMinimumThree() {
        let points1 = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 1
        )
        #expect(points1.count == 3)

        let points2 = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 2
        )
        #expect(points2.count == 3)
    }

    @Test
    func innerRadiusRatioClampedToValidRange() {
        let pointsNegative = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: -0.5,
            pointCount: 5
        )
        #expect(pointsNegative.count == 10)
        for i in 0..<5 {
            let innerPoint = pointsNegative[i * 2 + 1]
            #expect(innerPoint.distance(to: .zero).isClose(to: 0, threshold: threshold))
        }

        let pointsOver = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.5,
            pointCount: 5
        )
        // Clamped to 1.0, so regular polygon with 5 vertices
        #expect(pointsOver.count == 5)
    }

    // MARK: - Custom rotation

    @Test
    func zeroRotationPlacesFirstVertexAtRight() {
        let points = StarPolygon.points(
            center: .zero,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 4,
            rotation: .zero
        )
        #expect(points[0].isClose(to: Point(x: 100, y: 0), threshold: threshold))
    }

    // MARK: - Custom center

    @Test
    func verticesOffsetByCenter() {
        let center = Point(x: 50, y: 75)
        let points = StarPolygon.points(
            center: center,
            outerRadius: 100,
            innerRadiusRatio: 1.0,
            pointCount: 4
        )
        #expect(points[0].isClose(to: Point(x: 50, y: -25), threshold: threshold))
        #expect(points[1].isClose(to: Point(x: 150, y: 75), threshold: threshold))
        #expect(points[2].isClose(to: Point(x: 50, y: 175), threshold: threshold))
        #expect(points[3].isClose(to: Point(x: -50, y: 75), threshold: threshold))
    }

    // MARK: - Zero outer radius

    @Test
    func zeroOuterRadiusCollapsesToCenter() {
        let center = Point(x: 30, y: 40)
        let points = StarPolygon.points(
            center: center,
            outerRadius: 0,
            innerRadiusRatio: 0.5,
            pointCount: 5
        )
        #expect(points.count == 10)
        for point in points {
            #expect(point.isClose(to: center, threshold: threshold))
        }
    }
}
