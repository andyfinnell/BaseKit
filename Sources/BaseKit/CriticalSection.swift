import Foundation

public final class CriticalSection {
    public init() {
        pthread_mutex_init(&lock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&lock)
    }
        
    public final func critical<T>(_ work: () throws -> T) rethrows -> T {
        pthread_mutex_lock(&lock)
        defer {
            pthread_mutex_unlock(&lock)
        }
        
        return try work()
    }
    
    private var lock = pthread_mutex_t()
}
