public struct Point: Hashable, Codable, Sendable {
    public var x: Real
    public var y: Real
    
    public init(x: Real, y: Real) {
        self.x = x
        self.y = y
    }
    
    public static let zero = Point(x: 0, y: 0)
    
    public func update(minX: inout Real?, maxX: inout Real?, minY: inout Real?, maxY: inout Real?) {
        minX = minX.map { min($0, x) } ?? x
        maxX = maxX.map { max($0, x) } ?? x
        minY = minY.map { min($0, y) } ?? y
        maxY = maxY.map { max($0, y) } ?? y
    }
    
    public func roundedToPixel() -> Point {
        Point(x: x.rounded(), y: y.rounded())
    }
}
