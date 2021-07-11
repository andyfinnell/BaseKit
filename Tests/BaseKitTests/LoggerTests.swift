import Foundation
import XCTest
import BaseKit
import TestKit

final class LoggerTests: XCTestCase {
    private var subject: Logger!
    private var sink1: FakeLogSink!
    private var sink2: FakeLogSink!
    
    override func setUp() {
        sink1 = FakeLogSink()
        sink2 = FakeLogSink()
        // Add sinks two different ways to verify both
        subject = Logger(sinks: [sink1])
        subject.addSink(sink2)
        
        subject.isEnabled = true
    }
    
    func testInfoWhenEnabled() {
        subject.info("test test test", tag: .general)
        
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.value, "test test test")
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.level, .info)
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.tag, .general)

        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.value, "test test test")
        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.level, .info)
        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.tag, .general)
    }
    
    func testDebugWhenEnabled() {
        subject.debug("test test test", tag: .http)
        
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.value, "test test test")
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.level, .debug)
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.tag, .http)

        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.value, "test test test")
        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.level, .debug)
        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.tag, .http)
    }

    func testErrorWhenEnabled() {
        subject.error("test test test", tag: .general)
        
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.value, "test test test")
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.level, .error)
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.tag, .general)

        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.value, "test test test")
        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.level, .error)
        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.tag, .general)
    }

    func testFaultWhenEnabled() {
        subject.fault("test test test", tag: .general)
        
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.value, "test test test")
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.level, .fault)
        XCTAssertMethodWasCalledWithArgEquals(sink1.print_fake, \.tag, .general)

        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.value, "test test test")
        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.level, .fault)
        XCTAssertMethodWasCalledWithArgEquals(sink2.print_fake, \.tag, .general)
    }

    func testErrorWhenDisabled() {
        subject.isEnabled = false
        
        var didExecute = false
        let closure = { () -> Loggable in
            didExecute = true
            return "test test test"
        }
        
        subject.error(closure(), tag: .general)
        
        XCTAssertFalse(didExecute)
        XCTAssertMethodWasNotCalled(sink1.print_fake)
        XCTAssertMethodWasNotCalled(sink2.print_fake)
    }
}
