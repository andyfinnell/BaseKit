import Foundation
import TestKit
@testable import BaseKit

final class FakeURLSession: URLSessionType {
    
    let data_fake = SendableMethodCall(URLRequest.self, Result<(Data, URLResponse), Error>.failure(RequestEncoderError.badMojo))
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try data_fake.fakeThrows(request)
    }

    func fulfillJson(string: String, status: Int = 200, on request: URLRequest) {
        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: status,
                                       httpVersion: "1.1",
                                       headerFields: ["content-type": "application/json"])!

        let data = string.data(using: .utf8)!
        data_fake.return(.success((data, response)), ifEqual: request)
    }
    
    func fulfill(response: URLResponse, data: Data, on request: URLRequest) {
        data_fake.return(.success((data, response)), ifEqual: request)
    }
    
    func reject(error: Error, on request: URLRequest) {
        data_fake.return(.failure(error), ifEqual: request)
    }
}

