
/// This protocol contains displayable attributes like NSBezierPath or UIBezierPath
/// might have.
public protocol BezierPathRenderable: BezierPathRepresentable {
    var fillRule: FillRule { get set }
    var strokeLineWidth: Real { get set }
    var strokeLineCap: LineCap { get set }
    var strokeLineJoin: LineJoin { get set }
    var miterLimit: Real { get set }
    var flatness: Real { get set }
    
    mutating func setLineDash(_ pattern: [Real], phase: Real)
}

extension BezierPathRenderable {
    mutating func copyAttributes<B: BezierPathRenderable>(from other: B) {
        fillRule = other.fillRule
        strokeLineWidth = other.strokeLineWidth
        strokeLineCap = other.strokeLineCap
        strokeLineJoin = other.strokeLineJoin
        miterLimit = other.miterLimit
        flatness = other.flatness
    }
}
