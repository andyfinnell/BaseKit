import Foundation

public enum Bezier {
    
    /// Calculate a point on the bezier curve passed in, specifically the point at parameter.
    ///  We're using De Casteljau's algorithm, which not only calculates the point at parameter
    ///  in a numerically stable way, it also computes the two resulting bezier curves that
    ///  would be formed if the original were split at the parameter specified.
    ///
    /// See: http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/Bezier/de-casteljau.html
    ///  for an explaination of De Casteljau's algorithm.
    ///
    /// bezierPoints, leftCurve, rightCurve will have a length of degree + 1.
    /// degree is the order of the bezier path, which will be cubic (3) most of the time.
    public static func splitBezier(_ bezierPoints: [Point], ofDegree degree: Int, at parameter: Real) -> (point: Point, leftCurve: [Point], rightCurve: [Point]) {
        // With this algorithm we start out with the points in the bezier path.
        var points = Array(bezierPoints[0...degree])
        var leftArray = Array(repeating: Point.zero, count: degree + 1)
        var rightArray = Array(repeating: Point.zero, count: degree + 1)
        
        // If the caller is asking for the resulting bezier curves, start filling those in
        leftArray[0] = points[0]
        rightArray[degree] = points[degree]
        
        for k in 1...degree {
            for i in 0...(degree - k) {
                points[i].x = (1.0 - parameter) * points[i].x + parameter * points[i + 1].x
                points[i].y = (1.0 - parameter) * points[i].y + parameter * points[i + 1].y
            }
            leftArray[k] = points[0]
            rightArray[degree - k] = points[degree - k]
        }
        
        // The point in the curve at parameter ends up in points[0]
        return (point: points[0], leftCurve: leftArray, rightCurve: rightArray)
    }

    public static func findRoots(for bezierPoints: [Point], ofDegree degree: Int) -> [Real] {
        var results = [Real]()
        findRoots(for: bezierPoints, ofDegree: degree, atDepth: 0, into: &results)
        return results
    }
    
    public static func closestLocation(on bezierPoints: [Point], to point: Point) -> BezierCurveLocation {
        let relatedBezier = convertBezier(bezierPoints, relativeTo: point)
                
        let locations = ([
            BezierCurveLocation(parameter: 0, distance: abs(bezierPoints[0].distance(to: point))),
            BezierCurveLocation(parameter: 1, distance: abs(bezierPoints[3].distance(to: point))),
        ] + findRoots(for: relatedBezier, ofDegree: 5)
            .map { root in
                let split = splitBezier(bezierPoints, ofDegree: 3, at: root)
                return BezierCurveLocation(parameter: root, distance: abs(split.point.distance(to: point)))
            })
            .sorted { $0.distance < $1.distance }
        
        return locations[0]
    }
    
    public static func convertLineToCubicBezier(start: Point, end: Point) -> [Point] {
        // Convert the line into a bezier curve to keep our intersection algorithm general (i.e. only
        //  has to deal with curves, not lines). As long as the control points are colinear with the
        //  end points, it'll be a line. But for consistency sake, we put the control points inside
        //  the end points, 1/3 of the total distance away from their respective end point.
        let distance = start.distance(to: end)
        let leftTangent = (end - start).normalizedVector
        return [
            start,
            start + leftTangent.unitScale(distance / 3.0),
            start + leftTangent.unitScale(2.0 * distance / 3.0),
            end,
        ]
    }
    
    public static func computeBoundingBoxForLine(start: Point, end: Point) -> Rect {
        var topLeft = start
        var bottomRight = topLeft
        end.expandBounds(topLeft: &topLeft, bottomRight: &bottomRight)
        return Rect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }
    
    public static func computeBoundingBoxForCubicBezier(_ bezierPoints: [Point]) -> Rect {        
        // Start with the end points
        var (topLeft, _, _) = splitBezier(bezierPoints, ofDegree: 3, at: 0)
        var bottomRight = topLeft
        let (lastPoint, _, _) = splitBezier(bezierPoints, ofDegree: 3, at: 1)
        
        lastPoint.expandBounds(topLeft: &topLeft, bottomRight: &bottomRight)
        
        // Find the roots, which should be the extremities
        let xRoots = computeCubicFirstDerivativeRoots(
            a: bezierPoints[0].x,
            b: bezierPoints[1].x,
            c: bezierPoints[2].x,
            d: bezierPoints[3].x
        )
        
        for t in xRoots {
            if t < 0 || t > 1 {
                continue
            }
            let (location, _, _) = splitBezier(bezierPoints, ofDegree: 3, at: t)
            location.expandBounds(topLeft: &topLeft, bottomRight: &bottomRight)
        }
        
        let yRoots = computeCubicFirstDerivativeRoots(
            a: bezierPoints[0].y,
            b: bezierPoints[1].y,
            c: bezierPoints[2].y,
            d: bezierPoints[3].y
        )
        for t in yRoots {
            if t < 0 || t > 1 {
                continue
            }
            let (location, _, _) = splitBezier(bezierPoints, ofDegree: 3, at: t)
            location.expandBounds(topLeft: &topLeft, bottomRight: &bottomRight)
        }
        
        return Rect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }
}

