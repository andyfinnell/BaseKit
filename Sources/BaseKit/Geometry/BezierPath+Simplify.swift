public extension BezierPath {
    /// Returns a new path with fewer control points that approximates this path
    /// within the given tolerance, using Schneider's curve fitting algorithm.
    ///
    /// The algorithm flattens each subpath into a dense polyline, then fits
    /// cubic Bezier curves back to the polyline with the fewest segments needed
    /// to stay within `tolerance` distance of the original points.
    func simplified(tolerance: Real) -> BezierPath {
        let subpaths = splitIntoSubpaths()
        guard !subpaths.isEmpty else { return self }

        var result = BezierPath()
        for subpath in subpaths {
            let points = flattenSubpath(subpath.elements, isClosed: subpath.isClosed)
            guard points.count >= 2 else {
                // Too few points — copy original elements through
                result.append(contentsOf: BezierPath(elements: subpath.elements))
                if subpath.isClosed {
                    result.closeSubpath()
                }
                continue
            }

            let fitted = fitCubicToRange(
                points: points,
                range: 0..<points.count,
                leftTangent: computeLeftTangent(points: points, index: 0),
                rightTangent: computeRightTangent(points: points, index: points.count - 1),
                tolerance: tolerance * tolerance // algorithm uses squared error
            )

            result.move(to: fitted[0].start)
            for segment in fitted {
                result.addCurve(
                    to: segment.end,
                    controlPoint1: segment.control1,
                    controlPoint2: segment.control2
                )
            }
            if subpath.isClosed {
                result.closeSubpath()
            }
        }
        return result
    }
}

// MARK: - Subpath splitting

private struct Subpath {
    let elements: [BezierPath.Element]
    let isClosed: Bool
}

private extension BezierPath {
    func splitIntoSubpaths() -> [Subpath] {
        var subpaths = [Subpath]()
        var current = [Element]()
        var isClosed = false

        for element in elements {
            switch element {
            case .move:
                if !current.isEmpty {
                    subpaths.append(Subpath(elements: current, isClosed: isClosed))
                    current = []
                    isClosed = false
                }
                current.append(element)
            case .line, .curve:
                current.append(element)
            case .closeSubpath:
                isClosed = true
                if !current.isEmpty {
                    subpaths.append(Subpath(elements: current, isClosed: isClosed))
                    current = []
                    isClosed = false
                }
            }
        }

        if !current.isEmpty {
            subpaths.append(Subpath(elements: current, isClosed: isClosed))
        }

        return subpaths
    }
}

// MARK: - Flattening

private let samplesPerCurve = 20

/// Flattens a subpath's elements into a dense polyline by sampling cubic curves.
private func flattenSubpath(_ elements: [BezierPath.Element], isClosed: Bool) -> [Point] {
    var points = [Point]()
    var currentPoint: Point?
    var startPoint: Point?

    for element in elements {
        switch element {
        case let .move(to: point):
            startPoint = point
            currentPoint = point
            points.append(point)

        case let .line(to: point):
            // Only add the endpoint (current point is already in the list)
            points.append(point)
            currentPoint = point

        case let .curve(to: end, control1: cp1, control2: cp2):
            guard let start = currentPoint else { continue }
            // Sample the cubic at uniform parameter increments, skipping t=0
            // (the start point is already in the list)
            let bezierPoints = [start, cp1, cp2, end]
            for i in 1...samplesPerCurve {
                let t = Real(i) / Real(samplesPerCurve)
                let (point, _, _) = Bezier.splitBezier(bezierPoints, ofDegree: 3, at: t)
                points.append(point)
            }
            currentPoint = end

        case .closeSubpath:
            break // handled by caller
        }
    }

    // For closed paths, ensure the last point matches the first for a clean loop
    if isClosed, let start = startPoint, let last = points.last, start != last {
        points.append(start)
    }

    return points
}

// MARK: - Schneider curve fitting

private struct CubicSegment {
    let start: Point
    let control1: Point
    let control2: Point
    let end: Point
}

private let maxReparameterizations = 4

