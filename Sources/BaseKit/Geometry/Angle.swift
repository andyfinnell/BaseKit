
public struct Angle: Hashable, Sendable, Comparable, AdditiveArithmetic {
    public let radians: Real
    public let degrees: Real
    
    public init(radians: Real) {
        self.radians = radians
        degrees = radians * 180.0 / Real.pi
    }
    
    public init(degrees: Real) {
        self.degrees = degrees
        radians = degrees * Real.pi / 180.0
    }
    
    public static func <(lhs: Angle, rhs: Angle) -> Bool {
        lhs.radians < rhs.radians
    }
    
    public static let zero = Angle(radians: 0.0)
    
    public static func +(lhs: Angle, rhs: Angle) -> Angle {
        Angle(radians: lhs.radians + rhs.radians)
    }
    
    public static func -(lhs: Angle, rhs: Angle) -> Angle {
        Angle(radians: lhs.radians - rhs.radians)
    }
}
