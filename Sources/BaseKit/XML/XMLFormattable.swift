public struct XMLFormatContext {
    public let variables: [String: String]
    
    public init(variables: [String : String]) {
        self.variables = variables
    }
}

public protocol XMLFormattable {
    func xmlFormatted(using context: XMLFormatContext) -> String
}

extension Double: XMLFormattable {
    public func xmlFormatted(using context: XMLFormatContext) -> String {
        formatted(.number.grouping(.never))
    }
}

extension String: XMLFormattable {
    public func xmlFormatted(using context: XMLFormatContext) -> String {
        self
    }
}
