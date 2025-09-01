import Foundation
import XCTest
@testable import BaseKit

final class AsyncRandomAccessFileTests: XCTestCase {
    private let largeData = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f])
    
    func testInitWhenFileExists() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try AsyncRandomAccessFile(url: fileURL)
        let readData = try await subject.read(4, at: 0)
        XCTAssert(readData == data)
        
        subject.close()
    }
    
    func testInitWhenFileDoeNotExist() async throws {
        let fileURL = try URL.temporaryFile()
        let subject = try AsyncRandomAccessFile(url: fileURL)
        
        let bytes = Data([0x01, 0x02, 0x03, 0x04])
        try await subject.write(bytes, at: 0)
        
        let readData = try await subject.read(4, at: 0)
        XCTAssert(readData == bytes)
        
        subject.close()
    }
    
    func testInitWithLargeDataWhenFileDoeNotExist() async throws {
        let fileURL = try URL.temporaryFile()
        let subject = try AsyncRandomAccessFile(url: fileURL)
        
        let bytes = largeData
        try await subject.write(bytes, at: 0)
        
        let readData = try await subject.read(largeData.count, at: 0)
        XCTAssert(readData == bytes)
        
        subject.close()
    }
    
    func testCloseWhenFileIsOpen() async throws {
        let fileURL = try URL.temporaryFile()
        let subject = try AsyncRandomAccessFile(url: fileURL)
        
        subject.close()
    }
    
    func testReadWhenFileIsOpenWhenOffsetIsInRangeWhenSizeIsInRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try AsyncRandomAccessFile(url: fileURL)
        let readData = try await subject.read(4, at: 0)
        XCTAssert(readData == data)
        
        subject.close()
    }
    
    func testReadWhenFileIsOpenWhenOffsetIsInRangeWhenSizeTooBig() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try AsyncRandomAccessFile(url: fileURL)
        let readData = try await subject.read(8, at: 0)
        XCTAssert(readData == data)
        
        subject.close()
    }
    
    func testReadWhenFileIsOpenWhenOffsetIsOutOfRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try AsyncRandomAccessFile(url: fileURL)
        let readData = try await subject.read(4, at: 4)
        XCTAssert(readData.isEmpty)
        
        subject.close()
    }
    
    func testWriteWhenFileIsOpenedWhenOffsetIsInExistingRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try AsyncRandomAccessFile(url: fileURL)
        
        let bytes = Data([0x02, 0x03, 0x04, 0x05])
        try await subject.write(bytes, at: 0)
        
        let readData = try await subject.read(4, at: 0)
        XCTAssert(readData == bytes)
        
        subject.close()
    }
    
    func testWriteWithLargeDataWhenFileIsOpenedWhenOffsetIsInExistingRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try AsyncRandomAccessFile(url: fileURL)
        
        let bytes = largeData
        try await subject.write(bytes, at: 0)
        
        let readData = try await subject.read(largeData.count, at: 0)
        XCTAssert(readData == bytes)
        
        subject.close()
    }
    
    func testWriteWhenFileIsOpenedWhenOffsetIsBeyondExistingRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try AsyncRandomAccessFile(url: fileURL)
        
        let bytes = Data([0x02, 0x03, 0x04, 0x05])
        try await subject.write(bytes, at: 4)
        
        let readData = try await subject.read(8, at: 0)
        XCTAssert(readData == Data([0x01, 0x01, 0x01, 0x01, 0x02, 0x03, 0x04, 0x05]))
        
        subject.close()
    }

    func testWriteWithLargeDataWhenFileIsOpenedWhenOffsetIsBeyondExistingRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try AsyncRandomAccessFile(url: fileURL)
        
        let bytes = largeData
        try await subject.write(bytes, at: 4)

        let readData = try await subject.read(8, at: 0)
        XCTAssert(readData == Data([0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x03, 0x04]))
        
        subject.close()
    }

}
