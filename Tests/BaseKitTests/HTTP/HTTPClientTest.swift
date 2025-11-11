import Foundation
import XCTest
@testable import BaseKit

final class HTTPClientTest: XCTestCase {
    var subject: HTTPClient!
    var request: HTTPRequest<BaseKit.Empty>!
    var httpRequestEncoder: FakeHTTPRequestEncoder!
    var urlSession: FakeURLSession!
    
    override func setUp() {
        super.setUp()
        httpRequestEncoder = FakeHTTPRequestEncoder()
        urlSession = FakeURLSession()
        subject = HTTPClient(logger: FakeLogger(),
                             urlSession: urlSession,
                             httpRequestEncoder: httpRequestEncoder,
                             httpResponseDecoder: HTTPResponseDecoder())
        request = HTTPRequest<BaseKit.Empty>(method: .get,
                                     url: URL(string: "https://example.com")!,
                                     headers: [HTTPHeader.accept: "application/json"],
                                     body: .json(Empty()),
                                     shouldRedactRequestBody: false,
                                     shouldRedactResponseBody: false)
    }
    
    func testSend_encodeThrows_returnsFailure() async throws {
        httpRequestEncoder.encode_fake.throw(RequestEncoderError.badMojo)
        
        do {
            let _ = try await subject.send(request: request, responseFormat: HTTPResponse<BaseKit.Empty>.Format.empty)
            
            XCTFail("Should have thrown!")
        } catch {
            // success
        }

        XCTAssertTrue(httpRequestEncoder.encode_fake.wasCalled)
    }
    
    func testSend_encodeSucceeds_dataTaskFails_returnsFailure() async throws {

        let request = URLRequest(url: URL(string: "https://example.com")!)
        httpRequestEncoder.encode_fake.return(request)
        urlSession.reject(error: HTTPError.statusCode(404), on: request)
        do {
            _ = try await subject.send(request: self.request, responseFormat: HTTPResponse<BaseKit.Empty>.Format.empty)
            XCTFail("should have thrown")
        } catch {
            
        }

        XCTAssertTrue(httpRequestEncoder.encode_fake.wasCalled)
        XCTAssertTrue(urlSession.data_fake.wasCalled)
    }
    
    func testSend_encodeSucceeds_dataTaskSucceeds_returnsSucceess() async throws {
        let request = URLRequest(url: URL(string: "https://example.com")!)
        httpRequestEncoder.encode_fake.return(request)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "1.1", headerFields: ["content-type": "application/json"])
        urlSession.fulfill(response: urlResponse!, data: Data(), on: request)
        
        let finalResult = try await subject.send(request: self.request, responseFormat: HTTPResponse<BaseKit.Empty>.Format.empty)

        XCTAssertTrue(httpRequestEncoder.encode_fake.wasCalled)
        XCTAssertTrue(urlSession.data_fake.wasCalled)

        let expectedResponse = HTTPResponse<BaseKit.Empty>(status: 200, url: URL(string: "https://example.com")!, body: Empty(), headers: ["Content-Type": "application/json"])
        XCTAssertEqual(finalResult, expectedResponse)
    }
}
