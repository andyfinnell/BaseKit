public enum Paint: Hashable, Codable, Sendable {
    case solid(Color)
    case pattern(Pattern)
    case gradient(Gradient)
}
