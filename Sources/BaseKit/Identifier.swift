import Foundation

public struct Identifier<Value, Phantom> {
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}
 
extension Identifier: Equatable where Value: Equatable {}
extension Identifier: Hashable where Value: Hashable {}
extension Identifier: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Value.self)
    }
}
extension Identifier: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
extension Identifier: Comparable where Value: Comparable {
    public static func < (lhs: Identifier<Value, Phantom>, rhs: Identifier<Value, Phantom>) -> Bool {
        lhs.value < rhs.value
    }
}

extension Identifier where Value == UUID {
    public init() {
        self.init(UUID())
    }
}
