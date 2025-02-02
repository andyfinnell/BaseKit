import Foundation

public extension Rect {
    var topLeft: Point {
        Point(x: minX, y: minY)
    }

    var topRight: Point {
         Point(x: maxX, y: minY)
    }

    var bottomLeft: Point {
        Point(x: minX, y: maxY)
    }

    var bottomRight: Point {
         Point(x: maxX, y: maxY)
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
