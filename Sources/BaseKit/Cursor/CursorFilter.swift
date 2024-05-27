import Foundation

public protocol CursorFilter {
    associatedtype Element: Equatable
    
    func isIncluded(_ element: Element) -> Bool
}

public struct AnyCursorFilter<Element: Equatable>: CursorFilter {
    private let isIncludedThunk: (Element) -> Bool
    
    public init<F: CursorFilter>(_ filter: F) where F.Element == Element {
        self.isIncludedThunk = { filter.isIncluded($0) }
    }
    
    public func isIncluded(_ element: Element) -> Bool {
        return isIncludedThunk(element)
    }
}
