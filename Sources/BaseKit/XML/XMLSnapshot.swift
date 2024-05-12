import Foundation

public struct XMLSnapshot {
    public let roots: [XMLID]
    public let values: [XMLID: XMLValue]
    
    public init(roots: [XMLID], values: [XMLID: XMLValue]) {
        self.roots = roots
        self.values = values
    }
}

public extension XMLSnapshot {
    init(_ values: XMLValue...) {
        roots = values.map { $0.id }
        self.values = values.reduce(into: [XMLID: XMLValue]()) { sum, value in
            sum[value.id] = value
        }
    }
}
