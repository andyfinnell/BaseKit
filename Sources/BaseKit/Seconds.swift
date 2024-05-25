import Foundation

public struct Seconds: Hashable {
    public var seconds: Double
    
    public init(_ seconds: Double) {
        self.seconds = seconds
    }
}

public func +(lhs: Seconds, rhs: Seconds) -> Seconds {
    Seconds(lhs.seconds + rhs.seconds)
}

public func +=(lhs: inout Seconds, rhs: Seconds) {
    lhs.seconds += rhs.seconds
}

public func -(lhs: Seconds, rhs: Seconds) -> Seconds {
    Seconds(lhs.seconds - rhs.seconds)
}

public func *(lhs: Seconds, rhs: Double) -> Seconds {
    Seconds(lhs.seconds * rhs)
}

public func *(lhs: Seconds, rhs: RelativeTime) -> Seconds {
    Seconds(lhs.seconds * rhs.value)
}

public func *(lhs: Seconds, rhs: Int) -> Seconds {
    Seconds(lhs.seconds * Double(rhs))
}

public func /(lhs: Seconds, rhs: Seconds) -> RelativeTime {
    RelativeTime(lhs.seconds / rhs.seconds)
}

public extension Double {
    var s: Seconds {
        Seconds(self)
    }
}

public extension Float {
    var s: Seconds {
        Seconds(Double(self))
    }
}

extension Seconds: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        seconds = try container.decode(Double.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(seconds)
    }
}

extension Seconds: Comparable {
    public static func < (lhs: Seconds, rhs: Seconds) -> Bool {
        lhs.seconds < rhs.seconds
    }
}

extension Seconds: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        seconds = value
    }
}

extension Seconds: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        seconds = Double(value)
    }
}
