import BaseKit
import Foundation
import os
import Testing

@Suite struct AsyncStreamSubscriptionTests {
    @Test func sinkDeliversYieldedValues() async {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        let received = OSAllocatedUnfairLock(initialState: [Int]())

        let subscription = stream.sink { value in
            received.withLock { $0.append(value) }
        }

        continuation.yield(1)
        continuation.yield(2)
        continuation.yield(3)
        await yieldRunloop()

        #expect(received.withLock { $0 } == [1, 2, 3])
        subscription.cancel()
    }

    @Test func cancelStopsDelivery() async {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        let received = OSAllocatedUnfairLock(initialState: [Int]())

        let subscription = stream.sink { value in
            received.withLock { $0.append(value) }
        }

        continuation.yield(1)
        await yieldRunloop()

        subscription.cancel()
        await yieldRunloop()

        continuation.yield(2)
        await yieldRunloop()

        #expect(received.withLock { $0 } == [1])
    }

    @Test func droppingSubscriptionCancelsTask() async {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        let received = OSAllocatedUnfairLock(initialState: [Int]())

        var subscription: AsyncStreamSubscription? = stream.sink { value in
            received.withLock { $0.append(value) }
        }
        _ = subscription

        continuation.yield(1)
        await yieldRunloop()

        subscription = nil
        await yieldRunloop()

        continuation.yield(2)
        await yieldRunloop()

        #expect(received.withLock { $0 } == [1])
    }

    @Test func subscriptionsHaveDistinctIdentityInSet() {
        let (streamA, _) = AsyncStream<Int>.makeStream()
        let (streamB, _) = AsyncStream<Int>.makeStream()
        let a = streamA.sink { _ in }
        let b = streamB.sink { _ in }

        var set: Set<AsyncStreamSubscription> = []
        set.insert(a)
        set.insert(b)
        set.insert(a)

        #expect(set.count == 2)
        #expect(set.contains(a))
        #expect(set.contains(b))
        a.cancel()
        b.cancel()
    }

    @Test func storeInSetInserts() {
        let (stream, _) = AsyncStream<Int>.makeStream()
        let subscription = stream.sink { _ in }

        var set: Set<AsyncStreamSubscription> = []
        subscription.store(in: &set)

        #expect(set.contains(subscription))
        #expect(set.count == 1)
        subscription.cancel()
    }

    @Test func storeInArrayAppends() {
        let (stream, _) = AsyncStream<Int>.makeStream()
        let subscription = stream.sink { _ in }

        var array: [AsyncStreamSubscription] = []
        subscription.store(in: &array)

        #expect(array.count == 1)
        #expect(array.first === subscription)
        subscription.cancel()
    }

    @Test func elementlessSinkFiresOncePerYield() async {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        let count = OSAllocatedUnfairLock(initialState: 0)

        let subscription = stream.sink {
            count.withLock { $0 += 1 }
        }

        continuation.yield(1)
        continuation.yield(2)
        continuation.yield(3)
        await yieldRunloop()

        #expect(count.withLock { $0 } == 3)
        subscription.cancel()
    }

    @Test func elementlessWeakSinkPassesObjectToBody() async {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        let owner = TestOwner()

        let subscription = stream.sink(owner) { owner in
            owner.calls.withLock { $0.append(0) }
        }

        continuation.yield(1)
        continuation.yield(2)
        await yieldRunloop()

        #expect(owner.calls.withLock { $0 } == [0, 0])
        subscription.cancel()
    }

    @Test func curriedMethodSinkInvokesMethod() async {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        let owner = TestOwner()

        let subscription = stream.sink(owner, TestOwner.tick)

        continuation.yield(1)
        continuation.yield(2)
        await yieldRunloop()

        #expect(owner.calls.withLock { $0 } == [-1, -1])
        subscription.cancel()
    }

    @Test func weakSinkPassesObjectToBody() async {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        let owner = TestOwner()

        let subscription = stream.sink(owner) { owner, value in
            owner.calls.withLock { $0.append(value) }
        }

        continuation.yield(1)
        continuation.yield(2)
        await yieldRunloop()

        #expect(owner.calls.withLock { $0 } == [1, 2])
        subscription.cancel()
    }

    @Test func weakSinkStopsAfterOwnerDeallocates() async {
        let (stream, continuation) = AsyncStream<Int>.makeStream()
        let externalCalls = OSAllocatedUnfairLock(initialState: 0)
        var owner: TestOwner? = TestOwner()

        let subscription = stream.sink(owner!) { _, _ in
            externalCalls.withLock { $0 += 1 }
        }

        continuation.yield(1)
        await yieldRunloop()
        #expect(externalCalls.withLock { $0 } == 1)

        owner = nil
        await yieldRunloop()

        continuation.yield(2)
        await yieldRunloop()

        #expect(externalCalls.withLock { $0 } == 1)
        subscription.cancel()
    }
}

private final class TestOwner: Sendable {
    let calls = OSAllocatedUnfairLock(initialState: [Int]())

    func tick() {
        calls.withLock { $0.append(-1) }
    }
}

private func yieldRunloop() async {
    for _ in 0..<20 { await Task.yield() }
}
