import Foundation
import XCTest
@testable import BaseKit

final class FilesystemNodeTests: XCTestCase {
    private var subject: FilesystemFolder!
    
    override func setUp() {
        super.setUp()
        subject = FilesystemFolder()
    }
    
    func testAddWhenNameDoesNotExist() {
        let node = FilesystemNode.file(FilesystemFile(data: Data([0xaa, 0xbb, 0xcc, 0xdd])))
        
        subject.add(node: node, forName: "bob")
            
        XCTAssertEqual(subject.contents["bob"], node)
    }
    
    func testAddWhenNameExists() {
        let node = FilesystemNode.file(FilesystemFile(data: Data([0xaa, 0xbb, 0xcc, 0xdd])))

        subject.add(node: .folder(FilesystemFolder()), forName: "bob")
        subject.add(node: node, forName: "bob")
        
        XCTAssertEqual(subject.contents["bob"], node)
    }
    
    func testRemoveWhenNameDoesNotExist() {
        subject.remove(name: "bob")
        
        XCTAssertNil(subject.contents["bob"])
    }

    func testRemoveWhenNameExists() {
        let node = FilesystemNode.file(FilesystemFile(data: Data([0xaa, 0xbb, 0xcc, 0xdd])))
        subject.add(node: node, forName: "bob")
        subject.remove(name: "bob")
        
        XCTAssertNil(subject.contents["bob"])
    }
    
    func testRemoveAllWhenHasChildren() {
        let bobNode = FilesystemNode.file(FilesystemFile(data: Data([0xaa, 0xbb, 0xcc, 0xdd])))
        subject.add(node: bobNode, forName: "bob")
        subject.add(node: .folder(FilesystemFolder()), forName: "jim")
        
        subject.removeAll()
           
        XCTAssertEqual(subject.contents, [:])
    }
    
    func testRemoveAllWhenNoChildren() {
        subject.removeAll()
           
        XCTAssertEqual(subject.contents, [:])
    }
}
