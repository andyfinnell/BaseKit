import Foundation
import Combine
import XCTest
import BaseKit
import TestKit

final class FutureTests: XCTestCase {
    func testEraseToFutureWhenUpstreamFails() throws {
        let upstream = PassthroughSubject<Int, Error>()
        let expectation = self.expectation(description: "future")
        var error: Error?
        var cancellables = Set<AnyCancellable>()
        upstream.eraseToFuture(fallback: 42).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                XCTFail("Should not finish")
            case let .failure(e):
                error = e
            }
            expectation.fulfill()
        }, receiveValue: { value in
            XCTFail("Shouldn't receive a value")
        }).store(in: &cancellables)
        
        upstream.send(completion: .failure(FakeError()))
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertNotNil(error)
    }
    
    func testEraseToFutureWhenUpstreamSendsOneValue() throws {
        let upstream = PassthroughSubject<Int, Error>()
        let expectation = self.expectation(description: "future")
        var cancellables = Set<AnyCancellable>()
        var finished = false
        var result: Int?
        upstream.eraseToFuture(fallback: 42).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                finished = true
            case .failure:
                XCTFail("Should not fail")
            }
            expectation.fulfill()
        }, receiveValue: { value in
           result = value
        }).store(in: &cancellables)
        
        upstream.send(3)
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(result, 3)
        XCTAssertTrue(finished)
    }

    func testEraseToFutureWhenUpstreamSendsoMoreThanOneValue() throws {
        let upstream = PassthroughSubject<Int, Error>()
        let expectation = self.expectation(description: "future")
        var cancellables = Set<AnyCancellable>()
        var finished = false
        var result: Int?
        upstream.eraseToFuture(fallback: 42).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                finished = true
            case .failure:
                XCTFail("Should not fail")
            }
            expectation.fulfill()
        }, receiveValue: { value in
           result = value
        }).store(in: &cancellables)
        
        upstream.send(3)
        upstream.send(4)
        upstream.send(5)

        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(result, 3)
        XCTAssertTrue(finished)
    }

    func testEraseToFutureWhenUpstreamSendsNoValue() throws {
        let upstream = PassthroughSubject<Int, Error>()
        let expectation = self.expectation(description: "future")
        var cancellables = Set<AnyCancellable>()
        var finished = false
        var result: Int?
        upstream.eraseToFuture(fallback: 42).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                finished = true
            case .failure:
                XCTFail("Should not fail")
            }
            expectation.fulfill()
        }, receiveValue: { value in
           result = value
        }).store(in: &cancellables)
        
        upstream.send(completion: .finished)

        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(result, 42)
        XCTAssertTrue(finished)
    }

    func testValue() throws {
        let subject = Future<Int, Error>.value(42)
        let result = try waitLast(for: subject)
        XCTAssertEqual(result, 42)
    }
    
    func testError() throws {
        let subject = Future<Int, Error>.error(FakeError())
        XCTAssertThrowsError(try waitLast(for: subject))
    }
    
    func testReduceWhenAllSuccess() throws {
        let sequence = [1, 2, 3, 4, 5]
        let subject = sequence.reduce(0) { sum, value in
            Future<Int, Error>.value(sum + value)
        }
        let result = try waitLast(for: subject)
        XCTAssertEqual(result, 15)
    }
    
    func testReduceWhenOneFails() throws {
        let sequence = [1, 2, 3, 4, 5]
        let subject = sequence.reduce(0) { sum, value -> Future<Int, Error> in
            if value == 3 {
                return Future<Int, Error>.error(FakeError())
            }
            return Future<Int, Error>.value(sum + value)
        }
        XCTAssertThrowsError(try waitLast(for: subject))
    }
}
