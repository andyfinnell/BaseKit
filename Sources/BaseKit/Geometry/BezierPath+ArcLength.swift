extension BezierPath {
    /// Sample the path's point and unit tangent at the given arc-length
    /// position. `s` is measured from the start of the first subpath,
    /// walking each path element in order (cubics, lines, and
    /// `close` segments contribute; `move` is zero-length and just
    /// resets the current point).
    ///
    /// Returns nil when `s` is negative or exceeds `totalLength` —
    /// SVG 1.1 §10.13 specifies that glyphs whose center falls past
    /// the path's end aren't rendered, so the caller treats nil as
    /// "drop this glyph."
    ///
    /// The tangent is a unit vector pointing in the direction of
    /// increasing arc-length (line: end−start; cubic: derivative at
    /// the resolved parameter). Cubic segments are sampled in 16
    /// linear steps — the same resolution `BezierPath+Length`'s
    /// `cubicBezierLength` uses for the total. That's more than
    /// enough for textPath glyph placement; tighten if a fixture
    /// demands sub-pixel accuracy.
    public func pointAndTangent(atArcLength s: Real) -> (point: Point, tangent: Point)? {
        guard s >= 0 else { return nil }

        var accumulated: Real = 0
        var currentPoint = Point.zero
        var subpathStart = Point.zero

        for element in elements {
            switch element {
            case let .move(to: point):
                currentPoint = point
                subpathStart = point

            case let .line(to: point):
                if let result = pointAndTangentOnLine(
                    from: currentPoint, to: point,
                    accumulated: accumulated, target: s)
                {
                    return result
                }
                accumulated += currentPoint.distance(to: point)
                currentPoint = point

            case let .curve(to: end, control1: cp1, control2: cp2):
                if let result = pointAndTangentOnCubic(
                    from: currentPoint, control1: cp1, control2: cp2, to: end,
                    accumulated: accumulated, target: s)
                {
                    return result
                }
                accumulated += cubicLength(
                    from: currentPoint, control1: cp1, control2: cp2, to: end)
                currentPoint = end

            case .closeSubpath:
                if let result = pointAndTangentOnLine(
                    from: currentPoint, to: subpathStart,
                    accumulated: accumulated, target: s)
                {
                    return result
                }
                accumulated += currentPoint.distance(to: subpathStart)
                currentPoint = subpathStart
            }
        }

        return nil
    }
}

private extension BezierPath {
    /// Returns the (point, unit-tangent) for `target` if it falls on the
    /// line segment `from→to`, else nil. `accumulated` is the arc-length
    /// at `from`.
    func pointAndTangentOnLine(
        from start: Point, to end: Point,
        accumulated: Real, target: Real
    ) -> (point: Point, tangent: Point)? {
        let segmentLength = start.distance(to: end)
        guard accumulated + segmentLength >= target else { return nil }
        let local = target - accumulated
        let t = segmentLength > 0 ? local / segmentLength : 0
        let point = Point(
            x: start.x + (end.x - start.x) * t,
            y: start.y + (end.y - start.y) * t)
        let direction = end - start
        let length = direction.vectorLength
        // Zero-length line (consecutive identical points): fall back to
        // the +x axis so the caller still gets a defined orientation
        // rather than NaN-laden tangent components.
        let tangent = length > 0 ? direction / length : Point(x: 1, y: 0)
        return (point, tangent)
    }

