
public enum XMLPathKind {
    case element(XMLName)
    case text
    case whitespace
    case cdata
    case comment
}

public struct XMLPathSegment {
    public let kind: XMLPathKind
    public let index: Int
    
    public init(kind: XMLPathKind, index: Int) {
        self.kind = kind
        self.index = index
    }
}

public struct XMLPath {
    public let segments: [XMLPathSegment]
    
    public init(segments: [XMLPathSegment]) {
        self.segments = segments
    }
        
    public static func element(_ name: XMLName, at index: Int = 0) -> XMLPath {
        root(kind: .element(name), index: index)
    }
    
    public func element(_ name: XMLName, at index: Int = 0) -> XMLPath {
        appending(kind: .element(name), index: index)
    }

    public static func text(at index: Int = 0) -> XMLPath {
        root(kind: .text, index: index)
    }

    public func text(at index: Int = 0) -> XMLPath {
        appending(kind: .text, index: index)
    }

    public static func whitespace(at index: Int = 0) -> XMLPath {
        root(kind: .whitespace, index: index)
    }

    public func whitespace(at index: Int = 0) -> XMLPath {
        appending(kind: .whitespace, index: index)
    }
    
    public static func cdata(at index: Int = 0) -> XMLPath {
        root(kind: .cdata, index: index)
    }

    public func cdata(at index: Int = 0) -> XMLPath {
        appending(kind: .cdata, index: index)
    }

    public static func comment(at index: Int = 0) -> XMLPath {
        root(kind: .comment, index: index)
    }

    public func comment(at index: Int = 0) -> XMLPath {
        appending(kind: .comment, index: index)
    }
}

private extension XMLPath {
    static func root(kind: XMLPathKind, index: Int) -> XMLPath {
        XMLPath(segments: [XMLPathSegment(kind: kind, index: index)])
    }
    
    func appending(kind: XMLPathKind, index: Int) -> XMLPath {
        XMLPath(segments: segments + [XMLPathSegment(kind: kind, index: index)])
    }
}
