import Foundation
import Testing
import BaseKit

@Suite struct JSONStorageTests {
    struct Settings: Codable, Sendable, Equatable {
        var count: Int
    }

    @Test func freshStorageReadsFromDisk() async throws {
        let filename = uniqueFilename()
        defer { deleteFile(named: filename) }
        let writer = JSONStorage<Settings>(filename: filename)
        try await writer.store(Settings(count: 7))

        // Brand-new actor instance has an empty cache; the first read
        // must hit disk and pick up the previously persisted value.
        let reader = JSONStorage<Settings>(filename: filename)
        var iterator = await reader.makeStream().makeAsyncIterator()
        let value = await iterator.next()
        #expect(value == Settings(count: 7))
    }

    @Test func subsequentReadsServeFromCache() async throws {
        let filename = uniqueFilename()
        defer { deleteFile(named: filename) }
        let storage = JSONStorage<Settings>(filename: filename)
        try await storage.store(Settings(count: 42))

        // Delete the file out from under the cache. If reads were
        // hitting disk, the next stream would yield nil. With the
        // cache, it must still yield the stored value.
        deleteFile(named: filename)

        var iterator = await storage.makeStream().makeAsyncIterator()
        let value = await iterator.next()
        #expect(value == Settings(count: 42))
    }

    @Test func storeUpdatesCache() async throws {
        let filename = uniqueFilename()
        defer { deleteFile(named: filename) }
        let storage = JSONStorage<Settings>(filename: filename)
        try await storage.store(Settings(count: 1))
        try await storage.store(Settings(count: 2))

        // After deleting disk state, the cache must reflect the most
        // recent store, not an earlier one.
        deleteFile(named: filename)

        var iterator = await storage.makeStream().makeAsyncIterator()
        let value = await iterator.next()
        #expect(value == Settings(count: 2))
    }

    @Test func defaultValueIsCachedOnFirstReadOfMissingFile() async throws {
        let filename = uniqueFilename()
        defer { deleteFile(named: filename) }
        let storage = JSONStorage<Settings>(
            filename: filename,
            defaultValue: { Settings(count: 99) }
        )

        // First read populates the cache from the default (no file exists).
        var iteratorA = await storage.makeStream().makeAsyncIterator()
        let first = await iteratorA.next()
        #expect(first == Settings(count: 99))

        // A second stream must serve from the cached default rather than
        // re-invoking the closure or re-attempting disk load.
        var iteratorB = await storage.makeStream().makeAsyncIterator()
        let second = await iteratorB.next()
        #expect(second == Settings(count: 99))
    }
}

private func uniqueFilename() -> String {
    "JSONStorageTest-\(UUID().uuidString)"
}

private func deleteFile(named filename: String) {
    guard let appSupport = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    ).first else { return }
    let url = appSupport.appendingPathComponent("\(filename).json")
    try? FileManager.default.removeItem(at: url)
}
