public struct XMLName: Codable, Hashable, Sendable, RawRepresentable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ value: String) {
        self.rawValue = value
    }
}

extension XMLName: Comparable {
    public static func <(lhs: XMLName, rhs: XMLName) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension XMLName: CustomStringConvertible {
    public var description: String { rawValue }
}
