import Foundation


public func *(lhs: Point, rhs: Real) -> Point {
    .init(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func /(lhs: Point, rhs: Real) -> Point {
    .init(x: lhs.x / rhs, y: lhs.y / rhs)
}

extension Point: AdditiveArithmetic {
    public static func +(lhs: Point, rhs: Point) -> Point {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func -(lhs: Point, rhs: Point) -> Point {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

public extension Point {
    var vectorLength: Real {
        distance(to: .zero)
    }
    
    var normalizedVector: Point {
        let length = vectorLength
        guard length != 0.0 else {
            return self
        }
        return self / length
    }
    
    func distance(to point2: Point) -> Double {
        let xDelta = Double(point2.x - x)
        let yDelta = Double(point2.y - y)
        
        return sqrt(xDelta * xDelta + yDelta * yDelta)
    }

    func unitScale(_ scale: Double) -> Point {
        var result = self
        let length = vectorLength
        if length != 0.0 {
            result.x = result.x * (scale / length)
            result.y = result.y * (scale / length)
        }
        return result
    }

    func dotMultiply(_ point2: Point) -> Double {
        let dotX = Double(x) * Double(point2.x)
        let dotY = Double(y) * Double(point2.y)
        return dotX + dotY
    }

    func normal(to lineEnd: Point) -> Point {
        Point(
            x: -(lineEnd.y - y),
            y: lineEnd.x - x).normalizedVector
    }
    
    func midpoint(to lineEnd: Point) -> Point {
        let distance = self.distance(to: lineEnd)
        let tangent = (lineEnd - self).normalizedVector
        return self + tangent.unitScale(distance / 2.0)
    }

    func expandBounds(topLeft: inout Point, bottomRight: inout Point) {
        topLeft.x = min(x, topLeft.x)
        topLeft.y = min(y, topLeft.y)
        bottomRight.x = max(x, bottomRight.x)
        bottomRight.y = max(y, bottomRight.y)
    }

    func isClose(to point2: Point, threshold: Double) -> Bool {
        x.isClose(to: point2.x, threshold: threshold)
        && y.isClose(to: point2.y, threshold: threshold)
    }

    static prefix func - (point: Point) -> Point {
        Point(x: -point.x, y: -point.y)
    }
}

/// The three points are a counter-clockwise turn if the return value is greater than 0,
///  clockwise if less than 0, or colinear if 0.
/// We're calculating the signed area of the triangle formed by the three points. Well,
///  almost the area of the triangle -- we'd need to divide by 2. But since we only
///  care about the direction (i.e. the sign) dividing by 2 is an unnecessary step.
/// See http://mathworld.wolfram.com/TriangleArea.html for the signed area of a triangle.
public func counterClockwiseTurn(_ point1: Point, _ point2: Point, _ point3: Point) -> Double {
    
    let xDeltaA = Double(point2.x - point1.x)
    let yDeltaB = Double(point3.y - point1.y)
    let yDeltaC = Double(point2.y - point1.y)
    let xDeltaD = Double(point3.x - point1.x)
    
    return xDeltaA * yDeltaB - yDeltaC * xDeltaD
}
