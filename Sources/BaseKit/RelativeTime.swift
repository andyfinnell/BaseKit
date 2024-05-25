import Foundation

/// Between [0...1] inclusive.
public struct RelativeTime: Hashable {
    public var value: Double
    
    public init(_ value: Double) {
        self.value = value
    }
}

extension RelativeTime: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Double.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension RelativeTime: Comparable {
    public static func < (lhs: RelativeTime, rhs: RelativeTime) -> Bool {
        lhs.value < rhs.value
    }
}

extension RelativeTime: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.value = value
    }
}

extension RelativeTime: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }
}

public extension RelativeTime {
    
    static func / (lhs: RelativeTime, rhs: Int) -> RelativeTime {
        RelativeTime(lhs.value / Double(rhs))
    }
    
    static func * (lhs: RelativeTime, rhs: Int) -> RelativeTime {
        RelativeTime(lhs.value * Double(rhs))
    }

    static func / (lhs: RelativeTime, rhs: Double) -> RelativeTime {
        RelativeTime(lhs.value / rhs)
    }
    
    static func * (lhs: RelativeTime, rhs: Double) -> RelativeTime {
        RelativeTime(lhs.value * rhs)
    }

    static func / (lhs: RelativeTime, rhs: RelativeTime) -> RelativeTime {
        RelativeTime(lhs.value / rhs.value)
    }
    
    static func + (lhs: RelativeTime, rhs: RelativeTime) -> RelativeTime {
        RelativeTime(lhs.value + rhs.value)
    }
    
    static func - (lhs: RelativeTime, rhs: RelativeTime) -> RelativeTime {
        RelativeTime(lhs.value - rhs.value)
    }

    static func +=(lhs: inout RelativeTime, rhs: RelativeTime) {
        lhs.value += rhs.value
    }
}
