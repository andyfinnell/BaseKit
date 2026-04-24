import Foundation

public enum StarPolygon {

    /// Computes the vertices of a star or regular polygon.
    ///
    /// - Parameters:
    ///   - center: The center point of the star.
    ///   - outerRadius: Distance from center to the outer tips.
    ///   - innerRadiusRatio: Ratio of inner radius to outer radius (clamped to 0...1).
    ///     A value of 1.0 produces a regular polygon. Values closer to 0 produce sharper points.
    ///   - pointCount: Number of star points or polygon sides (clamped to minimum of 3).
    ///   - rotation: Angle of the first outer vertex. Defaults to -π/2 (top of shape).
    /// - Returns: Array of vertices. A regular polygon (ratio 1.0) has `pointCount` vertices.
    ///   A star has `2 * pointCount` vertices alternating between outer and inner radii.
    public static func points(
        center: Point,
        outerRadius: Real,
        innerRadiusRatio: Real,
        pointCount: Int,
        rotation: Angle = Angle(radians: -.pi / 2)
    ) -> [Point] {
        let count = max(pointCount, 3)
        let ratio = min(max(innerRadiusRatio, 0), 1)

        if ratio == 1.0 {
            return polygonPoints(
                center: center,
                radius: outerRadius,
                sideCount: count,
                rotation: rotation
            )
        } else {
            return starPoints(
                center: center,
                outerRadius: outerRadius,
                innerRadius: outerRadius * ratio,
                pointCount: count,
                rotation: rotation
            )
        }
    }
}

private extension StarPolygon {

    static func polygonPoints(
        center: Point,
        radius: Real,
        sideCount: Int,
        rotation: Angle
    ) -> [Point] {
        let angleStep = 2.0 * .pi / Real(sideCount)
        return (0..<sideCount).map { k in
            let angle = rotation.radians + angleStep * Real(k)
            return Point(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
        }
    }

    static func starPoints(
        center: Point,
        outerRadius: Real,
        innerRadius: Real,
        pointCount: Int,
        rotation: Angle
    ) -> [Point] {
        let outerAngleStep = 2.0 * .pi / Real(pointCount)
        let innerOffset = .pi / Real(pointCount)
        var result = [Point]()
        result.reserveCapacity(pointCount * 2)

        for k in 0..<pointCount {
            let outerAngle = rotation.radians + outerAngleStep * Real(k)
            result.append(Point(
                x: center.x + outerRadius * cos(outerAngle),
                y: center.y + outerRadius * sin(outerAngle)
            ))

            let innerAngle = outerAngle + innerOffset
            result.append(Point(
                x: center.x + innerRadius * cos(innerAngle),
                y: center.y + innerRadius * sin(innerAngle)
            ))
        }

        return result
    }
}