/// Recursively fits cubic Bezier segments to a range of points.
private func fitCubicToRange(
    points: [Point],
    range: Range<Int>,
    leftTangent: Point,
    rightTangent: Point,
    tolerance: Real
) -> [CubicSegment] {
    let count = range.count

    // Base case: only two points — use the naive chord/3 heuristic
    if count == 2 {
        return [naiveFit(
            start: points[range.lowerBound],
            end: points[range.upperBound - 1],
            leftTangent: leftTangent,
            rightTangent: rightTangent
        )]
    }

    // Try fitting a single cubic to all points in the range
    var parameters = chordLengthParameterize(points: points, range: range)
    var bezier = fitBezier(
        points: points, range: range, parameters: parameters,
        leftTangent: leftTangent, rightTangent: rightTangent
    )

    var (maxError, splitIndex) = computeMaxError(
        points: points, range: range, bezier: bezier, parameters: parameters
    )
    if maxError < tolerance {
        return [bezier]
    }

    // If the error isn't catastrophically bad, try reparameterizing
    if maxError < tolerance * tolerance {
        for _ in 0..<maxReparameterizations {
            parameters = reparameterize(
                points: points, range: range, parameters: parameters, bezier: bezier
            )
            bezier = fitBezier(
                points: points, range: range, parameters: parameters,
                leftTangent: leftTangent, rightTangent: rightTangent
            )
            (maxError, splitIndex) = computeMaxError(
                points: points, range: range, bezier: bezier, parameters: parameters
            )
            if maxError < tolerance {
                return [bezier]
            }
        }
    }

    // Split at the point of maximum error and recurse
    let centerTangent = computeCenterTangent(points: points, index: splitIndex)
    let leftResult = fitCubicToRange(
        points: points,
        range: range.lowerBound..<(splitIndex + 1),
        leftTangent: leftTangent,
        rightTangent: centerTangent,
        tolerance: tolerance
    )
    let rightResult = fitCubicToRange(
        points: points,
        range: splitIndex..<range.upperBound,
        leftTangent: -centerTangent,
        rightTangent: rightTangent,
        tolerance: tolerance
    )
    return leftResult + rightResult
}

// MARK: - Fitting a single cubic

/// Fits a single cubic Bezier to the points in `range` using least-squares.
private func fitBezier(
    points: [Point],
    range: Range<Int>,
    parameters: [Real],
    leftTangent: Point,
    rightTangent: Point
) -> CubicSegment {
    let start = points[range.lowerBound]
    let end = points[range.upperBound - 1]

    // Build the C and X matrices for the least-squares system
    var c11: Real = 0, c12: Real = 0, c22: Real = 0
    var x1: Real = 0, x2: Real = 0

    for i in 0..<range.count {
        let t = parameters[i]
        let b1 = bernstein1(t)
        let b2 = bernstein2(t)

        let a1 = leftTangent * b1
        let a2 = rightTangent * b2

        c11 += a1.dotMultiply(a1)
        c12 += a1.dotMultiply(a2)
        c22 += a2.dotMultiply(a2)

        let b0 = bernstein0(t)
        let b3 = bernstein3(t)
        let predicted = start * (b0 + b1) + end * (b2 + b3)
        let diff = points[range.lowerBound + i] - predicted

        x1 += a1.dotMultiply(diff)
        x2 += a2.dotMultiply(diff)
    }

    // Solve for alpha values
    let det = c11 * c22 - c12 * c12
    let chordLength = start.distance(to: end)
    let fallback = chordLength / 3.0

    let alpha1: Real
    let alpha2: Real
    if abs(det) < 1e-10 {
        alpha1 = fallback
        alpha2 = fallback
    } else {
        let rawAlpha1 = (c22 * x1 - c12 * x2) / det
        let rawAlpha2 = (c11 * x2 - c12 * x1) / det

        // Negative or very small alphas produce twisted curves — fall back
        let verySmall = 1e-6 * chordLength
        if rawAlpha1 < verySmall || rawAlpha2 < verySmall {
            return naiveFit(
                start: start, end: end,
                leftTangent: leftTangent, rightTangent: rightTangent
            )
        }
        alpha1 = rawAlpha1
        alpha2 = rawAlpha2
    }

    let cp1 = start + leftTangent.normalizedVector * alpha1
    let cp2 = end + rightTangent.normalizedVector * alpha2
    return CubicSegment(start: start, control1: cp1, control2: cp2, end: end)
}

/// Naive fallback: place control points at chord/3 along the tangent directions.
private func naiveFit(
    start: Point,
    end: Point,
    leftTangent: Point,
    rightTangent: Point
) -> CubicSegment {
    let dist = start.distance(to: end) / 3.0
    let cp1 = start + leftTangent.unitScale(dist)
    let cp2 = end + rightTangent.unitScale(dist)
    return CubicSegment(start: start, control1: cp1, control2: cp2, end: end)
}

// MARK: - Parameterization

