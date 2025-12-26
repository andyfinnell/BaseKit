import Foundation

// Nesting this data type inside of HTTPRequest blows up the Swift runtime
//  with a "cyclic metadata dependency detected, aborting" error
public enum HTTPRequestBody<T: Encodable & Equatable & Sendable>: Equatable, Sendable {
    case empty
    case json(T)
    case formData(T)
}
