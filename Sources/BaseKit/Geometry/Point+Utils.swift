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
    
    func distance(to point2: Point) -> Real {
        let xDelta = point2.x - x
        let yDelta = point2.y - y
        
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
    
    func applying(_ t: Transform) -> Point {
        // result[row, column] = p[row][0]*m[0][column] + p[row][1] * m[1][column] + p[row][2] * m[2][column]
        
        let p = [[x, y, 1.0]]
        let m = [[t.a, t.b, 0.0],
                 [t.c, t.d, 0.0],
                 [t.translateX,t.translateY,1.0]]
        
        let result = [
            p[0][0] * m[0][0] + p[0][1] * m[1][0] + p[0][2] * m[2][0],
            p[0][0] * m[0][1] + p[0][1] * m[1][1] + p[0][2] * m[2][1],
            p[0][0] * m[0][2] + p[0][1] * m[1][2] + p[0][2] * m[2][2],
        ]
        
        return Point(x: result[0], y: result[1])
    }
}

/// The three points are a counter-clockwise turn if the return value is greater than 0,
///  clockwise if less than 0, or colinear if 0.
/// We're calculating the signed area of the triangle formed by the three points. Well,
///  almost the area of the triangle -- we'd need to divide by 2. But since we only
///  care about the direction (i.e. the sign) dividing by 2 is an unnecessary step.
/// See http://mathworld.wolfram.com/TriangleArea.html for the signed area of a triangle.
public func counterClockwiseTurn(_ point1: Point, _ point2: Point, _ point3: Point) -> Real {
    let xDeltaA = point2.x - point1.x
    let yDeltaB = point3.y - point1.y
    let yDeltaC = point2.y - point1.y
    let xDeltaD = point3.x - point1.x
    
    return xDeltaA * yDeltaB - yDeltaC * xDeltaD
}

public func isColinear(_ point1: Point, _ point2: Point, _ point3: Point) -> Bool {
    counterClockwiseTurn(point1, point2, point3).isClose(to: 0.0, threshold: 1e-6)
}
