import Foundation

public struct PathVertex: Hashable, Sendable {
    public enum Position: Hashable, Sendable {
        case start
        case mid
        case end
    }

    public let point: Point
    public let angle: Double
    public let position: Position

    public init(point: Point, angle: Double, position: Position) {
        self.point = point
        self.angle = angle
        self.position = position
    }
}

public extension BezierPath {
    func markerVertices() -> [PathVertex] {
        var subpaths = [[SegmentInfo]]()
        var currentSubpath = [SegmentInfo]()
        var currentPoint = Point.zero
        var subpathStart = Point.zero
        var isClosed = false

        for element in elements {
            switch element {
            case let .move(to: point):
                if !currentSubpath.isEmpty {
                    subpaths.append(currentSubpath)
                    currentSubpath = []
                }
                subpathStart = point
                currentPoint = point
                isClosed = false

            case let .line(to: point):
                let inAngle = atan2(point.y - currentPoint.y, point.x - currentPoint.x)
                currentSubpath.append(SegmentInfo(
                    startPoint: currentPoint,
                    endPoint: point,
                    incomingAngle: inAngle,
                    outgoingAngle: inAngle
                ))
                currentPoint = point

            case let .curve(to: point, control1: control1, control2: control2):
                let startTangent: Double
                if control1 != currentPoint {
                    startTangent = atan2(control1.y - currentPoint.y, control1.x - currentPoint.x)
                } else if control2 != currentPoint {
                    startTangent = atan2(control2.y - currentPoint.y, control2.x - currentPoint.x)
                } else {
                    startTangent = atan2(point.y - currentPoint.y, point.x - currentPoint.x)
                }

                let endTangent: Double
                if control2 != point {
                    endTangent = atan2(point.y - control2.y, point.x - control2.x)
                } else if control1 != point {
                    endTangent = atan2(point.y - control1.y, point.x - control1.x)
                } else {
                    endTangent = atan2(point.y - currentPoint.y, point.x - currentPoint.x)
                }

                currentSubpath.append(SegmentInfo(
                    startPoint: currentPoint,
                    endPoint: point,
                    incomingAngle: startTangent,
                    outgoingAngle: endTangent
                ))
                currentPoint = point

            case .closeSubpath:
                if currentPoint != subpathStart {
                    let closeAngle = atan2(subpathStart.y - currentPoint.y, subpathStart.x - currentPoint.x)
                    currentSubpath.append(SegmentInfo(
                        startPoint: currentPoint,
                        endPoint: subpathStart,
                        incomingAngle: closeAngle,
                        outgoingAngle: closeAngle
                    ))
                }
                isClosed = true
                subpaths.append(currentSubpath)
                currentSubpath = []
                currentPoint = subpathStart
            }
        }

        if !currentSubpath.isEmpty {
            subpaths.append(currentSubpath)
        }

        var vertices = [PathVertex]()

        for subpath in subpaths {
            guard !subpath.isEmpty else { continue }

            let subpathIsClosed = isClosed || (subpath.count > 1
                && subpath.first?.startPoint == subpath.last?.endPoint)

            if subpathIsClosed {
                // Closed subpath: all vertices are .mid
                // First vertex: bisector of last segment's incoming and first segment's outgoing
                let lastSegment = subpath[subpath.count - 1]
                let firstSegment = subpath[0]
                let firstAngle = bisectorAngle(lastSegment.outgoingAngle, firstSegment.incomingAngle)
                vertices.append(PathVertex(
                    point: firstSegment.startPoint,
                    angle: firstAngle,
                    position: .mid
                ))

                // Interior vertices
                for i in 1..<subpath.count {
                    let prevSegment = subpath[i - 1]
                    let segment = subpath[i]
                    let midAngle = bisectorAngle(prevSegment.outgoingAngle, segment.incomingAngle)
                    vertices.append(PathVertex(
                        point: segment.startPoint,
                        angle: midAngle,
                        position: .mid
                    ))
                }
            } else {
                // Open subpath: first = .start, last = .end, interior = .mid
                vertices.append(PathVertex(
                    point: subpath[0].startPoint,
                    angle: subpath[0].incomingAngle,
                    position: .start
                ))

                for i in 1..<subpath.count {
                    let prevSegment = subpath[i - 1]
                    let segment = subpath[i]
                    let midAngle = bisectorAngle(prevSegment.outgoingAngle, segment.incomingAngle)
                    vertices.append(PathVertex(
                        point: segment.startPoint,
                        angle: midAngle,
                        position: .mid
                    ))
                }

                let lastSegment = subpath[subpath.count - 1]
                vertices.append(PathVertex(
                    point: lastSegment.endPoint,
                    angle: lastSegment.outgoingAngle,
                    position: .end
                ))
            }
        }

        return vertices
    }
}

private struct SegmentInfo {
    let startPoint: Point
    let endPoint: Point
    let incomingAngle: Double
    let outgoingAngle: Double
}

private func bisectorAngle(_ a: Double, _ b: Double) -> Double {
    atan2(sin(a) + sin(b), cos(a) + cos(b))
}
