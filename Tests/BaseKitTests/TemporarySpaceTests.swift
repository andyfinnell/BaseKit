import Foundation
import XCTest
import TestKit
import BaseKit

final class TemporarySpaceTests: XCTestCase {
    private var filesystem: FakeFilesystem!
    private var subject: TemporarySpace!
    private let inputData = Data([0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0x0F])
    private let inputDataHash = "eb3ca3ca1b1abb0ecf34893413b0fcc7158001fc63f659f97e50498f33503ba9"

    override func setUp() {
        super.setUp()
        filesystem = FakeFilesystem()
        subject = TemporarySpace(filesystem: filesystem)
    }
    
    func testStoreWhenNotAlreadyStored() throws {
        let contentId = try subject.store(inputData)
        
        XCTAssertMethodWasCalledWithArgEquals(filesystem.write_fake, \.data, inputData)
        XCTAssertEqual(contentId.value, inputDataHash)
    }
    
    func testStoreWhenAlreadyStored() throws {
        filesystem.exists_fake.return(true)
                
        let contentId = try subject.store(inputData)
        XCTAssertMethodWasNotCalled(filesystem.write_fake)
        XCTAssertEqual(contentId.value, inputDataHash)
    }
    
    func testFetchWhenExists() throws {
        filesystem.exists_fake.return(true)
        filesystem.read_fake.return(inputData)
        
        let contentId = ContentId(inputDataHash)
        let data = try subject.fetch(contentId)
        
        XCTAssertEqual(data, inputData)
    }
    
    func testFetchWhenNotExisting() {
        let contentId = ContentId(inputDataHash)
        filesystem.read_fake.throw()
        
        XCTAssertThrowsError(try subject.fetch(contentId))
    }
}
