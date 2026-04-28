import Foundation
import Synchronization

/// Test-only `SettingsStorageProviding` that vends `InMemoryStorage`
/// instances. Each instance lives only for the registry's lifetime, so
/// tests get isolation by constructing a fresh registry per test.
///
/// Note: lives in the BaseKit main target so multiple test modules can
/// import it. Production code must not use it.
public final class InMemorySettingsRegistry: SettingsStorageProviding {
    private struct CachedStorage {
        let valueType: Any.Type
        let storage: any Sendable
    }

    private let cache = Mutex<[String: CachedStorage]>([:])

    public init() {}

    public func storage<Value>(
        for key: SettingsKey<Value>
    ) -> any CodableStorage<Value> {
        cache.withLock { cache in
            if let existing = cache[key.filename] {
                precondition(
                    existing.valueType == Value.self,
                    "SettingsKey filename \(key.filename) reused with mismatched Value type: cached as \(existing.valueType), requested as \(Value.self)"
                )
                guard let storage = existing.storage as? any CodableStorage<Value> else {
                    preconditionFailure("Unreachable: type identity matched but cast failed")
                }
                return storage
            }
            let initial = key.defaultValue?()
            let storage: any CodableStorage<Value> = InMemoryStorage<Value>(initial: initial)
            cache[key.filename] = CachedStorage(valueType: Value.self, storage: storage)
            return storage
        }
    }
}
