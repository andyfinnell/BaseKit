public struct XMLAttribute: Codable, Hashable, Sendable, RawRepresentable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ value: String) {
        self.rawValue = value
    }
}

extension XMLAttribute: Comparable {
    public static func <(lhs: XMLAttribute, rhs: XMLAttribute) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension XMLAttribute: CustomStringConvertible {
    public var description: String { rawValue }
}

public extension XMLAttribute {
    static let id = XMLAttribute("id")
}