    /// Returns the (point, unit-tangent) for `target` if it falls on
    /// the cubic Bézier `start→end` with controls `cp1`/`cp2`, else
    /// nil. `accumulated` is the arc-length at `start`. Uses the same
    /// 16-step polyline sampling as `BezierPath+Length`; finds the
    /// containing sub-segment, linearly interpolates the parameter
    /// `t`, then evaluates point and derivative at `t`.
    func pointAndTangentOnCubic(
        from start: Point, control1 cp1: Point, control2 cp2: Point, to end: Point,
        accumulated: Real, target: Real
    ) -> (point: Point, tangent: Point)? {
        let samples = cubicCumulativeLengths(
            from: start, control1: cp1, control2: cp2, to: end)
        let totalSegment = samples.last ?? 0
        guard accumulated + totalSegment >= target else { return nil }

        let local = target - accumulated
        let t: Real
        if totalSegment <= 0 {
            t = 0
        } else {
            // Binary search the cumulative-length table for the
            // sub-segment that brackets `local`, then linearly
            // interpolate the corresponding parameter t.
            let steps = samples.count - 1
            var lo = 0
            var hi = steps
            while lo + 1 < hi {
                let mid = (lo + hi) / 2
                if samples[mid] < local {
                    lo = mid
                } else {
                    hi = mid
                }
            }
            let sLo = samples[lo]
            let sHi = samples[hi]
            let segSpan = sHi - sLo
            let fraction = segSpan > 0 ? (local - sLo) / segSpan : 0
            let tLo = Real(lo) / Real(steps)
            let tHi = Real(hi) / Real(steps)
            t = tLo + fraction * (tHi - tLo)
        }

        let point = cubicPoint(at: t, start: start, cp1: cp1, cp2: cp2, end: end)
        let derivative = cubicDerivative(at: t, start: start, cp1: cp1, cp2: cp2, end: end)
        let derivativeLength = derivative.vectorLength
        let tangent =
            derivativeLength > 0
            ? derivative / derivativeLength
            : Point(x: 1, y: 0)
        return (point, tangent)
    }

    /// Cumulative arc-length samples of a cubic Bézier at 17 equally
    /// spaced parameter values t ∈ {0/16, 1/16, …, 16/16}. Element 0
    /// is always 0; element 16 is the polyline total. Same 16-step
    /// resolution used by `BezierPath+Length.cubicBezierLength`.
    func cubicCumulativeLengths(
        from p0: Point, control1 p1: Point, control2 p2: Point, to p3: Point
    ) -> [Real] {
        let steps = 16
        var lengths = [Real](repeating: 0, count: steps + 1)
        var previous = p0
        var total: Real = 0
        for i in 1...steps {
            let t = Real(i) / Real(steps)
            let point = cubicPoint(at: t, start: p0, cp1: p1, cp2: p2, end: p3)
            total += previous.distance(to: point)
            lengths[i] = total
            previous = point
        }
        return lengths
    }

    /// Sums the polyline approximation of a cubic Bézier's arc-length —
    /// matches `BezierPath+Length.cubicBezierLength` so total-length
    /// and arc-length sampling agree on segment boundaries.
    func cubicLength(
        from p0: Point, control1 p1: Point, control2 p2: Point, to p3: Point
    ) -> Real {
        cubicCumulativeLengths(from: p0, control1: p1, control2: p2, to: p3).last ?? 0
    }

    /// Cubic Bézier point at parameter `t` ∈ [0, 1], via the explicit
    /// Bernstein form.
    func cubicPoint(
        at t: Real, start p0: Point, cp1 p1: Point, cp2 p2: Point, end p3: Point
    ) -> Point {
        let oneMinusT = 1 - t
        let b0 = oneMinusT * oneMinusT * oneMinusT
        let b1 = 3 * oneMinusT * oneMinusT * t
        let b2 = 3 * oneMinusT * t * t
        let b3 = t * t * t
        return Point(
            x: b0 * p0.x + b1 * p1.x + b2 * p2.x + b3 * p3.x,
            y: b0 * p0.y + b1 * p1.y + b2 * p2.y + b3 * p3.y)
    }

    /// Cubic Bézier first derivative at parameter `t` ∈ [0, 1] —
    /// `B'(t) = 3(1−t)²(p1−p0) + 6(1−t)t(p2−p1) + 3t²(p3−p2)`. Not
    /// normalized; callers divide by `vectorLength` for a unit tangent.
    func cubicDerivative(
        at t: Real, start p0: Point, cp1 p1: Point, cp2 p2: Point, end p3: Point
    ) -> Point {
        let oneMinusT = 1 - t
        let k0 = 3 * oneMinusT * oneMinusT
        let k1 = 6 * oneMinusT * t
        let k2 = 3 * t * t
        let d01 = p1 - p0
        let d12 = p2 - p1
        let d23 = p3 - p2
        return Point(
            x: k0 * d01.x + k1 * d12.x + k2 * d23.x,
            y: k0 * d01.y + k1 * d12.y + k2 * d23.y)
    }
}
