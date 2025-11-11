import Foundation
import os

public final class OSLogSink: LogSink {
    private let memberData = OSAllocatedUnfairLock(uncheckedState: MemberData())

    public init() {}
    
    public func print(_ value: String, tag: LogTag, level: LogLevel) {
        let l = log(for: tag)
        os_log("%{public}@", log: l, type: level.type, value)
    }
}

private extension OSLogSink {
    struct MemberData {
        var logs = [LogTag: OSLog]()
    }
    
    func log(for tag: LogTag) -> OSLog {
        memberData.withLock {
            guard let cachedLog = $0.logs[tag] else {
                let subsystem = Bundle.main.bundleIdentifier ?? "com.losingfight.basekit.default"
                let log = OSLog(subsystem: subsystem, category: tag.rawValue)
                $0.logs[tag] = log
                return log
            }
            return cachedLog
        }
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
