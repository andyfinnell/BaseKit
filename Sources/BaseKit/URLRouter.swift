import Foundation

public protocol URLRouterType {
    func on(_ pattern: URLMatcher.Pattern..., handler: URLHandlerType)
    func on(_ pattern: URLMatcher.Pattern..., block: @escaping (URLMatch) -> Bool)
    func handle(url: URL) -> Bool
}

public final class URLRouter: URLRouterType {
    private var entries = [Entry]()
    
    public init() {
    }
    
    public func on(_ pattern: URLMatcher.Pattern..., handler: URLHandlerType) {
        install(pattern: pattern, for: handler)
    }
    
    public func on(_ pattern: URLMatcher.Pattern..., block: @escaping (URLMatch) -> Bool) {
        install(pattern: pattern, for: URLHandler(block: block))
    }
    
    public func handle(url: URL) -> Bool {
        guard let (entry, match) = firstMatchingEntry(url: url) else {
            return false
        }
        
        return entry.handler.handle(match: match)
    }
}

private extension URLRouter {
    struct Entry {
        let matcher: URLMatcher
        let handler: URLHandlerType
    }
    
    func install(pattern: [URLMatcher.Pattern], for handler: URLHandlerType) {
        let entry = Entry(matcher: URLMatcher(patterns: pattern), handler: handler)
        entries.append(entry)
    }

    func firstMatchingEntry(url: URL) -> (Entry, URLMatch)? {
        for entry in entries {
            if let match = entry.matcher.match(url: url) {
                return (entry, match)
            }
        }
        return nil
    }
}
