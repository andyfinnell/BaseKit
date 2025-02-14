
public struct Rect: Hashable, Codable, Sendable {
    public var origin: Point
    public var size: Size
    
    public var x: Real { origin.x }
    public var y: Real { origin.y }
    public var width: Real { size.width }
    public var height: Real { size.height }
    
    public var minX: Real { x }
    public var midX: Real { (minX + maxX) / 2.0 }
    public var maxX: Real { x + width }
    public var minY: Real { y }
    public var midY: Real { (minY + maxY) / 2.0 }
    public var maxY: Real { y + height }
    
    public init(x: Real, y: Real, width: Real, height: Real) {
        self.origin = .init(x: x, y: y)
        self.size = .init(width: width, height: height)
    }
    
    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
    
    public init(point1: Point, point2: Point) {
        self.origin = Point(x: min(point1.x, point2.x), y: min(point1.y, point2.y))
        self.size = Size(
            width: max(point1.x, point2.x) - min(point1.x, point2.x),
            height: max(point1.y, point2.y) - min(point1.y, point2.y)
        )
    }
    
    public static let zero = Rect(origin: .zero, size: .zero)
    
    public func union(_ other: Rect) -> Rect {
        let left = min(minX, other.minX)
        let right = max(maxX, other.maxX)
        let top = min(minY, other.minY)
        let bottom = max(maxY, other.maxY)
        return Rect(x: left, y: top, width: right - left, height: bottom - top)
    }
    
    public func contains(_ point: Point) -> Bool {
        point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
    }
    
    public func isClose(to other: Rect, threshold: Real) -> Bool {
        origin.isClose(to: other.origin, threshold: threshold)
        && size.isClose(to: other.size, threshold: threshold)
    }
}

public extension Optional where Wrapped == Rect {
    func union(_ other: Rect) -> Rect {
        map { $0.union(other) } ?? other
    }
}
