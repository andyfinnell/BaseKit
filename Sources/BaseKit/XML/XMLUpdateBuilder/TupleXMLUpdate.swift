
public struct TupleXMLUpdate<each X: XMLUpdate>: XMLUpdate {
    let xml: (repeat each X)
    
    public init(_ xml: (repeat each X)) {
        self.xml = xml
    }
        
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        var allChanges = [XMLChange]()
        for child in repeat (each xml) {
            allChanges.append(contentsOf: child.changes(for: parentID))
        }
        return allChanges
    }
    
    public var body: Never { fatalError() }
}
