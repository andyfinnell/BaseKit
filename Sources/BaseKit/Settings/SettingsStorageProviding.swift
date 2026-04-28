import Foundation

/// Vends `CodableStorage` instances keyed by `SettingsKey`.
///
/// Conformers are expected to return the same instance for repeated
/// requests with the same `SettingsKey.filename`, so callers can rely on
/// a single source of truth (and shared change broadcast) per file.
public protocol SettingsStorageProviding: Sendable {
    func storage<Value>(for key: SettingsKey<Value>) -> any CodableStorage<Value>
}
