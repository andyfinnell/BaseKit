import Foundation
import BaseKit
import TestKit

final class FakeLogSink: LogSink {
    lazy var print_fake = FakeMethodCall((value: String, tag: LogTag, level: LogLevel).self, ())
    func print(_ value: String, tag: LogTag, level: LogLevel) {
        print_fake.fake((value, tag, level))
    }
}
