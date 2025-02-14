import Foundation

public extension Rect {
    var topLeft: Point { Point(x: minX, y: minY) }
    var top: Point { Point(x: midX, y: minY) }
    var topRight: Point { Point(x: maxX, y: minY) }
    var middleLeft: Point { Point(x: minX, y: midY) }
    var middle: Point { Point(x: midX, y: midY) }
    var middleRight: Point { Point(x: maxX, y: midY) }
    var bottomLeft: Point { Point(x: minX, y: maxY) }
    var bottom: Point { Point(x: midX, y: maxY) }
    var bottomRight: Point { Point(x: maxX, y: maxY) }

    func anchor(for anchorPoint: AnchorPoint) -> Point {
        switch anchorPoint {
        case .topLeft: topLeft
        case .topCenter: top
        case .topRight: topRight
        case .centerLeft: middleLeft
        case .center: middle
        case .centerRight: middleRight
        case .bottomLeft: bottomLeft
        case .bottomCenter: bottom
        case .bottomRight: bottomRight
        }
    }
    
    func mightOverlap(_ bounds2: Rect, threshold: Real) -> Bool {
        let left = max(minX, bounds2.minX)
        let right = min(maxX, bounds2.maxX)
        
        if left.isGreaterThan(right, threshold: threshold) {
            return false    // no horizontal overlap
        }
        
        let top = max(minY, bounds2.minY)
        let bottom = min(maxY, bounds2.maxY)
        return top.isLessThanEqual(bottom, threshold: threshold)
    }

}
