/// This is like optional, but with a specific purpose of specifying an override
/// value. The point of having a separate type is to make it clear when the
/// underlying type is actually an optional, and making the given value intent
/// clearer.
public enum Override<T> {
    case useExisting
    case overrideWith(T)
    
    public func compute(withExisting existingValue: T) -> T {
        switch self {
        case .useExisting: existingValue
        case let .overrideWith(value): value
        }
    }
}

