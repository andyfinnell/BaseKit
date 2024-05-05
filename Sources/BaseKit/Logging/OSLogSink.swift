import Foundation
import os

public final class OSLogSink: LogSink {
    private var logs = [LogTag: OSLog]()

    public init() {}
    
    public func print(_ value: String, tag: LogTag, level: LogLevel) {
        let l = log(for: tag)
        os_log("%{public}@", log: l, type: level.type, value)
    }
}

private extension OSLogSink {
    func log(for tag: LogTag) -> OSLog {
        guard let cachedLog = logs[tag] else {
            let subsystem = Bundle.main.bundleIdentifier ?? "com.losingfight.basekit.default"
            let log = OSLog(subsystem: subsystem, category: tag.rawValue)
            logs[tag] = log
            return log
        }
        return cachedLog
    }
}

private extension LogLevel {
    var type: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .error:
            return .error
        case .info:
            return .info
        case .fault:
            return .fault
        }
    }
}
