
public func clamp<T: Comparable>(_ value: T, _ low: T, _ high: T) -> T {
    if value > high {
        return high
    } else if value < low {
        return low
    } else {
        return value
    }
}
