import BaseKit
import Testing

struct GradientUtilsTests {
    // MARK: - axisT

    @Test func axisTAtStartIsZero() {
        let gradient = makeLinearGradient(start: Point(x: 0, y: 0), end: Point(x: 100, y: 0))
        #expect(gradient.axisT(at: Point(x: 0, y: 0)) == 0)
    }

    @Test func axisTAtEndIsOne() {
        let gradient = makeLinearGradient(start: Point(x: 0, y: 0), end: Point(x: 100, y: 0))
        #expect(gradient.axisT(at: Point(x: 100, y: 0)) == 1)
    }

    @Test func axisTAtMidpointIsHalf() {
        let gradient = makeLinearGradient(start: Point(x: 0, y: 0), end: Point(x: 100, y: 0))
        #expect(gradient.axisT(at: Point(x: 50, y: 0)) == 0.5)
    }

    @Test func axisTOnDiagonalAxis() {
        let gradient = makeLinearGradient(start: Point(x: 0, y: 0), end: Point(x: 10, y: 10))
        #expect(abs(gradient.axisT(at: Point(x: 5, y: 5)) - 0.5) < 1e-9)
    }

    @Test func axisTPerpendicularProjectsToZero() {
        // Off-axis point: projection onto the axis lands at the start.
        let gradient = makeLinearGradient(start: Point(x: 0, y: 0), end: Point(x: 100, y: 0))
        #expect(gradient.axisT(at: Point(x: 0, y: 50)) == 0)
    }

    @Test func axisTBeyondEndExceedsOne() {
        // Caller must clamp if they want [0, 1]; the raw scalar projection
        // is informative for off-segment detection.
        let gradient = makeLinearGradient(start: Point(x: 0, y: 0), end: Point(x: 100, y: 0))
        #expect(gradient.axisT(at: Point(x: 150, y: 0)) == 1.5)
    }

    @Test func axisTBeforeStartIsNegative() {
        let gradient = makeLinearGradient(start: Point(x: 0, y: 0), end: Point(x: 100, y: 0))
        #expect(gradient.axisT(at: Point(x: -50, y: 0)) == -0.5)
    }

    @Test func axisTOnDegenerateAxisIsZero() {
        let gradient = makeLinearGradient(start: Point(x: 50, y: 50), end: Point(x: 50, y: 50))
        #expect(gradient.axisT(at: Point(x: 50, y: 50)) == 0)
        #expect(gradient.axisT(at: Point(x: 999, y: 999)) == 0)
    }

    // MARK: - color(at:)

    @Test func colorAtMidpointInterpolates() {
        let gradient = makeLinearGradient(
            start: .zero, end: Point(x: 100, y: 0),
            stops: [
                Gradient.Stop(offset: 0, color: .red),
                Gradient.Stop(offset: 1, color: .blue),
            ]
        )
        let color = gradient.color(at: 0.5)
        #expect(color?.red == 0.5)
        #expect(color?.green == 0.0)
        #expect(color?.blue == 0.5)
        #expect(color?.alpha == 1.0)
    }

    @Test func colorAtStopOffsetReturnsThatStopColor() {
        let gradient = makeLinearGradient(
            start: .zero, end: Point(x: 100, y: 0),
            stops: [
                Gradient.Stop(offset: 0, color: .red),
                Gradient.Stop(offset: 0.5, color: .green),
                Gradient.Stop(offset: 1, color: .blue),
            ]
        )
        #expect(gradient.color(at: 0.5) == .green)
    }

    @Test func colorBelowFirstStopClampsToFirstColor() {
        let gradient = makeLinearGradient(
            start: .zero, end: Point(x: 100, y: 0),
            stops: [
                Gradient.Stop(offset: 0.25, color: .red),
                Gradient.Stop(offset: 0.75, color: .blue),
            ]
        )
        #expect(gradient.color(at: 0) == .red)
        #expect(gradient.color(at: -1) == .red)
    }

    @Test func colorAboveLastStopClampsToLastColor() {
        let gradient = makeLinearGradient(
            start: .zero, end: Point(x: 100, y: 0),
            stops: [
                Gradient.Stop(offset: 0.25, color: .red),
                Gradient.Stop(offset: 0.75, color: .blue),
            ]
        )
        #expect(gradient.color(at: 1) == .blue)
        #expect(gradient.color(at: 99) == .blue)
    }

    @Test func colorWithUnsortedStopsStillInterpolates() {
        // Document order != offset order — extension should sort internally.
        let gradient = makeLinearGradient(
            start: .zero, end: Point(x: 100, y: 0),
            stops: [
                Gradient.Stop(offset: 1, color: .blue),
                Gradient.Stop(offset: 0, color: .red),
            ]
        )
        let color = gradient.color(at: 0.5)
        #expect(color?.red == 0.5)
        #expect(color?.blue == 0.5)
    }

    @Test func colorWithNoStopsReturnsNil() {
        let gradient = makeLinearGradient(
            start: .zero, end: Point(x: 100, y: 0),
            stops: []
        )
        #expect(gradient.color(at: 0.5) == nil)
    }

    @Test func colorWithSingleStopReturnsThatStop() {
        let gradient = makeLinearGradient(
            start: .zero, end: Point(x: 100, y: 0),
            stops: [Gradient.Stop(offset: 0.3, color: .green)]
        )
        #expect(gradient.color(at: 0) == .green)
        #expect(gradient.color(at: 0.3) == .green)
        #expect(gradient.color(at: 1) == .green)
    }

    @Test func colorInterpolatesAlphaChannel() {
        let gradient = makeLinearGradient(
            start: .zero, end: Point(x: 100, y: 0),
            stops: [
                Gradient.Stop(
                    offset: 0,
                    color: Color(red: 0, green: 0, blue: 0, alpha: 0)),
                Gradient.Stop(
                    offset: 1,
                    color: Color(red: 0, green: 0, blue: 0, alpha: 1)),
            ]
        )
        #expect(gradient.color(at: 0.5)?.alpha == 0.5)
    }
}

private extension GradientUtilsTests {
    func makeLinearGradient(
        start: Point,
        end: Point,
        stops: [Gradient.Stop] = [
            Gradient.Stop(offset: 0, color: .red),
            Gradient.Stop(offset: 1, color: .blue),
        ]
    ) -> Gradient {
        Gradient(
            kind: .linear,
            start: start,
            end: end,
            stops: stops,
            boundingBox: nil
        )
    }
}
