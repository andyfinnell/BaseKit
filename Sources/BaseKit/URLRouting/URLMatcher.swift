import Foundation

public struct URLMatch {
    public let url: URL
    public let matches: [String: String]
}

public struct URLMatcher {
    public enum Pattern: Equatable {
        case exact(String)
        case regex(NSRegularExpression, name: String)
        case segment(name: String)
    }
    
    private let patterns: [Pattern]
    
    init(patterns: [Pattern]) {
        self.patterns = patterns
    }
    
    func match(url: URL) -> URLMatch? {
        let initialState = MatchingState(remaining: url.absoluteString, matches: [String: String]())
        let state = patterns.reduce(initialState) { intermediateState, pattern -> MatchingState? in
            guard let state = intermediateState else { return nil }
            return pattern.match(state: state)
        }
        
        guard let finalState = state else {
            return nil
        }
        
        return URLMatch(url: url, matches: finalState.matches)
    }
}

private struct MatchingState {
    let remaining: String
    let matches: [String: String]
}

private extension URLMatcher.Pattern {
    func match(state: MatchingState) -> MatchingState? {
        switch self {
        case let .exact(str):
            if state.remaining.hasPrefix(str) {
                let newRemaining = String(state.remaining.suffix(state.remaining.count - str.count))
                return MatchingState(remaining: newRemaining, matches: state.matches)
            } else {
                return nil
            }
            
        case let .regex(regex, name: name):
            return match(regex: regex, name: name, state: state)
            
        case let .segment(name: name):
            let regex = try! NSRegularExpression(pattern: "[^/]+", options: [])
            return match(regex: regex, name: name, state: state)
        }
    }
    
    func match(regex: NSRegularExpression, name: String, state: MatchingState) -> MatchingState? {
        if let match = regex.firstMatch(in: state.remaining, options: .anchored, range: NSRange(location: 0, length: state.remaining.count)) {
            var newMatches = state.matches
            newMatches[name] = String(state.remaining.prefix(match.range.length))
            let newRemaining = String(state.remaining.suffix(state.remaining.count - match.range.length))
            return MatchingState(remaining: newRemaining, matches: newMatches)
        } else {
            return nil
        }
    }
}
