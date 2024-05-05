import Foundation

extension JSONValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .boolean(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case let .number(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case let .string(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        case let .array(value):
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: value)
        case let .object(value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            for (key, object) in value {
                try container.encode(object, forKey: CodingKeys(key))
            }
        }
    }
}
