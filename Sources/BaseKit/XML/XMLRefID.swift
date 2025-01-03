public struct XMLRefID: XMLFormattable, Sendable {
    private let name: String
    private let transform: @Sendable (String) -> String
    
    public init(_ name: String, transform: @escaping @Sendable (String) -> String = { $0 }) {
        self.name = name
        self.transform = transform
    }
    
    public func xmlFormatted(using context: XMLFormatContext) -> String {
        guard let base = context.variables[name] else {
            return ""
        }
        return transform(base)
    }
}
