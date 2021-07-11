import Foundation
import XCTest
@testable import BaseKit

final class PersistentFilesystemTests: XCTestCase {
    private var subject: PersistentFilesystem!
    private var rootURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        rootURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        subject = try PersistentFilesystem(rootURL: rootURL)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        try FileManager.default.removeItem(at: rootURL)
    }
    
    func testInit() {
        XCTAssertTrue(subject.exists(FilesystemPath(components: [])))
    }
    
    func testReadWhenPathDoesNotExist() {
        XCTAssertThrowsError(try subject.read(FilesystemPath(components: ["jim", "bob"])))
    }
    
    func testReadWhenPathIsFolder() throws {
        try subject.write(Data(), to: FilesystemPath(components: ["jim", "bob"]))
       
        XCTAssertThrowsError(try subject.read(FilesystemPath(components: ["jim"])))
    }

    func testReadWhenPathIsFile() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "bob"]))
        
        XCTAssertEqual(try subject.read(FilesystemPath(components: ["jim", "bob"])), Data([0xaa, 0xbb, 0xcc, 0xdd]))
    }
    
    func testWriteWhenPathDoesNotExist() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim"]))
        
        XCTAssertEqual(try subject.read(FilesystemPath(components: ["jim"])), Data([0xaa, 0xbb, 0xcc, 0xdd]))
    }
    
    func testWriteWhenPathIsFolder() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "bob"]))
        
        XCTAssertThrowsError(try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim"])))
    }
    
    func testWriteWhenPathIsFile() throws {
        try subject.write(Data([0x11, 0x22, 0x33, 0x44]), to: FilesystemPath(components: ["jim"]))
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim"]))
        
        XCTAssertEqual(try subject.read(FilesystemPath(components: ["jim"])), Data([0xaa, 0xbb, 0xcc, 0xdd]))
    }
    
    func testWriteWhenParentFolderDoesNotExist() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "bob"]))
        XCTAssertEqual(try subject.read(FilesystemPath(components: ["jim", "bob"])), Data([0xaa, 0xbb, 0xcc, 0xdd]))
    }
    
    func testExistsWhenPathDoesNotExist() {
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim"])))
    }
    
    func testExistsWhenPathIsFolder() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "bob"]))
        
        XCTAssertTrue(subject.exists(FilesystemPath(components: ["jim"])))
    }
    
    func testExistsWhenPathIsFile() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "bob"]))
        
        XCTAssertTrue(subject.exists(FilesystemPath(components: ["jim", "bob"])))
    }
    
    func testExistsWhenParentFolderDoesNotExist() {
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim", "bob"])))
    }
    
    func testExistsWhenParentInPathIsFileButDoesNotExist() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim"]))
        
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim", "bob"])))
    }
    
    func testDeleteWhenPathDoesNotExist() throws {
        XCTAssertThrowsError(try subject.delete(FilesystemPath(components: ["jim", "bob"])))
    }
    
    func testDeleteWhenPathIsFolder() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "bob"]))
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "frank"]))
    
        try subject.delete(FilesystemPath(components: ["jim"]))
        
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim", "bob"])))
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim", "frank"])))
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim"])))
    }
    
    func testDeleteWhenPathIsFile() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "bob"]))
        
        try subject.delete(FilesystemPath(components: ["jim", "bob"]))
        
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim", "bob"])))
    }
    
    func testDeleteWhenPathContainsFileButDoesNotExist() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim"]))
        
        XCTAssertThrowsError(try subject.delete(FilesystemPath(components: ["jim", "bob"])))
    }
    
    func testDeleteWhenRootFolder() throws {
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["jim", "bob"]))
        try subject.write(Data([0xaa, 0xbb, 0xcc, 0xdd]), to: FilesystemPath(components: ["frank"]))

        try subject.delete(FilesystemPath(components: []))
        
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim", "bob"])))
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["jim"])))
        XCTAssertFalse(subject.exists(FilesystemPath(components: ["frank"])))
        XCTAssertTrue(subject.exists(FilesystemPath(components: [])))
    }

}
