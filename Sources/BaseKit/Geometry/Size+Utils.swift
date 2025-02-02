import Foundation

public func *(lhs: Size, rhs: Real) -> Size {
    .init(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func /(lhs: Size, rhs: Real) -> Size {
    .init(width: lhs.width / rhs, height: lhs.height / rhs)
}

public func -(lhs: Size, rhs: Size) -> Size {
    .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}
