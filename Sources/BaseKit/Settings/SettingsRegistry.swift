import Foundation
import Synchronization

/// Production `SettingsStorageProviding` that caches one `JSONStorage`
/// per filename for the lifetime of the registry.
///
/// Sharing a single storage per filename ensures callers see each other's
/// `store(_:)` writes through their own `makeStream()` subscriptions —
/// independent storages over the same file would each have a private
/// listener table and miss writes from siblings.
public final class SettingsRegistry: SettingsStorageProviding {
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
                // The precondition above guarantees the cached storage's
                // associatedtype matches `Value`, so this cast is safe.
                guard let storage = existing.storage as? any CodableStorage<Value> else {
                    preconditionFailure("Unreachable: type identity matched but cast failed")
                }
                return storage
            }
            let storage: any CodableStorage<Value>
            if let defaultValue = key.defaultValue {
                storage = JSONStorage<Value>(filename: key.filename, defaultValue: defaultValue)
            } else {
                storage = JSONStorage<Value>(filename: key.filename)
            }
            cache[key.filename] = CachedStorage(valueType: Value.self, storage: storage)
            return storage
        }
    }
}
