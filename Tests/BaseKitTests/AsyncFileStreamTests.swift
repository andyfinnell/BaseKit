import Foundation
import XCTest
import BaseKit

extension URL {
    static func temporaryFile() throws -> URL {
        let rootTemporary = FileManager.default.temporaryDirectory
        try FileManager.default.createDirectory(at: rootTemporary, withIntermediateDirectories: true)
        return rootTemporary.appendingPathComponent(UUID().uuidString + ".data", isDirectory: false)
    }
}

extension DispatchData {
    static func ==(lhs: DispatchData, rhs: Data) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
}

final class AsyncFileStreamTests: XCTestCase {
    func testReadInitWhenFileExists() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try fileURL.openForReading()
        let readData = try await subject.readData(upToCount: 4)
        XCTAssert(readData == data)
        
        subject.close()
    }

    func testReadInitWhenFileDoesNotExists() async throws {
        let fileURL = try URL.temporaryFile()
        
        do {
            let subject = try fileURL.openForReading()
            _ = try await subject.read(upToCount: 4)
            XCTFail("Should have thrown an error")
        } catch {
            // expected to throw
        }
    }

    func testWriteInitWhenFileDoesExist() async throws {
        let fileURL = try URL.temporaryFile()
        
        // Set up the existing data
        let initialData = Data([0x05, 0x05, 0x05, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a])
        try initialData.write(to: fileURL)

        // Write out
        let writeStream = try fileURL.openForWriting()
        let expectedData = Data([0x01, 0x02, 0x03, 0x04])
        let writeData = expectedData.withUnsafeBytes { buffer in
            DispatchData(bytes: buffer)
        }
        try await writeStream.write(writeData)
        writeStream.close()
        
        // Read in
        let readStream = try fileURL.openForReading()
        let readData = try await readStream.readData(upToCount: 8)
        XCTAssert(readData == expectedData)
            
        readStream.close()
    }

    func testWriteInitWhenFileDoeNotExist() async throws {
        let fileURL = try URL.temporaryFile()
        
        // Write out
        let writeStream = try fileURL.openForWriting()
        let bytes = Data([0x01, 0x02, 0x03, 0x04])
        let writeData = bytes.withUnsafeBytes { buffer in
            DispatchData(bytes: buffer)
        }
        try await writeStream.write(writeData)
        writeStream.close()
        
        // Read in
        let readStream = try fileURL.openForReading()
        let readData = try await readStream.readData(upToCount: 4)
        XCTAssert(readData == bytes)
            
        readStream.close()
    }
            
    func testReadWhenFileIsOpenWhenOffsetIsInRangeWhenSizeIsInRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try fileURL.openForReading()
        let readData = try await subject.readData(upToCount: 4)
        XCTAssert(readData == data)
        
        subject.close()
    }
    
    func testReadWhenFileIsOpenWhenOffsetIsInRangeWhenSizeTooBig() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try fileURL.openForReading()
        let readData = try await subject.readData(upToCount: 8)
        XCTAssert(readData == data)
        
        subject.close()
    }
    
    func testReadWhenFileIsOpenWhenOffsetIsOutOfRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try fileURL.openForReading()
        _ = try await subject.read(upToCount: 4) // read what's there
        let readData = try await subject.readData(upToCount: 4)
        XCTAssert(readData.isEmpty)
        
        subject.close()
    }

    func testWriteWhenFileIsOpenedWhenOffsetIsInExistingRange() async throws {
        let fileURL = try URL.temporaryFile()
        let data = Data([0x01, 0x01, 0x01, 0x01])
        try data.write(to: fileURL)
        
        let subject = try fileURL.openForWriting()
        
        let bytes = Data([0x02, 0x03, 0x04, 0x05])
        let writeData = bytes.withUnsafeBytes { buffer in
            DispatchData(bytes: buffer)
        }
        try await subject.write(writeData)
        subject.close()

        let readData = try Data(contentsOf: fileURL)
        XCTAssert(readData == bytes)
    }
    
    func testWriteWhenFileIsOpenedWhenOffsetIsBeyondExistingRange() async throws {
        let fileURL = try URL.temporaryFile()
        let firstData = Data([0x01, 0x01, 0x01, 0x01])
        try firstData.write(to: fileURL)
        
        let subject = try fileURL.openForWriting()
        
        let secondData = Data([0x02, 0x03, 0x04, 0x05])
        try await subject.write(firstData.withUnsafeBytes { DispatchData(bytes: $0) })
        try await subject.write(secondData.withUnsafeBytes { DispatchData(bytes: $0) })
        subject.close()

        let readData = try Data(contentsOf: fileURL)
        XCTAssert(readData == Data([0x01, 0x01, 0x01, 0x01, 0x02, 0x03, 0x04, 0x05]))
        
    }
}
