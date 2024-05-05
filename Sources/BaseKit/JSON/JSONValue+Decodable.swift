import Foundation

extension JSONValue: Decodable {
    public init(from decoder: Decoder) throws {
        self = try JSONValue.decode(JSONValue.container(for: decoder))
    }
}

extension JSONValue {
    struct CodingKeys: CodingKey {
        let stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        let intValue: Int?
        
        init?(intValue: Int) {
            self.stringValue = String(describing: intValue)
            self.intValue = intValue
        }
        
        init(_ value: String) {
            self.stringValue = value
            self.intValue = nil
        }
    }
}

private extension JSONValue {
    enum Container {
        case single(SingleValueDecodingContainer)
        case array(UnkeyedDecodingContainer)
        case object(KeyedDecodingContainer<CodingKeys>)
    }
    
    static func container(for decoder: Decoder) throws -> Container {
        do {
            return .array(try decoder.unkeyedContainer())
        } catch {
            do {
                return .object(try decoder.container(keyedBy: CodingKeys.self))
            } catch {
                return .single(try decoder.singleValueContainer())
            }
        }
    }
    
    static func decode(_ container: Container) throws -> JSONValue {
        switch container {
        case let .array(unkeyedContainer):
            return try decodeArray(unkeyedContainer)
        case let .single(singleContainer):
            return try decodeSingle(singleContainer)
        case let .object(keyedContainer):
            return try decodeObject(keyedContainer)
        }
    }
    
    static func decodeArray(_ container: UnkeyedDecodingContainer) throws -> JSONValue {
        var c = container
        
        var values = [JSONValue]()
        do {
            while true {
                try values.append(c.decode(JSONValue.self))
            }
        } catch {
            // nop
        }
        return .array(values)
    }
    
    static func decodeSingle(_ container: SingleValueDecodingContainer) throws -> JSONValue {
        do {
            return try .boolean(container.decode(Bool.self))
        } catch {
            do {
                return try .number(container.decode(Double.self))
            } catch {
                do {
                    return try .string(container.decode(String.self))
                } catch {
                    if container.decodeNil() {
                        return .null
                    } else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected something we could decode")
                    }
                }
            }
        }
    }
    
    static func decodeObject(_ container: KeyedDecodingContainer<CodingKeys>) throws -> JSONValue {
        var object = [String: JSONValue]()
        
        for key in container.allKeys {
            let value = try container.decode(JSONValue.self, forKey: key)
            object[key.stringValue] = value
        }
        
        return .object(object)
    }
}
