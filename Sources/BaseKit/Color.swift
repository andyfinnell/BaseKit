import Foundation

public enum ColorError: Error {
    case invalidHexidecimalFormat
}

public struct Color: Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init(hex: String) throws {
        let (redString, greenString, blueString, alphaString) = try Color.components(hex: hex)
        self.red = try Color.parse(component: redString)
        self.green = try Color.parse(component: greenString)
        self.blue = try Color.parse(component: blueString)
        self.alpha = try Color.parse(component: alphaString)
    }
}

private extension Color {
    static func components(hex: String) throws -> (String, String, String, String) {
        var str = hex.lowercased()
        if str.hasPrefix("#") {
            str = String(str[str.index(str.startIndex, offsetBy: 1)...])
        }
        let red: String
        let green: String
        let blue: String
        let alpha: String
        switch str.count {
        case 6: // rgb
            red = String(str[str.startIndex...str.index(str.startIndex, offsetBy: 1)])
            green = String(str[str.index(str.startIndex, offsetBy: 2)...str.index(str.startIndex, offsetBy: 3)])
            blue = String(str[str.index(str.startIndex, offsetBy: 4)...str.index(str.startIndex, offsetBy: 5)])
            alpha = "ff"
        case 8: // rgba
            red = String(str[str.startIndex...str.index(str.startIndex, offsetBy: 1)])
            green = String(str[str.index(str.startIndex, offsetBy: 2)...str.index(str.startIndex, offsetBy: 3)])
            blue = String(str[str.index(str.startIndex, offsetBy: 4)...str.index(str.startIndex, offsetBy: 5)])
            alpha = String(str[str.index(str.startIndex, offsetBy: 6)...str.index(str.startIndex, offsetBy: 7)])
        default:
            throw ColorError.invalidHexidecimalFormat
        }
        
        return (red, green, blue, alpha)
    }
    
    static func parse(component hex: String) throws -> Double {
        let amount = try hex.reduce(0.0) { sum, ch -> Double in
            let value = Double(try parseInt(hex: ch))
            return (sum * 16.0) + value
        }
        return amount / 255.0
    }
    
    static func parseInt(hex: Character) throws -> Int {
        guard let ch = hex.unicodeScalars.first,
            let zero = "0".unicodeScalars.first,
            let nine = "9".unicodeScalars.first,
            let a = "a".unicodeScalars.first,
            let f = "f".unicodeScalars.first else {
            throw ColorError.invalidHexidecimalFormat
        }
        if ch >= a && ch <= f {
            return Int(ch.value - a.value) + 10
        } else if ch >= zero && ch <= nine {
            return Int(ch.value - zero.value)
        } else {
            throw ColorError.invalidHexidecimalFormat
        }
    }
}
