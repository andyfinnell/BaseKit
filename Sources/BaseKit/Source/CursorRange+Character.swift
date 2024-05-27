import Foundation

public extension CursorRange where S == Source {
    var string: String {
        String(source.substring(from: start.index, upTo: end.index))
    }
}
