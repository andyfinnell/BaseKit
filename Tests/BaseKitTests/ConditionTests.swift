import XCTest
import BaseKit

final class ConditionTests: XCTestCase {
    
    func testWaitDoesNotResumeUntilSignaled() async {
        let (condition, _) = Condition.makeCondition()
        
        let finishExpectation = expectation(description: "will wait")
        finishExpectation.isInverted = true
        Task {
            await condition.wait()
            finishExpectation.fulfill()
        }
        
        await fulfillment(of: [finishExpectation], timeout: 0.5)
    }
    
    func testWaitDoesResumeWhenSignaled() async {
        let (condition, signal) = Condition.makeCondition()
        
        let finishExpectation = expectation(description: "will complete")
        Task {
            await condition.wait()
            finishExpectation.fulfill()
        }
        
        signal.signal()
        await fulfillment(of: [finishExpectation], timeout: 1.0)
    }

    func testWaitDoesResumeWhenSignaledBefore() async {
        let (condition, signal) = Condition.makeCondition()
        signal.signal()

        let finishExpectation = expectation(description: "will complete")
        Task {
            await condition.wait()
            finishExpectation.fulfill()
        }
        
        await fulfillment(of: [finishExpectation], timeout: 1.0)
    }

}

