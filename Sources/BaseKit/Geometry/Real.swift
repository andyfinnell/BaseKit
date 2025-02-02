import Foundation

/// A cross platform type that's the same size
public typealias Real = Double

extension Real {
    var sign: Int {
        self < 0.0 ? -1 : 1
    }
    
    func isClose(to value2: Double, threshold: Double) -> Bool {
        let delta = self - value2
        return (delta <= threshold) && (delta >= -threshold)
    }
    
    func isGreaterThan(_ minimum: Double, threshold: Double) -> Bool {
        if isClose(to: minimum, threshold: threshold) {
            return false
        }
        
        return self > minimum
    }
    
    func isGreaterThanEqual(_ minimum: Double, threshold: Double) -> Bool {
        if isClose(to: minimum, threshold: threshold) {
            return true
        }
        
        return self >= minimum
    }

    func isLessThan(_ maximum: Double, threshold: Double) -> Bool {
        if isClose(to: maximum, threshold: threshold) {
            return false
        }
        
        return self < maximum
    }
    
    func isLessThanEqual(_ maximum: Double, threshold: Double) -> Bool {
        if isClose(to: maximum, threshold: threshold) {
            return true
        }
        
        return self <= maximum
    }
}
