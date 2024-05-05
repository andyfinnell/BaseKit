import Foundation
import os

public enum LogLevel: Hashable {
    case info, debug, error, fault
}

public protocol LoggerType {
    func info(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func debug(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func error(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func fault(_ value: @autoclosure () -> Loggable, tag: LogTag)
}

public final class Logger: LoggerType {
    private var sinks: [LogSink]
    
    public init(sinks: [LogSink] = [OSLogSink()]) {
        self.sinks = sinks
    }
    
    public func addSink(_ sink: LogSink) {
        sinks.append(sink)
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
    
    public var isEnabled: Bool = Logger.isEnabledDefault
}
 
private extension Logger {
    func print(_ value: () -> Loggable, tag: LogTag, level: LogLevel) {
        guard isEnabled else {
            return
        }
        
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
