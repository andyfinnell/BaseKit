import Foundation

public extension Cursor where S.Element == Character {
    var isAtStartOfLine: Bool {
        isStart || regress().isNewline
    }
    
    var isNewline: Bool {
        guard let ch = element else {
            return false
        }
        return ch.isNewline
    }

    var notNewline: Bool {
        guard let ch = element else {
            return true
        }
        return !ch.isNewline
    }

    var isWhitespace: Bool {
        guard let ch = element else {
            return false
        }
        return ch.isWhitespace
    }

    var notWhitespace: Bool {
        guard let ch = element else {
            return true
        }
        return !ch.isWhitespace
    }
       
    func not(in set: Set<Character>) -> Bool {
        guard let ch = element else {
            return true
        }
        return !set.contains(ch)
    }
    
    func `in`(_ set: Set<Character>) -> Bool {
        guard let ch = element else {
            return false
        }
        return set.contains(ch)
    }
    
    func scan(into output: inout String) -> Cursor {
        guard let ch = element else {
            return self
        }
        output.append(ch)
        return advance()
    }
    
    func toInt(radix: Int) -> Int? {
        guard let ch = element else {
            return nil
        }
        return ch.toInt(radix: radix)
    }
}


private extension Character {    
    func toInt(radix: Int) -> Int? {
        guard let value = Character.toIntegerValues[self], value < radix else {
            return nil
        }
        return value
    }
    
    static let toIntegerValues = [Character("0"): 0,
                                  Character("1"): 1, Character("2"): 2,
                                  Character("3"): 3, Character("4"): 4,
                                  Character("5"): 5, Character("6"): 6,
                                  Character("7"): 7, Character("8"): 8,
                                  Character("9"): 9, Character("a"): 10,
                                  Character("b"): 11, Character("c"): 12,
                                  Character("d"): 13, Character("e"): 14,
                                  Character("f"): 15, Character("A"): 10,
                                  Character("B"): 11, Character("C"): 12,
                                  Character("D"): 13, Character("E"): 14,
                                  Character("F"): 15
    ]
}

