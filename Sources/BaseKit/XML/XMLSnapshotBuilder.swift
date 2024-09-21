
@resultBuilder
public struct XMLSnapshotBuilder {
    public static func buildBlock<each X: XML>(_ components: repeat each X) -> TupleXML<repeat each X> {
        TupleXML((repeat each components))
    }
    
    public static func buildOptional<X: XML>(_ component: X?) -> ConditionalXML<X, EmptyXML> {
        if let component {
            ConditionalXML(.true(component))
        } else {
            ConditionalXML(.false(EmptyXML()))
        }
    }
    
    public static func buildEither<X0: XML, X1: XML>(first component: X0) -> ConditionalXML<X0, X1> {
        ConditionalXML(.true(component))
    }
    
    public static func buildEither<X0: XML, X1: XML>(second component: X1) -> ConditionalXML<X0, X1> {
        ConditionalXML(.false(component))
    }
    
    public static func buildArray<X: XML>(_ components: [X]) -> ArrayXML<X> {
        ArrayXML(components)
    }
}
