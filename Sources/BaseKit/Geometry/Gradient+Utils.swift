import Foundation

public extension Gradient {
    /// Scalar projection of `point` onto the gradient's start→end axis,
    /// normalized so the start endpoint returns 0 and the end endpoint
    /// returns 1. Returns 0 for a degenerate gradient (start == end).
    ///
    /// `point` must be in gradient-local space (the same space as `start`
    /// and `end`). Values outside `[0, 1]` mean the point is past one of
    /// the endpoints along the axis, which is meaningful for callers that
    /// want to detect off-axis clicks.
    ///
    /// The same formula serves linear and radial gradients: for radial,
    /// the axis runs center → edge, so `t` becomes the fractional radius.
    func axisT(at point: Point) -> Double {
        let axis = end - start
        let lenSq = axis.x * axis.x + axis.y * axis.y
        guard lenSq > 0 else { return 0 }
        let v = point - start
        return (v.x * axis.x + v.y * axis.y) / lenSq
    }

    /// Returns the color at parameter `t` along this gradient's color
    /// ramp via component-wise sRGB lerp between the two stops bracketing
    /// `t`. Out-of-range `t` clamps to the first or last stop (matching
    /// SVG's default `spreadMethod="pad"`). Returns `nil` if the gradient
    /// has no stops.
    func color(at t: Double) -> Color? {
        let sorted = stops.sorted { $0.offset < $1.offset }
        guard let first = sorted.first else { return nil }
        if t <= first.offset { return first.color }
        guard let last = sorted.last else { return first.color }
        if t >= last.offset { return last.color }
        for i in 0..<(sorted.count - 1) {
            let a = sorted[i]
            let b = sorted[i + 1]
            if t >= a.offset && t <= b.offset {
                let span = b.offset - a.offset
                let frac = span > 0 ? (t - a.offset) / span : 0
                return Color(
                    red: a.color.red + (b.color.red - a.color.red) * frac,
                    green: a.color.green + (b.color.green - a.color.green) * frac,
                    blue: a.color.blue + (b.color.blue - a.color.blue) * frac,
                    alpha: a.color.alpha + (b.color.alpha - a.color.alpha) * frac
                )
            }
        }
        return first.color
    }
}
