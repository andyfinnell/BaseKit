import Foundation

/// a, c, tx
/// b, d, ty
/// 0, 0, 1
public struct Transform: Hashable, Codable, Sendable {
    public let a: Real
    public let b: Real
    public let c: Real
    public let d: Real
    public let translateX: Real
    public let translateY: Real
    
    public init(
        a: Real = 1,
        b: Real = 0,
        c: Real = 0,
        d: Real = 1,
        translateX: Real = 0,
        translateY: Real = 0
    ) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.translateX = translateX
        self.translateY = translateY
    }
}

public extension Transform {
    init(translateX x: Real, y: Real) {
        self.init(translateX: x, translateY: y)
    }
    
    init(scaleX: Real, y scaleY: Real) {
        self.init(a: scaleX, d: scaleY)
    }
    
    init(scale: Real) {
        self.init(a: scale, d: scale)
    }
    
    init(rotate angle: Real) {
        self.init(
            a: cos(angle),
            b: sin(angle),
            c: -sin(angle),
            d: cos(angle)
        )
    }
    
    init(skewX angle: Real) {
        self.init(c: tan(angle))
    }
    
    init(skewY angle: Real) {
        self.init(b: tan(angle))
    }
    
    func concatenating(_ other: Transform) -> Transform {
        Transform(
            a: a * other.a + c * other.b,
            b: b * other.a + d * other.b,
            c: a * other.c + c * other.d,
            d: b * other.c + d * other.d,
            translateX: a * other.translateX + c * other.translateY + translateX,
            translateY: b * other.translateX + d * other.translateY + translateY
        )
    }
    
    func inverted() -> Transform? {
        // See: http://negativeprobability.blogspot.com/2011/11/affine-transformations-and-their.html
        // Affine transform inversion (instead of matrix inversion)
        let det = determinant()
        guard det != 0.0 else {
            return nil
        }
        return Transform(
            a: d / det,
            b: -b / det,
            c: -c / det,
            d: a / det,
            translateX: (-translateX * d - translateY * c) / det,
            translateY: (-translateY * a + translateX * b) / det
        )
    }
    
    func applying(to point: Point) -> Point {
        Point(
            x: point.x * a + point.y * c + translateX,
            y: point.x * b + point.y * d + translateY
        )
    }
    
    func determinant() -> Real {
        (a * d) - (b * c)
    }
    
    static let identity = Transform()
}
