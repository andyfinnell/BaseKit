import Testing
import BaseKit

@Suite struct SettingsRegistryTests {
    struct Settings: Codable, Sendable, Equatable {
        var value: Int
    }

    @Test func inMemoryRegistryReturnsSharedStorageForSameKey() async throws {
        let registry = InMemorySettingsRegistry()
        let key = SettingsKey<Settings>(filename: "shared")

        let storageA = registry.storage(for: key)
        let storageB = registry.storage(for: key)

        // Behavioral check: a write through one handle is observed through
        // the other's stream subscription. That only holds if both handles
        // point at the same underlying storage instance.
        var iterator = await storageB.makeStream().makeAsyncIterator()
        try await storageA.store(Settings(value: 99))

        let observed = await iterator.next()
        #expect(observed == Settings(value: 99))
    }

    @Test func inMemoryRegistryAppliesDefaultValueOnFirstRead() async {
        let registry = InMemorySettingsRegistry()
        let key = SettingsKey<Settings>(
            filename: "with-default",
            defaultValue: { Settings(value: 11) }
        )

        let storage = registry.storage(for: key)

        var iterator = await storage.makeStream().makeAsyncIterator()
        let first = await iterator.next()
        #expect(first == Settings(value: 11))
    }

    @Test func inMemoryRegistryIsolatesSeparateRegistries() async throws {
        let registryA = InMemorySettingsRegistry()
        let registryB = InMemorySettingsRegistry()
        let key = SettingsKey<Settings>(filename: "isolated")

        let storageA = registryA.storage(for: key)
        let storageB = registryB.storage(for: key)

        try await storageA.store(Settings(value: 1))
        try await storageB.store(Settings(value: 2))

        // If the registries shared state, both stores would land in the
        // same storage and both streams would yield the last write.
        var iteratorA = await storageA.makeStream().makeAsyncIterator()
        var iteratorB = await storageB.makeStream().makeAsyncIterator()
        let firstA = await iteratorA.next()
        let firstB = await iteratorB.next()

        #expect(firstA == Settings(value: 1))
        #expect(firstB == Settings(value: 2))
    }
}
