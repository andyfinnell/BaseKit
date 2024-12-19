@resultBuilder
public struct XMLUpdateBuilder {
    public static func buildBlock() -> EmptyXMLUpdate {
        EmptyXMLUpdate()
    }
    
    public static func buildBlock<X: XMLUpdate>(_ component: X) -> X {
        component
    }

    public static func buildBlock<each X: XMLUpdate>(_ components: repeat each X) -> TupleXMLUpdate<repeat each X> {
        TupleXMLUpdate((repeat each components))
    }

    public static func buildOptional<X: XMLUpdate>(_ component: X?) -> ConditionalXMLUpdate<X, EmptyXMLUpdate> {
        if let component {
            ConditionalXMLUpdate(.true(component))
        } else {
            ConditionalXMLUpdate(.false(EmptyXMLUpdate()))
        }
    }
    
    public static func buildEither<X0: XMLUpdate, X1: XMLUpdate>(first component: X0) -> ConditionalXMLUpdate<X0, X1> {
        ConditionalXMLUpdate(.true(component))
    }
    
    public static func buildEither<X0: XMLUpdate, X1: XMLUpdate>(second component: X1) -> ConditionalXMLUpdate<X0, X1> {
        ConditionalXMLUpdate(.false(component))
    }

    public static func buildArray<X: XMLUpdate>(_ components: [X]) -> ArrayXMLUpdate<X> {
        ArrayXMLUpdate(components)
    }
}
