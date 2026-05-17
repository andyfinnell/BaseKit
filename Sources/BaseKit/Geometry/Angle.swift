
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

extension Angle: Codable {
    // Encodes `degrees` only so the persisted form has a single source of
    // truth — auto-synthesis would store `radians` and `degrees` redundantly
    // and decode could land on inconsistent values if tampered with. Degrees
    // is the canonical SVG unit, so it's the natural one to serialize.
    private enum CodingKeys: String, CodingKey {
        case degrees
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let degrees = try container.decode(Real.self, forKey: .degrees)
        self.init(degrees: degrees)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(degrees, forKey: .degrees)
    }
}
