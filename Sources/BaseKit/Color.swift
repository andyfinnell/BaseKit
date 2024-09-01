import Foundation

public enum ColorError: Error {
    case invalidHexidecimalFormat
}

public struct Color: Hashable, Codable, Sendable {
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

public extension Color {
    static let black = Color(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = Color(red: 1, green: 1, blue: 1, alpha: 1)
    static let red = Color(red: 1, green: 0, blue: 0, alpha: 1)
    static let green = Color(red: 0, green: 1, blue: 0, alpha: 1)
    static let blue = Color(red: 0, green: 0, blue: 1, alpha: 1)
    static let purple = Color(red: 1, green: 0, blue: 1, alpha: 1)
    static let yellow = Color(red: 1, green: 1, blue: 0, alpha: 1)
    static let orange = Color(red: 1, green: 0.5, blue: 0, alpha: 1)
    static let transparentBlack = Color(red: 0, green: 0.0, blue: 0.0, alpha: 0.0)
    static let clear = Color(red: 0, green: 0.0, blue: 0.0, alpha: 0.0)
    
    static let pasteboard = Color(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
}

public extension Color {
    /// Print in RGB
    var hexadecimal: String {
        "\(componentHex(red))\(componentHex(green))\(componentHex(blue))"
    }
    
    var rgbString: String {
        "#\(componentHex(red))\(componentHex(green))\(componentHex(blue))"
    }
}

public extension Color {
    /// Only considers non-alpha (red, green, blue)
    func distance(to color: Color) -> Double {
        let red = self.red - color.red
        let green = self.green - color.green
        let blue = self.blue - color.blue
        return sqrt(red * red + green * green + blue * blue)
    }
    
    func linearInterpolate(at parameter: Double, to nextColor: Color) -> Color {
        Color(
            red: BaseKit.linearInterpolate(start: red, end: nextColor.red, time: parameter),
            green: BaseKit.linearInterpolate(start: green, end: nextColor.green, time: parameter),
            blue: BaseKit.linearInterpolate(start: blue, end: nextColor.blue, time: parameter),
            alpha: BaseKit.linearInterpolate(start: alpha, end: nextColor.alpha, time: parameter)
        )
    }
}

private extension Color {
    func componentHex(_ value: Double) -> String {
        let asInt = Int(value * 255.0)
        let asString = String(asInt, radix: 16, uppercase: true)
        if asString.count < 2 {
            return "0\(asString)"
        } else {
            return asString
        }
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
