import Foundation
import XCTest
@testable import BaseKit

final class MultipartFormDataEncoderTest: XCTestCase {
    var subject: MultipartFormDataEncoder!

    override func setUp() {
        super.setUp()
        subject = MultipartFormDataEncoder()
    }
    
    func testEncodingFormItems() throws {
        let formData = try subject.encode(TestParameters1())
        let boundary = formData.contentType.split(separator: "boundary=").last ?? ""
        let expectedText = """
            --\(boundary)\r
            Content-Disposition: form-data; name="name"\r
            \r
            frank\r
            --\(boundary)\r
            Content-Disposition: form-data; name="image"; filename="readme.txt"\r
            Content-Type: text/plain\r
            \r
            This is a readme file for some
            test data. It just needs to contain
            some words or whatever.\r
            --\(boundary)--\r
            
            """
        let actualText = String(data: formData.bodyData, encoding: .utf8)
        XCTAssertNotNil(actualText)
        XCTAssertEqual(actualText, expectedText)
        XCTAssertEqual(formData.contentType, "multipart/form-data; boundary=\(boundary)")
    }
}

private struct TestParameters1: Encodable {
    let name = "frank"
    let image: HTTPFormFile = .fixture()
}

private extension HTTPFormFile {
    static func fixture() -> HTTPFormFile {
        HTTPFormFile(
            filename: "readme.txt",
            mimeType: "text/plain",
            data: Data("""
                This is a readme file for some
                test data. It just needs to contain
                some words or whatever.
                """.utf8)
        )
    }
}
