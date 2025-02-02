public struct LineDash: Hashable, Sendable {
    public let phase: Real
    public let lengths: [Real]
    
    public init(phase: Real, lengths: [Real]) {
        self.phase = phase
        self.lengths = lengths
    }
}

public extension LineDash {
    var isSet: Bool { !lengths.isEmpty }
    
    static let none = LineDash(phase: 0, lengths: [])
}
