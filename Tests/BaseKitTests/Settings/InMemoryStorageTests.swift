import Testing
import BaseKit

@Suite struct InMemoryStorageTests {
    struct Settings: Codable, Sendable, Equatable {
        var count: Int
    }

    @Test func streamYieldsInitialValue() async {
        let storage = InMemoryStorage<Settings>(initial: Settings(count: 7))

        var iterator = await storage.makeStream().makeAsyncIterator()
        let first = await iterator.next()

        #expect(first == Settings(count: 7))
    }

    @Test func streamSkipsInitialWhenNoValueProvided() async throws {
        let storage = InMemoryStorage<Settings>()
        var iterator = await storage.makeStream().makeAsyncIterator()

        try await storage.store(Settings(count: 1))

        let first = await iterator.next()
        #expect(first == Settings(count: 1))
    }

    @Test func storeBroadcastsToAllSubscribers() async throws {
        let storage = InMemoryStorage<Settings>()
        var iteratorA = await storage.makeStream().makeAsyncIterator()
        var iteratorB = await storage.makeStream().makeAsyncIterator()

        try await storage.store(Settings(count: 42))

        let a = await iteratorA.next()
        let b = await iteratorB.next()
        #expect(a == Settings(count: 42))
        #expect(b == Settings(count: 42))
    }
}
