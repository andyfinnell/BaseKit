public protocol XMLUpdateImpl {
    func changes(for parentID: XMLID?) -> [XMLChange]
}

public protocol XMLUpdate: XMLUpdateImpl {
    associatedtype Body: XMLUpdate
    
    @XMLUpdateBuilder
    var body: Body { get }
}

public extension XMLUpdate {
    func changes(for parentID: XMLID?) -> [XMLChange] {
        body.changes(for: parentID)
    }
}

extension Never: XMLUpdate {
    public func changes(for parentID: XMLID?) -> [XMLChange] { [] }
    
}
