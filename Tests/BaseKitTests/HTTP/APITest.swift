import Foundation
import XCTest
import TestKit
@testable import BaseKit

final class APITest: XCTestCase {
    var subject: API!
    var urlSession: FakeURLSession!
    var authenticationStorage: FakeAuthenticationStorage!
    
    override func setUp() {
        super.setUp()
        urlSession = FakeURLSession()
        authenticationStorage = FakeAuthenticationStorage()
        
        subject = API(httpClient: HTTPClient(logger: FakeLogger(),
                                             urlSession: urlSession,
                                             httpRequestEncoder: HTTPRequestEncoder(),
                                             httpResponseDecoder: HTTPResponseDecoder()),
                      apiConfig: APIConfig(baseURL: URL(string: "https://example.com/api/")!, baseHeaders: [.apiKey: "valid-api-key"]),
                      authenticationStorage: authenticationStorage)
    }
    
    func testCall_urlBuildingFails_returnsError() async throws {
        let request = BadURLRequest()
        
        do {
            _ = try await subject.call(request)
            
            XCTFail("Should have thrown")
        } catch {
            XCTAssertTrue(true) // should throw
        }
    }

    func testCall_urlBuildingSucceeds_hasAuth_httpFails_returnsError() async throws {
        let request = TestRequest(email: "frank@example.com")
        
        authenticationStorage.authenticationHeader_fake.return("Bearer valid-token")
        urlSession.data_fake.throw(HTTPError.statusCode(404))

        do {
            _ = try await subject.call(request)
            
            XCTFail("Should have thrown")
        } catch {
        
        }
        
        XCTAssertMethodWasCalled(urlSession.data_fake)
        XCTAssertMethodWasCalledWithArgEquals(authenticationStorage.authenticationHeader_fake, "example.com")
        
        let httpRequest = urlSession.data_fake.args
        XCTAssertEqual(httpRequest?.url, URL(string: "https://example.com/api/login")!)
        XCTAssertEqual(httpRequest?.httpMethod, "POST")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "accept"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "x-api-key"), "valid-api-key")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer valid-token")
        XCTAssertEqual(httpRequest?.httpBody, request.expectedRequestBodyData())
    }
    
    func testCall_urlBuildingSucceeds_hasAuth_httpSucceeds_returnsValue() async throws {
        let request = TestRequest(email: "frank@example.com")

        authenticationStorage.authenticationHeader_fake.return("Bearer valid-token")
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com/api/login")!, statusCode: 200, httpVersion: "1.1", headerFields: ["content-type": "application/json"])
        let responseData = request.expectedResponseBodyData(response: TestRequest.ResourceType(token: "valid-token"))
        urlSession.data_fake.return(.success((responseData!, urlResponse!)))

        let finalResult = try await subject.call(request)

        XCTAssertMethodWasCalled(urlSession.data_fake)
        XCTAssertMethodWasCalledWithArgEquals(authenticationStorage.authenticationHeader_fake, "example.com")
        
        let httpRequest = urlSession.data_fake.args
        XCTAssertEqual(httpRequest?.url, URL(string: "https://example.com/api/login")!)
        XCTAssertEqual(httpRequest?.httpMethod, "POST")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "accept"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "x-api-key"), "valid-api-key")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer valid-token")
        XCTAssertEqual(httpRequest?.httpBody, request.expectedRequestBodyData())

        XCTAssertEqual(finalResult.token, "valid-token")
    }

    func testCall_urlBuildingSucceeds_noAuth_httpSucceeds_returnsValue() async throws {
        let request = TestRequest(email: "frank@example.com")

        authenticationStorage.authenticationHeader_fake.return(nil)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com/api/login")!, statusCode: 200, httpVersion: "1.1", headerFields: ["content-type": "application/json"])
        let responseData = request.expectedResponseBodyData(response: TestRequest.ResourceType(token: "valid-token"))
        urlSession.data_fake.return(.success((responseData!, urlResponse!)))
        
        let finalResult = try await subject.call(request)
        
        XCTAssertMethodWasCalled(urlSession.data_fake)
        XCTAssertMethodWasCalledWithArgEquals(authenticationStorage.authenticationHeader_fake, "example.com")
        
        let httpRequest = urlSession.data_fake.args
        XCTAssertEqual(httpRequest?.url, URL(string: "https://example.com/api/login")!)
        XCTAssertEqual(httpRequest?.httpMethod, "POST")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "accept"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "x-api-key"), "valid-api-key")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNil(httpRequest?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(httpRequest?.httpBody, request.expectedRequestBodyData())

        XCTAssertEqual(finalResult.token, "valid-token")
    }

    func testShow() async throws {
        let request = ShowRequest(d: "123")

        authenticationStorage.authenticationHeader_fake.return("Bearer valid-token")
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com/api/message?d=123")!, statusCode: 200, httpVersion: "1.1", headerFields: ["content-type": "application/json"])
        let responseData = request.expectedResponseBodyData(response: ShowRequest.ResourceType(message: "hello world"))
        urlSession.data_fake.return(.success((responseData!, urlResponse!)))

        let finalResult = try await subject.call(request)
    
        XCTAssertMethodWasCalled(urlSession.data_fake)
        XCTAssertMethodWasCalledWithArgEquals(authenticationStorage.authenticationHeader_fake, "example.com")
        
        let httpRequest = urlSession.data_fake.args
        XCTAssertEqual(httpRequest?.url, URL(string: "https://example.com/api/message?d=123")!)
        XCTAssertEqual(httpRequest?.httpMethod, "GET")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "accept"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "x-api-key"), "valid-api-key")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer valid-token")
        XCTAssertNil(httpRequest?.httpBody)
        
        XCTAssertEqual(finalResult.message, "hello world")
    }
}

private struct TestRequest: ResourceRequest {
    struct Request: Encodable, Equatable {
        let email: String
    }
    
    struct ResourceType: Encodable, Decodable, Equatable {
        let token: String
    }
    
    let verb = ResourceVerb.create
    let path = "login"
    let parameters: Request
    
    init(email: String) {
        self.parameters = Request(email: email)
    }
}

private struct BadURLRequest: ResourceRequest {
    typealias ResourceType = BaseKit.Empty

    let verb = ResourceVerb.show
    let path = ""
    let parameters = Empty()
}

private struct ShowRequest: ResourceRequest {
    struct Request: Encodable, Equatable {
        let d: String?
    }
    
    struct ResourceType: Encodable, Decodable, Equatable {
        let message: String
    }
    
    let verb = ResourceVerb.show
    let path = "message"
    let parameters: Request
    
    init(d: String?) {
        self.parameters = Request(d: d)
    }
}
