
public struct AnyError: Error {
    public let underlyingError: Error
    private let isEqual: (Error, Error) -> Bool
    
    public init<Failure>(_ error: Failure) where Failure: Error, Failure: Equatable {
        self.underlyingError = error
        self.isEqual = { lhs, rhs in
            guard let l = lhs as? Failure, let r = rhs as? Failure else {
                return false
            }
            return l == r
        }
    }
    
    public init<Failure: Error>(_ error: Failure) {
        self.underlyingError = error
        self.isEqual = { _, _ in false }
    }
}

extension AnyError: Equatable {
    public static func == (lhs: AnyError, rhs: AnyError) -> Bool {
        lhs.isEqual(lhs.underlyingError, rhs.underlyingError)
    }
}
