import Foundation

public protocol Sourceable {
    func toSource() async throws -> Source
}

extension URL: Sourceable {
    public func toSource() async throws -> Source {
        try Source(text: String(contentsOf: self),
                   filename: standardizedFileURL.path)
    }
}

extension Source: Sourceable {
    public func toSource() async throws -> Source {
        self
    }
}
