import Foundation

public protocol URLHandlerType {
    func handle(match: URLMatch) -> Bool
}

struct URLHandler: URLHandlerType {
    private let block: (URLMatch) -> Bool
    
    init(block: @escaping (URLMatch) -> Bool) {
        self.block = block
    }
    
    func handle(match: URLMatch) -> Bool {
        return block(match)
    }
}
