extension BezierPath {
    public var totalLength: Real {
        var length: Real = 0
        var currentPoint = Point.zero
        var subpathStart = Point.zero

        for element in elements {
            switch element {
            case let .move(to: point):
                currentPoint = point
                subpathStart = point
            case let .line(to: point):
                length += currentPoint.distance(to: point)
                currentPoint = point
            case let .curve(to: end, control1: cp1, control2: cp2):
                length += cubicBezierLength(
                    from: currentPoint,
                    control1: cp1,
                    control2: cp2,
                    to: end
                )
                currentPoint = end
            case .closeSubpath:
                length += currentPoint.distance(to: subpathStart)
                currentPoint = subpathStart
            }
        }
        return length
    }
}

private func cubicBezierLength(
    from p0: Point,
    control1 p1: Point,
    control2 p2: Point,
    to p3: Point,
    steps: Int = 16
) -> Real {
    var length: Real = 0
    var previous = p0

    for i in 1...steps {
        let t = Real(i) / Real(steps)
        let oneMinusT = 1.0 - t

        let x = oneMinusT * oneMinusT * oneMinusT * p0.x
            + 3.0 * oneMinusT * oneMinusT * t * p1.x
            + 3.0 * oneMinusT * t * t * p2.x
            + t * t * t * p3.x

        let y = oneMinusT * oneMinusT * oneMinusT * p0.y
            + 3.0 * oneMinusT * oneMinusT * t * p1.y
            + 3.0 * oneMinusT * t * t * p2.y
            + t * t * t * p3.y

        let current = Point(x: x, y: y)
        length += previous.distance(to: current)
        previous = current
    }
    return length
}
