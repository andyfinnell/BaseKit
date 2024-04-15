import XCTest
import BaseKit

enum TestError: Error {
    case stopTheAsync
}

final class ConcurrencyLimiterTests: XCTestCase {
    private var subject: ConcurrencyLimiter!
    
    override func setUp() {
        super.setUp()
        
        subject = ConcurrencyLimiter(concurrency: 3)
    }
    
    func testLimitsToConcurrencySetting() async throws {
        let counter = Counter()
        
        let sum = try await withThrowingTaskGroup(of: Int.self) { taskGroup in
            // Spin up 100 concurrent tasks
            for i in 0..<100 {
                taskGroup.addTask {
                    await self.subject.run {
                        await counter.increment()
                        
                        // do busy work so we don't immediately complete
                        print("task \(i)")
                        
                        await counter.decrement()
                    }
                    return i
                }
            }
            
            // Collect the results (use the summing as an example workload)
            var sum = 0
            for try await result in taskGroup {
                sum += result
            }
            return sum
        }
        
        let max = await counter.maxCount
        XCTAssert(max <= 3)
        XCTAssertEqual(sum, 4950)
    }
    
    func testThrowingWorks() async throws {
        let counter = Counter()
        
        let sum = try await withThrowingTaskGroup(of: Int.self) { taskGroup in
            // Spin up 100 concurrent tasks
            for i in 0..<100 {
                taskGroup.addTask {
                    do {
                        try await self.subject.run {
                            await counter.increment()
                            
                            // do busy work so we don't immediately complete
                            print("task \(i)")
                            
                            await counter.decrement()
                            
                            // Every 5th, throw
                            if i % 5 == 0 {
                                throw TestError.stopTheAsync
                            }
                        }
                    } catch {
                        // We catch here because we only want to test our code,
                        //  the limiter. Specifically it shouldn't break if we
                        //  throw through it. So keep going to verify future
                        //  `runs` work as expected
                    }
                    return i
                }
            }
            
            // Collect the results (use the summing as an example workload)
            var sum = 0
            for try await result in taskGroup {
                sum += result
            }
            return sum
        }
        
        let max = await counter.maxCount
        XCTAssert(max <= 3)
        XCTAssertEqual(sum, 4950)
    }
}

private extension ConcurrencyLimiterTests {
    final actor Counter {
        private var count = 0
        private(set) var maxCount = 0
        
        init() {}
        
        func increment() {
            count += 1
            maxCount = max(count, maxCount)
        }
        
        func decrement() {
            count -= 1
        }
    }
}
