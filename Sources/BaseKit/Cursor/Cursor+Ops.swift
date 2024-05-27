import Foundation

public func ==<S: CursorSource>(lhs: Cursor<S>, rhs: S.Element) -> Bool {
    guard let v = lhs.element else {
        return false
    }
    return v == rhs
}

public func !=<S: CursorSource>(lhs: Cursor<S>, rhs: S.Element) -> Bool {
    guard let v = lhs.element else {
        return true
    }
    return v != rhs
}

public func ~=<S: CursorSource>(lhs: S.Element, rhs: Cursor<S>) -> Bool {
    guard let v = rhs.element else {
        return false
    }
    return v == lhs
}
