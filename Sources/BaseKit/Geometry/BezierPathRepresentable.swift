
public protocol BezierPathRepresentable {
    init()
    
    var isEmpty: Bool { get }
    
    mutating func move(to point: Point)
    mutating func addCurve(to point: Point, controlPoint1: Point, controlPoint2: Point)
    mutating func addLine(to point: Point)
    mutating func closeSubpath()
    
    func enumerate(_ block: (BezierPath.Element) -> Void)
    
    mutating func transform(_ transform: BaseKit.Transform)
}

public extension BezierPathRepresentable {
    
    mutating func append<B: BezierPathRepresentable>(_ other: B) {
        other.enumerate { element in
            switch element {
            case let .move(to: point):
                move(to: point)
            case let .line(to: point):
                addLine(to: point)
            case let .curve(to: point, control1: control1, control2: control2):
                addCurve(to: point, controlPoint1: control1, controlPoint2: control2)
            case .closeSubpath:
                closeSubpath()
            }
        }
    }
    
    func distance(to point: Point) -> Real {
        var currentPoint = Point.zero
        var distances = [Real]()
        enumerate { element in
            switch element {
            case let .move(to: endPoint):
                currentPoint = endPoint
            case let .line(to: endPoint):
                let location = Bezier.closestLocation(
                    on: Bezier.convertLineToCubicBezier(start: currentPoint, end: endPoint),
                    to: point
                )
                distances.append(abs(location.distance))
                currentPoint = endPoint
                
            case let .curve(to: endPoint2, control1: control1, control2: control2):
                let location = Bezier.closestLocation(
                    on: [currentPoint, control1, control2, endPoint2],
                    to: point
                )
                distances.append(abs(location.distance))
                currentPoint = endPoint2
                
            case .closeSubpath:
                currentPoint = .zero
            }
        }
        return distances.min() ?? .greatestFiniteMagnitude
    }
}

