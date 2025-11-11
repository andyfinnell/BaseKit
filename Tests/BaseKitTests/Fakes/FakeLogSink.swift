import Foundation
import BaseKit
import TestKit

final class FakeLogSink: LogSink {
    let print_fake = SendableMethodCall((value: String, tag: LogTag, level: LogLevel).self, ())
    func print(_ value: String, tag: LogTag, level: LogLevel) {
        print_fake.fake((value, tag, level))
    }
}
