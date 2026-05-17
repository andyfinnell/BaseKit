public struct UpdateAttr<V: XMLFormattable & Equatable & Sendable>: XMLUpdate {
    private let name: XMLAttribute
    private let operation: Operation

    public init(_ name: XMLAttribute, _ value: V, `default` defaultValue: V) {
        self.name = name
        self.operation = value == defaultValue ? .delete : .set(value)
    }

    public init(_ name: XMLAttribute, _ value: V?) {
        self.name = name
        self.operation = value.map { .set($0) } ?? .delete
    }

    /// Sets `value` unconditionally when `optionalDefault` is nil; when
    /// `optionalDefault` is non-nil, behaves like the non-Optional
    /// `default:` init (suppresses writes that match the default).
    ///
    /// Use this when the dedupe target may legitimately be absent — for
    /// example, when reading a chain-aware effective default that returns
    /// nil for an unchained leaf with no spec fallback.
    public init(_ name: XMLAttribute, _ value: V, `default` optionalDefault: V?) {
        self.name = name
        if let optionalDefault {
            self.operation = value == optionalDefault ? .delete : .set(value)
        } else {
            self.operation = .set(value)
        }
    }

    public var body: some XMLUpdate {
        switch operation {
        case .delete:
            DeleteAttr(name)
        case let .set(value):
            SetAttr(name, value)
        }
    }
}

private extension UpdateAttr {
    enum Operation {
        case delete
        case set(V)
    }
}
