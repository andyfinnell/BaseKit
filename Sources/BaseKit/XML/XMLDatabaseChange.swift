
public struct XMLDatabaseChange: Hashable, Sendable, Identifiable {
    public let id: XMLDatabaseChangeSubjectID
    public let kind: XMLDatabaseChangeSubjectKind
    public let action: XMLDatabaseChangeAction
    
    public init(id: XMLDatabaseChangeSubjectID, kind: XMLDatabaseChangeSubjectKind, action: XMLDatabaseChangeAction) {
        self.id = id
        self.kind = kind
        self.action = action
    }
    
    public static func create(_ id: XMLID, _ kind: XMLDatabaseChangeSubjectKind) -> XMLDatabaseChange {
        XMLDatabaseChange(id: .value(id), kind: kind, action: .create)
    }
    
    public static func update(_ id: XMLID, _ kind: XMLDatabaseChangeSubjectKind) -> XMLDatabaseChange {
        XMLDatabaseChange(id: .value(id), kind: kind, action: .update)
    }
    
    public static func destroy(_ id: XMLID, _ kind: XMLDatabaseChangeSubjectKind) -> XMLDatabaseChange {
        XMLDatabaseChange(id: .value(id), kind: kind, action: .destroy)
    }
    
    public static let updateRoot = XMLDatabaseChange(id: .root, kind: .root, action: .update)
}

public enum XMLDatabaseChangeSubjectID: Hashable, Sendable {
    case root
    case value(XMLID)
}

public enum XMLDatabaseChangeAction: Hashable, Sendable {
    case create
    case update
    case destroy
}

public enum XMLDatabaseChangeSubjectKind: Hashable, Sendable {
    case root
    case element(String)
    case text
    case cdata
    case comment
    case ignorableWhitespace
}
