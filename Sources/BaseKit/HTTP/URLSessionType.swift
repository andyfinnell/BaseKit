import Foundation

public protocol URLSessionType: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

public protocol HasURLSessionType {
    var urlSession: URLSessionType { get }
}

extension URLSession: URLSessionType {}
