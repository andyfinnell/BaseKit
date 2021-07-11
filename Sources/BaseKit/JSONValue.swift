import Foundation

public indirect enum JSONValue: Hashable {
    case number(Double)
    case boolean(Bool)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])
    case null
}
