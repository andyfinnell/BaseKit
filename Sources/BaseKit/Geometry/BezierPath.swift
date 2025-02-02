
public struct BezierPath: Hashable, BezierPathRepresentable, Codable, Sendable {
    public var isEmpty: Bool { elements.isEmpty }
    
    public func enumerate(_ block: (Element) -> Void) {
        for element in elements {
            block(element)
        }
    }
    
    private static let circleCoefficient = 0.55228475
    
    public enum Element: Hashable, Codable, Sendable {
        case move(to: Point)
        case line(to: Point)
        case curve(to: Point, control1: Point, control2: Point)
        case closeSubpath
    }
    
    public private(set) var elements: [Element]
    
    public init() {
        elements = []
    }
    
    public init(elements: [Element]) {
        self.elements = elements
    }
    
    public init<B: BezierPathRepresentable>(_ representable: B) {
        elements = []
        representable.enumerate { element in
            elements.append(element)
        }
    }
    
    public init(rect: Rect) {
        elements = [
            .move(to: .init(x: rect.minX, y: rect.minY)),
            .line(to: .init(x: rect.maxX, y: rect.minY)),
            .line(to: .init(x: rect.maxX, y: rect.maxY)),
            .line(to: .init(x: rect.minX, y: rect.maxY)),
            .closeSubpath
        ]
    }
    
    public init(ellipseIn rect: Rect) {
        let xControlOffset = Self.circleCoefficient * (rect.width / 2.0)
        let yControlOffset = Self.circleCoefficient * (rect.height / 2.0)
        elements = [
            .move(to: .init(x: rect.maxX, y: rect.midY)),
            .curve(to: .init(x: rect.midX, y: rect.maxY),
                   control1: .init(x: rect.maxX, y: rect.midY + yControlOffset),
                   control2: .init(x: rect.midX + xControlOffset, y: rect.maxY)),
            .curve(to: .init(x: rect.minX, y: rect.midY),
                   control1: .init(x: rect.midX - xControlOffset, y: rect.maxY),
                   control2: .init(x: rect.minX, y: rect.midY + yControlOffset)),
            .curve(to: .init(x: rect.midX, y: rect.minY),
                   control1: .init(x: rect.minX, y: rect.midY - yControlOffset),
                   control2: .init(x: rect.midX - xControlOffset, y: rect.minY)),
            .curve(to: .init(x: rect.maxX, y: rect.midY),
                   control1: .init(x: rect.midX + xControlOffset, y: rect.minY),
                   control2: .init(x: rect.maxX, y: rect.midY - yControlOffset)),
            .closeSubpath
        ]
    }
    
    public init(roundedRect rect: Rect, cornerRadius: Real) {
        self.init(roundedRect: rect, cornerSize: .init(width: cornerRadius, height: cornerRadius))
    }
    
    public init(roundedRect rect: Rect, cornerSize: Size) {
        let controlOffset = cornerSize * Self.circleCoefficient
        let flatSideLength = (rect.size - (cornerSize * 2.0)) / 2.0
        
        elements = [
            .move(to: .init(x: rect.maxX, y: rect.midY)),
            .line(to: .init(x: rect.maxX, y: rect.midY + flatSideLength.height)),
            .curve(to: .init(x: rect.maxX - cornerSize.width, y: rect.maxY),
                   control1: .init(x: rect.maxX, y: rect.midY + flatSideLength.height + controlOffset.height),
                   control2: .init(x: rect.maxX - cornerSize.width + controlOffset.width, y: rect.maxY )),
            .line(to: .init(x: rect.minX + cornerSize.width, y: rect.maxY)),
            .curve(to: .init(x: rect.minX, y: rect.midY + flatSideLength.height),
                   control1: .init(x: rect.minX + cornerSize.width - controlOffset.width, y: rect.maxY),
                   control2: .init(x: rect.minX, y: rect.midY + flatSideLength.height + controlOffset.height)),
            .line(to: .init(x: rect.minX, y: rect.midY - flatSideLength.height)),
            .curve(to: .init(x: rect.minX + cornerSize.width, y: rect.minY),
                   control1: .init(x: rect.minX, y: rect.midY - flatSideLength.height - controlOffset.height),
                   control2: .init(x: rect.minX + cornerSize.width - controlOffset.width, y: rect.minY)),
            .line(to: .init(x: rect.maxX - cornerSize.width, y: rect.minY)),
            .curve(to: .init(x: rect.maxX, y: rect.midY - flatSideLength.height),
                   control1: .init(x: rect.maxX - cornerSize.width + controlOffset.width, y: rect.minY),
                   control2: .init(x: rect.maxX, y: rect.midY - flatSideLength.height - controlOffset.height)),
            .closeSubpath
        ]
    }
    
    
    public init(end1: Point, control1: Point, control2: Point, end2: Point) {
        elements = [
            .move(to: end1),
            .curve(to: end2, control1: control1, control2: control2)
        ]
    }

    public init(_ builder: (inout BezierPath) -> Void) {
        var empty = BezierPath()
        builder(&empty)
        self.elements = empty.elements
    }
    
