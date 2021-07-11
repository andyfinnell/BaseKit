import Foundation

public protocol LogSink {
    func print(_ value: String, tag: LogTag, level: LogLevel)
}
