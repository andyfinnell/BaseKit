
public enum XMLDatabaseChange: Hashable {
    case root
    case value(XMLID)
}

public protocol XMLDatabaseDelegate: AnyObject {
    func onChanges(_ changes: Set<XMLDatabaseChange>)
}
