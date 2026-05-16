public struct Vector: Hashable, Codable, Sendable {
    public var dx: Real
    public var dy: Real

    public init(dx: Real, dy: Real) {
        self.dx = dx
        self.dy = dy
    }

    public static let zero = Vector(dx: 0, dy: 0)
}
