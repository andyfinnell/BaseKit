public struct BezierCurveLocation: Hashable, Sendable {
    public let parameter: Real
    public let distance: Real
    
    public init(parameter: Real, distance: Real) {
        self.parameter = parameter
        self.distance = distance
    }
}
