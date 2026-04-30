/// Cancels its underlying task on `deinit`. Hold this value to keep receiving elements.
public final class AsyncStreamSubscription: Sendable, Hashable {
    private let task: Task<Void, Never>

    fileprivate init(task: Task<Void, Never>) {
        self.task = task
    }

    public func cancel() {
        task.cancel()
    }

    public func store(in collection: inout Set<AsyncStreamSubscription>) {
        collection.insert(self)
    }

    public func store<Collection: RangeReplaceableCollection>(
        in collection: inout Collection
    ) where Collection.Element == AsyncStreamSubscription {
        collection.append(self)
    }

    public static func == (lhs: AsyncStreamSubscription, rhs: AsyncStreamSubscription) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    deinit {
        task.cancel()
    }
}

public extension AsyncStream where Element: Sendable {
    func sink(_ body: sending @escaping (Element) async -> Void) -> AsyncStreamSubscription {
        let task = Task {
            for await element in self {
                await body(element)
            }
        }
        return AsyncStreamSubscription(task: task)
    }

    func sink(_ body: sending @escaping () async -> Void) -> AsyncStreamSubscription {
        let task = Task {
            for await _ in self {
                await body()
            }
        }
        return AsyncStreamSubscription(task: task)
    }

    func sink<Object: AnyObject & Sendable>(
        _ object: Object,
        _ body: sending @escaping (Object, Element) async -> Void
    ) -> AsyncStreamSubscription {
        let task = Task { [weak object] in
            for await element in self {
                guard let object else { break }
                await body(object, element)
            }
        }
        return AsyncStreamSubscription(task: task)
    }

    func sink<Object: AnyObject & Sendable>(
        _ object: Object,
        _ body: sending @escaping (Object) async -> Void
    ) -> AsyncStreamSubscription {
        let task = Task { [weak object] in
            for await _ in self {
                guard let object else { break }
                await body(object)
            }
        }
        return AsyncStreamSubscription(task: task)
    }

    func sink<Object: AnyObject & Sendable>(
        _ object: Object,
        _ body: sending @escaping (Object) -> () async -> Void
    ) -> AsyncStreamSubscription {
        let task = Task { [weak object] in
            for await _ in self {
                guard let object else { break }
                await body(object)()
            }
        }
        return AsyncStreamSubscription(task: task)
    }
}
