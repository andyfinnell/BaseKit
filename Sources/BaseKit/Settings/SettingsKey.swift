import Foundation

/// Typed handle identifying a single settings file.
///
/// `Value` carries through to `SettingsStorageProviding.storage(for:)`,
/// giving each call site compile-time knowledge of the stored type.
public struct SettingsKey<Value: Codable & Sendable>: Sendable {
    public let filename: String
    public let defaultValue: (@Sendable () -> Value)?

    public init(
        filename: String,
        defaultValue: (@Sendable () -> Value)? = nil
    ) {
        self.filename = filename
        self.defaultValue = defaultValue
    }
}
