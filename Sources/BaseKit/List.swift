import Foundation

public indirect enum List<T> {
    case element(data: T, next: List<T>)
    case unit
}

public extension List {
    init() {
        self = .unit
    }

    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == T {
        var list = List<T>()
        for element in sequence.reversed() {
            list = list.push(element)
        }
        self = list
    }
    
    func pop() -> List<T> {
        switch self {
        case let .element(data: _, next: next):
          return next
        case .unit:
          return self
        }
    }

    func push(_ data: T) -> List<T> {
        return .element(data: data, next: self)
    }

    func head() -> T? {
        switch self {
        case let .element(data: data, next: _):
          return data
        case .unit:
          return nil
        }
    }
    
    var count: Int {
        return reduce(0) { (sum, _) -> Int in
            return sum + 1
        }
    }
        
    var last: T? {
        return reduce(head()) { (_, last) -> T? in
            return last
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .element(data: _, next: _):
            return false
        case .unit:
            return true
        }
    }
    
    func updateHead(_ map: @escaping (T) throws -> T) rethrows -> List<T> {
        switch self {
        case let .element(data: data, next: next):
            return try .element(data: map(data), next: next)
        case .unit:
            return self
        }
    }
}

extension List: Sequence {
    public typealias Iterator = AnyIterator<T>

    public func makeIterator() -> Iterator {
        var list = self
        return AnyIterator<T> {
            let head = list.head()
            list = list.pop()
            return head
        }
    }
}

extension List: ExpressibleByArrayLiteral {
    public init(arrayLiteral: T...) {
        var list = List<T>()
        for element in arrayLiteral.reversed() {
            list = list.push(element)
        }
        self = list
    }
}

extension List: CustomStringConvertible {
    public var description: String {
        return self.reduce("[") { output, element -> String in
            return output + String(describing: element) + ";"
        } + "]"
    }
}

extension List: Equatable where T: Equatable {
    public static func == (lhs: List<T>, rhs: List<T>) -> Bool {
        switch (lhs, rhs) {
        case let (.element(data: lhsData, next: lhsNext), .element(data: rhsData, next: rhsNext)):
            return lhsData == rhsData && lhsNext == rhsNext
        case (.unit, .unit):
            return true
        default:
            return false
        }
    }
}
