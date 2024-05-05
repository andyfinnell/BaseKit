import Foundation

public extension Dictionary {
    func removing(_ key: Key) -> Self {
        var copy = self
        copy.removeValue(forKey: key)
        return copy
    }
    
    func removing<S: Sequence>(_ keys: S) -> Self where S.Element == Key {
        var copy = self
        for key in keys {
            copy.removeValue(forKey: key)
        }
        return copy
    }
    
    func adding(_ value: Value, for key: Key) -> Self {
        var copy = self
        copy[key] = value
        return copy
    }
}
