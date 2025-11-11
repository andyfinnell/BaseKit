import Foundation
import os

public enum LogLevel: Hashable, Sendable {
    case info, debug, error, fault
}

public protocol LoggerType: Sendable {
    func info(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func debug(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func error(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func fault(_ value: @autoclosure () -> Loggable, tag: LogTag)
}

public final class Logger: LoggerType {
    private let memberData: OSAllocatedUnfairLock<MemberData>
    
    public init(sinks: [LogSink] = [OSLogSink()]) {
        memberData = OSAllocatedUnfairLock(uncheckedState: MemberData(sinks: sinks, isEnabled: Logger.isEnabledDefault))
    }
    
    public func addSink(_ sink: LogSink) {
        memberData.withLock {
            $0.sinks.append(sink)
        }
    }
    
    public func info(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        print(value, tag: tag, level: .info)
    }

    public func debug(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        print(value, tag: tag, level: .debug)
    }
    
    public func error(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        print(value, tag: tag, level: .error)
    }
    
    public func fault(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        print(value, tag: tag, level: .fault)
    }
    
    public var isEnabled: Bool {
        get { memberData.withLock { $0.isEnabled } }
        set { memberData.withLock { $0.isEnabled = newValue } }
    }
}
 
private extension Logger {
    struct MemberData {
        var sinks: [LogSink]
        var isEnabled: Bool
    }
    
    func print(_ value: () -> Loggable, tag: LogTag, level: LogLevel) {
        guard isEnabled else {
            return
        }
        
        let sinks = memberData.withLock { $0.sinks }
        value().log { string in
            for sink in sinks {
                sink.print(string, tag: tag, level: level)
            }
        }
    }

    static var isEnabledDefault: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
