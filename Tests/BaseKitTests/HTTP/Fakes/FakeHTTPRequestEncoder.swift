import Foundation
import TestKit
@testable import BaseKit

enum RequestEncoderError: Error {
    case badMojo
}

final class FakeHTTPRequestEncoder: HTTPRequestEncoderType {
    let encode_fake = SendableMethodCall(Void.self, Result<URLRequest, Error>.failure(RequestEncoderError.badMojo))
    func encode<T>(request: HTTPRequest<T>) throws -> URLRequest {
        try encode_fake.fakeThrows(())
    }
}
