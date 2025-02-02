
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

extension BezierPathRepresentable {
    
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
}

