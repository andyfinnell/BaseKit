import Foundation

public protocol LogSink: Sendable {
    func print(_ value: String, tag: LogTag, level: LogLevel)
}
