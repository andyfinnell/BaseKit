import XCTest
import BaseKit

final class TransformTests: XCTestCase {
    func testTranslate() {
        let subject = Transform(translateX: 15, y: 35)
        XCTAssertEqual(subject.applying(to: Point(x: 10, y: 12)), Point(x: 25, y: 47))
    }
    
    func testRotate() {
        let subject = Transform(rotate: .pi)
        XCTAssertClose(subject.applying(to: Point(x: 10, y: 12)), Point(x: -10, y: -12))
    }
    
    func testScale() {
        let subject = Transform(scaleX: 2, y: 4)
        XCTAssertClose(subject.applying(to: Point(x: 10, y: 12)), Point(x: 20, y: 48))
    }
    
    func testSkewX() {
        let subject = Transform(skewX: .pi / 4.0)
        XCTAssertClose(subject.applying(to: Point(x: 10, y: 12)), Point(x: 22, y: 12))
    }

    func testSkewY() {
        let subject = Transform(skewY: .pi / 4.0)
        XCTAssertClose(subject.applying(to: Point(x: 10, y: 12)), Point(x: 10, y: 22))
    }

    func testConcat() {
        let subject = Transform(translateX: 15, y: 35)
            .concatenating(Transform(rotate: .pi))
            .concatenating(Transform(scaleX: 2, y: 4))
        XCTAssertClose(subject.applying(to: Point(x: 10, y: 12)), Point(x: -5, y: -13))
    }
    
    func testInvert() {
        let forwards = Transform(translateX: 15, y: 35)
            .concatenating(Transform(rotate: .pi))
            .concatenating(Transform(scaleX: 2, y: 4))
        let backwards = forwards.inverted()
                
        XCTAssertClose(
            backwards?.applying(
                to: forwards.applying(to: Point(x: 10, y: 12))
            ),
            Point(x: 10, y: 12)
        )
    }
}