/// Estimates parameters using chord-length method.
private func chordLengthParameterize(points: [Point], range: Range<Int>) -> [Real] {
    var distances = [Real](repeating: 0, count: range.count)
    for i in 1..<range.count {
        distances[i] = distances[i - 1]
            + points[range.lowerBound + i].distance(to: points[range.lowerBound + i - 1])
    }
    let totalDistance = distances[range.count - 1]
    guard totalDistance > 0 else {
        // All points coincide — distribute evenly
        return (0..<range.count).map { Real($0) / Real(range.count - 1) }
    }
    return distances.map { $0 / totalDistance }
}

/// Refines parameters using Newton's method.
private func reparameterize(
    points: [Point],
    range: Range<Int>,
    parameters: [Real],
    bezier: CubicSegment
) -> [Real] {
    parameters.enumerated().map { i, t in
        newtonsMethod(bezier: bezier, point: points[range.lowerBound + i], parameter: t)
    }
}

/// Single Newton-Raphson step to refine a parameter value.
private func newtonsMethod(bezier: CubicSegment, point: Point, parameter: Real) -> Real {
    let bezierPoints = [bezier.start, bezier.control1, bezier.control2, bezier.end]

    // Q(t)
    let (qAtT, _, _) = Bezier.splitBezier(bezierPoints, ofDegree: 3, at: parameter)

    // Q'(t) — first derivative (degree 2)
    let qPrimePoints = (0..<3).map { i in
        Point(
            x: (bezierPoints[i + 1].x - bezierPoints[i].x) * 3.0,
            y: (bezierPoints[i + 1].y - bezierPoints[i].y) * 3.0
        )
    }
    let (qPrimeAtT, _, _) = Bezier.splitBezier(qPrimePoints, ofDegree: 2, at: parameter)

    // Q''(t) — second derivative (degree 1)
    let qPrimePrimePoints = (0..<2).map { i in
        Point(
            x: (qPrimePoints[i + 1].x - qPrimePoints[i].x) * 2.0,
            y: (qPrimePoints[i + 1].y - qPrimePoints[i].y) * 2.0
        )
    }
    let (qPrimePrimeAtT, _, _) = Bezier.splitBezier(qPrimePrimePoints, ofDegree: 1, at: parameter)

    // f(t) = (Q(t) - point) · Q'(t)
    let diff = qAtT - point
    let fAtT = diff.dotMultiply(qPrimeAtT)

    // f'(t) = (Q(t) - point) · Q''(t) + Q'(t) · Q'(t)
    let fPrimeAtT = diff.dotMultiply(qPrimePrimeAtT) + qPrimeAtT.dotMultiply(qPrimeAtT)

    guard abs(fPrimeAtT) > 1e-15 else { return parameter }
    return parameter - (fAtT / fPrimeAtT)
}

// MARK: - Error computation

/// Finds the point with the maximum squared error and returns (error, index).
private func computeMaxError(
    points: [Point],
    range: Range<Int>,
    bezier: CubicSegment,
    parameters: [Real]
) -> (maxError: Real, splitIndex: Int) {
    let bezierPoints = [bezier.start, bezier.control1, bezier.control2, bezier.end]
    var maxError: Real = 0
    var splitIndex = range.lowerBound + (range.count / 2)

    for i in 1..<(range.count - 1) {
        let (pointOnCurve, _, _) = Bezier.splitBezier(bezierPoints, ofDegree: 3, at: parameters[i])
        let diff = pointOnCurve - points[range.lowerBound + i]
        let distSquared = diff.dotMultiply(diff)
        if distSquared >= maxError {
            maxError = distSquared
            splitIndex = range.lowerBound + i
        }
    }
    return (maxError, splitIndex)
}

// MARK: - Tangent computation

private func computeLeftTangent(points: [Point], index: Int) -> Point {
    (points[index + 1] - points[index]).normalizedVector
}

private func computeRightTangent(points: [Point], index: Int) -> Point {
    (points[index - 1] - points[index]).normalizedVector
}

private func computeCenterTangent(points: [Point], index: Int) -> Point {
    let v1 = points[index - 1] - points[index]
    let v2 = points[index] - points[index + 1]
    let average = Point(x: (v1.x + v2.x) / 2.0, y: (v1.y + v2.y) / 2.0)
    return average.normalizedVector
}

// MARK: - Bernstein polynomials

private func bernstein0(_ t: Real) -> Real {
    let oneMinusT = 1.0 - t
    return oneMinusT * oneMinusT * oneMinusT
}

private func bernstein1(_ t: Real) -> Real {
    let oneMinusT = 1.0 - t
    return 3.0 * t * oneMinusT * oneMinusT
}

private func bernstein2(_ t: Real) -> Real {
    return 3.0 * t * t * (1.0 - t)
}

private func bernstein3(_ t: Real) -> Real {
    return t * t * t
}
