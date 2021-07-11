import Foundation
import Combine

public extension Publisher {
    func eraseToFuture(fallback: Result<Output, Failure>) -> Future<Output, Failure> {
        Future { promise in
            var cancellable: AnyCancellable?
            cancellable = sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    promise(.failure(error))
                case .finished:
                    // shouldn't have gotten here
                    promise(fallback)
                }
                cancellable?.cancel()
                cancellable = nil
            }, receiveValue: { output in
                promise(.success(output))
                cancellable?.cancel()
                cancellable = nil
            })
        }
    }
    
    func eraseToFuture(fallback: Output) -> Future<Output, Failure> {
        eraseToFuture(fallback: .success(fallback))
    }
    
    func eraseToFuture(fallback: Failure) -> Future<Output, Failure> {
        eraseToFuture(fallback: .failure(fallback))
    }
}

public extension Future {
    static func value(_ value: Output) -> Future<Output, Failure> {
        Future { promise in
            promise(.success(value))
        }
    }
    
    static func error(_ error: Failure) -> Future<Output, Failure> {
        Future { promise in
            promise(.failure(error))
        }
    }
}

public extension Sequence {
    func reduce<Sum, Failure: Error>(_ initialValue: Sum, reducer: @escaping (Sum, Element) -> Future<Sum, Failure>) -> Future<Sum, Failure> {
        Future { promise in
            var cancellable: AnyCancellable?
            var finalValue = initialValue
            cancellable = self.reduce(Just(initialValue).setFailureType(to: Failure.self).eraseToAnyPublisher()) { partialResult, value in
                return partialResult.flatMap { previous in
                    reducer(previous, value)
                }.eraseToAnyPublisher()
            }.sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    promise(.success(finalValue))
                case let .failure(error):
                    promise(.failure(error))
                }
                cancellable?.cancel()
                cancellable = nil
            }, receiveValue: { sum in
                finalValue = sum
            })
        }

    }
}
