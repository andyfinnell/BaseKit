import Foundation

public protocol HTTPClientType: Sendable {
    func send<T, R>(request: HTTPRequest<T>, responseFormat: HTTPResponse<R>.Format) async throws -> HTTPResponse<R>
}

public protocol HasHTTPClient {
    var httpClient: HTTPClientType { get }
}

public final class HTTPClient: HTTPClientType {
    private let logger: LoggerType
    private let urlSession: URLSessionType
    private let httpRequestEncoder: HTTPRequestEncoderType
    private let httpResponseDecoder: HTTPResponseDecoderType
    
    public init(logger: LoggerType,
                urlSession: URLSessionType,
                httpRequestEncoder: HTTPRequestEncoderType,
                httpResponseDecoder: HTTPResponseDecoderType) {
        self.logger = logger
        self.urlSession = urlSession
        self.httpRequestEncoder = httpRequestEncoder
        self.httpResponseDecoder = httpResponseDecoder
    }
    
    public func send<T, R>(request: HTTPRequest<T>, responseFormat: HTTPResponse<R>.Format) async throws -> HTTPResponse<R> {
        logger.debug(request, tag: .http)
        let urlRequest = try httpRequestEncoder.encode(request: request)
        let (data, urlResponse) = try await urlSession.data(for: urlRequest)
        let rawResponse = HTTPRawResponse(
            urlResponse: urlResponse,
            body: data,
            error: nil,
            shouldRedactResponseBody: request.shouldRedactResponseBody
        )
        logger.debug(rawResponse, tag: .http)
        return try httpResponseDecoder.decode(rawResponse, into: responseFormat)
    }
}
