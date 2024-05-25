import Foundation

public extension Sequence {
    var pairs: AnySequence<(Element, Element)> {
        AnySequence {
            var iterator = self.makeIterator()
            var currentValue = iterator.next()
            var nextValue = iterator.next()
            
            return AnyIterator { () -> (Element, Element)? in
                guard let current = currentValue, let next = nextValue else {
                    return nil
                }
                let pair = (current, next)
                currentValue = nextValue
                nextValue = iterator.next()
                return pair
            }
        }
    }
}
