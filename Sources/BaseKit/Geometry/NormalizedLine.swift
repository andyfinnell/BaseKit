import Foundation

public struct NormalizedLine: Hashable, Sendable {
    public let a: Real // * x +
    public let b: Real // * y +
    public let c: Real // constant
    
    public init(a: Real, b: Real, c: Real) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    public func offset(_ offset: Real) -> NormalizedLine {
        .init(a: a, b: b, c: c + offset)
    }
    
    public func distance(to point: Point) -> Real {
        a * Double(point.x) + b * Double(point.y) + c
    }
    
    public func intersectionWith(_ other: NormalizedLine) -> Point {
        let denominator = (a * other.b) - (other.a * b)
        
        return Point(
            x: (b * other.c - other.b * c) / denominator,
            y: (a * other.c - other.a * c) / denominator)
    }
}

public extension NormalizedLine {
    /// Create a normalized line such that computing the distance from it is quick.
    ///  See:    http://softsurfer.com/Archive/algorithm_0102/algorithm_0102.htm#Distance%20to%20an%20Infinite%20Line
    ///          http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/geometry/basic.html
    init(point1: Point, point2: Point) {
        let a = point1.y - point2.y
        let b = point2.x - point1.x
        let c = point1.x * point2.y - point2.x * point1.y
        
        let distance = sqrt(b * b + a * a)
        
        // GPC: prevent divide-by-zero from putting NaNs into the values which cause trouble further on. I'm not sure
        // what cases trigger this, but sometimes point1 == point2 so distance is 0.
        if distance != 0.0 {
            self.init(a: a / distance, b: b / distance, c: c / distance)
        } else {
            self.init(a: 0.0, b: 0.0, c: 0.0)
        }
    }
}