    public mutating func move(to point: Point) {
        elements.append(.move(to: point))
    }
    
    public mutating func addCurve(to point: Point, controlPoint1: Point, controlPoint2: Point) {
        elements.append(.curve(to: point, control1: controlPoint1, control2: controlPoint2))
    }
    
    public mutating func addLine(to point: Point) {
        elements.append(.line(to: point))
    }
    
    public mutating func closeSubpath() {
        elements.append(.closeSubpath)
    }
    
    public mutating func append<B: BezierPathRepresentable>(contentsOf bezier: B) {
        bezier.enumerate { element in
            elements.append(element)
        }
    }
        
    public var count: Int {
        elements.count
    }
    
    public mutating func transform(_ transform: BaseKit.Transform) {
        elements = elements.map { $0.transform(transform) }
    }
    
    public func reversed() -> BezierPath {
        var subpaths = [[BezierPath.Element]]()
        var currentSubpath = [BezierPath.Element]()
        for element in elements {
            switch element {
            case .move:
                if !currentSubpath.isEmpty {
                    subpaths.append(currentSubpath)
                    currentSubpath = []
                }
                currentSubpath.append(element)
            case .line, .curve:
                currentSubpath.append(element)
            case .closeSubpath:
                currentSubpath.append(element)
                subpaths.append(currentSubpath)
                currentSubpath = []
            }
        }
        
        if !currentSubpath.isEmpty {
            subpaths.append(currentSubpath)
            currentSubpath = []
        }

        var result = BezierPath()
        for subpath in subpaths {
            result.appendReverse(subpath)
        }
        return result
    }
    
    public static let easeInEaseOut = BezierPath(end1: .init(x: 0, y: 0),
                                      control1: .init(x: 0.2, y: 0),
                                      control2: .init(x: 0.8, y: 1),
                                      end2: .init(x: 1, y: 1))

}

extension BezierPath.Element {
    func transform(_ transform: BaseKit.Transform) -> BezierPath.Element {
        switch self {
        case let .move(to: point):
            return .move(to: point.applying(transform))
        case let .line(to: point):
            return .line(to: point.applying(transform))
        case let .curve(to: point, control1: controlPoint1, control2: controlPoint2):
            return .curve(to: point.applying(transform),
                          control1: controlPoint1.applying(transform),
                          control2: controlPoint2.applying(transform))
        case .closeSubpath:
            return .closeSubpath
        }
    }
}

public extension BezierPath.Element {
    var endPoint: Point? {
        switch self {
        case let .move(to: point):
            return point
        case let .line(to: point):
            return point
        case let .curve(to: point, control1: _, control2: _):
            return point
        case .closeSubpath:
            return nil
        }
    }
    
    var controlPoint1: Point? {
        if case let .curve(to: _, control1: control1, control2: _) = self {
            return control1
        } else {
            return nil
        }
    }

    var controlPoint2: Point? {
        if case let .curve(to: _, control1: _, control2: control2) = self {
            return control2
        } else {
            return nil
        }
    }
}

extension BezierPath: Swift.Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        var i = elements.startIndex
        return AnyIterator { () -> Element? in
            guard i >= elements.startIndex && i < elements.endIndex else {
                return nil
            }
            let value = elements[i]
            i += 1
            return value
        }
    }
}

func convertQuadToCubic(from currentPoint: Point, controlPoint: Point, to endPoint: Point) -> (controlPoint1: Point, controlPoint2: Point, endPoint: Point) {
    // Create a cubic curve representation of the quadratic curve from
    let ⅔: Real = 2.0 / 3.0
    
    // lastPoint + twoThirds * (via - lastPoint)
    let controlPoint1 = currentPoint + ((controlPoint - currentPoint) * ⅔)
    // toPt + twoThirds * (via - toPt)
    let controlPoint2 = endPoint + ((controlPoint - endPoint) * ⅔)
    
    return (controlPoint1: controlPoint1, controlPoint2: controlPoint2, endPoint: endPoint)
}

private extension BezierPath {
    
    mutating func appendReverse(_ subpath: [BezierPath.Element]) {
        let isClosed = subpath.last == .closeSubpath
        
        let reversedElements = (isClosed ? subpath.dropLast() : subpath).reversed()
        var previousElement: BezierPath.Element?
        for element in reversedElements {
            guard let elementToProcess = previousElement else {
                if let endPoint = element.endPoint {
                    move(to: endPoint)
                }
                previousElement = element
                continue
            }
            switch elementToProcess {
            case .move:
                break // TODO: can we get here?
                
            case .line:
                if let endPoint = element.endPoint {
                    addLine(to: endPoint)
                }
                
            case let .curve(to: _, control1: control1, control2: control2):
                if let endPoint = element.endPoint {
                    addCurve(to: endPoint, controlPoint1: control2, controlPoint2: control1)
                }
                
            case .closeSubpath:
                break // Shouldn't get here
            }
            
            previousElement = element
        }
        
        if isClosed {
            closeSubpath()
        }
    }
}
