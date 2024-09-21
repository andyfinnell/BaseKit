import Foundation

public struct XMLSnapshot: Sendable {
    public let roots: [XMLID]
    public let values: [XMLID: XMLValue]
    
    public init(roots: [XMLID], values: [XMLID: XMLValue]) {
        self.roots = roots
        self.values = values
    }
}

public extension XMLSnapshot {
    init(_ values: XMLValue...) {
        self.init(values: values)
    }
    
    init(values: [XMLValue]) {
        roots = values.map { $0.id }
        self.values = values.reduce(into: [XMLID: XMLValue]()) { sum, value in
            sum[value.id] = value
        }
    }
    
    init<Content: XML>(parentID: XMLID?, @XMLSnapshotBuilder builder: () -> Content) {
        let built = builder()
        var storage = [XMLID: XMLValue]()
        let context = XMLBuilderContext()
        roots = built.values(for: parentID, context: context, storingInto: &storage).map(\.id)
        values = storage
    }
}