private extension Bezier {
    static func computeCubicFirstDerivativeRoots(a: Real, b: Real, c: Real, d: Real) -> [Real] {
        // See http://processingjs.nihongoresources.com/bezierinfo/#bounds for where the formulas come from
        
        let denominator = -a + 3.0 * b - 3.0 * c + d
        
        // If denominator == 0, fall back to
        if denominator.isClose(to: 0.0, threshold: 1e-9) {
            let t = (a - b) / (2.0 * (a - 2.0 * b + c))
            return [t]
        } else {
            let numeratorLeft = -a + 2.0 * b - c
            
            let v1 = -a * (c - d)
            let v2 = b * b
            let v3 = b * (c + d)
            let v4 = c * c
            let numeratorRight = -1.0 * sqrt(v1 + v2 - v3 + v4)
            
            let t1 = (numeratorLeft + numeratorRight) / denominator
            let t2 = (numeratorLeft - numeratorRight) / denominator
            return [t1, t2]
        }
    }

    static func convertBezier(_ bezierPoints: [Point], relativeTo point: Point) -> [Point] {
        // c[i] in the paper
        let distanceFromPoint = [
            bezierPoints[0] - point,
            bezierPoints[1] - point,
            bezierPoints[2] - point,
            bezierPoints[3] - point
        ]
        
        // d[i] in the paper
        let weightedDelta = [
            (bezierPoints[1] - bezierPoints[0]) * 3,
            (bezierPoints[2] - bezierPoints[1]) * 3,
            (bezierPoints[3] - bezierPoints[2]) * 3
        ]
        
        // Precompute the dot product of distanceFromPoint and weightedDelta in order to speed things up
        var precomputedTable: [[Real]] = [
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ]
        for row in 0 ..< 3 {
            for column in 0 ..< 4 {
                precomputedTable[row][column] = weightedDelta[row].dotMultiply(distanceFromPoint[column])
            }
        }
        
        // Precompute some of the values to speed things up
        let z: [[Real]] = [
            [1.0, 0.6, 0.3, 0.1],
            [0.4, 0.6, 0.6, 0.4],
            [0.1, 0.3, 0.6, 1.0]
        ]
        
        // create our output array
        var results = Array(repeating: Point.zero, count: 6)
        
        // Set the x values of the bezier points
        for i in 0 ..< 6 {
            results[i] = Point(x: Real(i) / 5.0, y: 0)
        }
        
        // Finally set the y values of the bezier points
        let n = 3
        let m = n - 1
        for k in 0...(n + m) {
            let lowerBound = max(0, k - m)
            let upperBound = min(k, n)
            for i in lowerBound...upperBound {
                let j = k - i
                results[i + j].y += Real(precomputedTable[j][i] * z[j][i])
            }
        }
        
        return results
    }

    static let findBezierRootsMaximumDepth = 64

    static func crossings(_ bezierPoints: [Point], degree: Int) -> Int {
        var count = 0
        var sign = bezierPoints[0].y.sign
        
        var previousSign = sign
        for i in 1...degree {
            sign = bezierPoints[i].y.sign
            if sign != previousSign {
                count += 1
            }
            previousSign = sign
        }
        return count
    }
    
    static func isControlPolygonFlatEnough(_ bezierPoints: [Point], degree: Int, intersectionPoint: inout Point) -> Bool {
        // 2^-63
        let findBezierRootsErrorThreshold = pow(Real(2), Real(-1 * (Bezier.findBezierRootsMaximumDepth - 1)))
        
        let line = NormalizedLine(point1: bezierPoints[0], point2: bezierPoints[degree])
        
        // Find the bounds around the line
        var belowDistance = 0.0
        var aboveDistance = 0.0
        for i in 1..<degree {
            let distance = line.distance(to: bezierPoints[i])
            if distance > aboveDistance {
                aboveDistance = distance
            }
            
            if distance < belowDistance {
                belowDistance = distance
            }
        }
        
        let zeroLine = NormalizedLine(a: 0.0, b: 1.0, c: 0.0)
        let aboveLine = line.offset(-aboveDistance)
        let intersect1 = zeroLine.intersectionWith(aboveLine)
        
        let belowLine = line.offset(-belowDistance)
        let intersect2 = zeroLine.intersectionWith(belowLine)
        
        let error = max(intersect1.x, intersect2.x) - min(intersect1.x, intersect2.x)
        if error < findBezierRootsErrorThreshold {
            intersectionPoint = zeroLine.intersectionWith(line)
            return true
        }
        
        return false
    }

    static func findRoots(for bezierPoints: [Point], ofDegree degree: Int, atDepth depth: Int, into results: inout [Real]) {
        let crossingCount = crossings(bezierPoints, degree: degree)
        guard crossingCount != 0 else {
            return
        }
        
        if crossingCount == 1 {
            if depth >= findBezierRootsMaximumDepth {
                let root = bezierPoints[0].x + bezierPoints[degree].x / 2.0
                results.append(root)
                return
            }
            var intersectionPoint = Point.zero
            if isControlPolygonFlatEnough(bezierPoints, degree: degree, intersectionPoint: &intersectionPoint) {
                results.append(intersectionPoint.x)
                return
            }
        }
        
        // Subdivide and try again
        let splitResult = splitBezier(bezierPoints, ofDegree: degree, at: 0.5)
        findRoots(for: splitResult.leftCurve, ofDegree: degree, atDepth: depth + 1, into: &results)
        findRoots(for: splitResult.rightCurve, ofDegree: degree, atDepth: depth + 1, into: &results)
    }
}
