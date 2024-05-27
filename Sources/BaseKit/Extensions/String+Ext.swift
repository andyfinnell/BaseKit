import Foundation

public extension String {
    func leftPadding(toLength newLength: Int, withPad pad: String) -> String {
        guard count < newLength else {
            return self
        }
        
        let difference = newLength - count
        let fullCount = difference / pad.count
        let remainderCount = difference % pad.count
        let remainder: String
        if let i = pad.index(pad.startIndex, offsetBy: remainderCount, limitedBy: pad.endIndex) {
            remainder = String(pad[..<i])
        } else {
            remainder = ""
        }
        return String(repeating: pad, count: fullCount) + remainder + self
    }
    
    func extendLeft(_ beginningIndex: String.Index, while predicate: (Character) -> Bool) -> String.Index {
        guard beginningIndex < endIndex else { return endIndex }
        
        var lastKnownGoodIndex = beginningIndex
        var index = beginningIndex
        while index >= startIndex && predicate(self[index]) {
            lastKnownGoodIndex = index
            if index == startIndex {
                break
            }
            index = self.index(before: index)
        }
        
        return lastKnownGoodIndex
    }
    
    func extendRight(_ beginningIndex: String.Index, while predicate: (Character) -> Bool) -> String.Index {
        guard beginningIndex < endIndex else { return endIndex }

        var lastKnownGoodIndex = beginningIndex
        var index = beginningIndex
        while index < endIndex && predicate(self[index]) {
            lastKnownGoodIndex = index
            index = self.index(after: index)
        }
        
        return lastKnownGoodIndex
    }

    func trimSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else {
            return self
        }
        var copy = self
        let start = copy.index(copy.endIndex, offsetBy: -suffix.count)
        let suffixRange = start..<copy.endIndex
        copy.removeSubrange(suffixRange)
        return copy
    }

    func trimmingSuffix(_ characterSet: CharacterSet) -> (remaining: String, suffix: String?) {
        var lastMatchingScalarIndex: String.UnicodeScalarIndex?
        for i in unicodeScalars.indices.reversed() {
            guard characterSet.contains(unicodeScalars[i]) else {
                break
            }
            lastMatchingScalarIndex = i
        }
        
        guard let lastMatchingScalarIndex else {
            return (self, nil)
        }
        
        let remaining = String(unicodeScalars[unicodeScalars.startIndex..<lastMatchingScalarIndex])
        let suffix = String(unicodeScalars[lastMatchingScalarIndex..<unicodeScalars.endIndex])

        return (remaining: remaining, suffix: suffix)
    }

    func camelCase() -> String {
        var copy = ""
        var shouldUppercase = true
        for c in self {
            if c == "_" {
                shouldUppercase = true
            } else if shouldUppercase {
                copy.append(c.uppercased())
                shouldUppercase = false
            } else {
                copy.append(c)
            }
        }
        return copy
    }
    
    func lowerCamelCase() -> String {
        var copy = ""
        var shouldUppercase = false
        var shouldLowercase = true
        for c in self {
            if c == "_" {
                shouldUppercase = true
            } else if shouldLowercase {
                copy.append(c.lowercased())
                shouldLowercase = false
            } else if shouldUppercase {
                copy.append(c.uppercased())
                shouldUppercase = false
            } else {
                copy.append(c)
            }
        }
        return copy
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
            
    func firstMatch(of regex: NSRegularExpression) -> NSTextCheckingResult? {
        regex.firstMatch(in: self,
                         options: [],
                         range: NSRange(self.startIndex..<self.endIndex, in: self))
    }
    
    func trimmed(by count: Int) -> String {
        let newStart = index(startIndex, offsetBy: count, limitedBy: endIndex) ?? endIndex
        let newEnd = index(endIndex, offsetBy: -count, limitedBy: startIndex) ?? startIndex
        guard newStart < newEnd else {
            // if we've crossed, then we've trimmed everything and should return
            //  an empty string.
            return ""
        }
        return String(self[newStart..<newEnd])
    }
    
    func remove(_ regex: NSRegularExpression) -> String {
        guard let match = firstMatch(of: regex) else {
            return self
        }
        return remove(match)
    }
    
    func remove(_ match: NSTextCheckingResult) -> String {
        guard let replaceRange = Range(match.range, in: self) else {
            return self
        }
        
        var subtext = self
        subtext.removeSubrange(replaceRange)
        return subtext
    }

    func replacingOccurrences(of regex: NSRegularExpression, with replacementString: String) -> String {
        regex.stringByReplacingMatches(in: self,
                                       options: [],
                                       range: NSRange(self.startIndex..<self.endIndex, in: self),
                                       withTemplate: replacementString)
    }
    
    func replacingOccurrences(of regex: NSRegularExpression, using transform: (String) -> String) -> String {
        var result = ""
        var lastMatchEndIndex: String.Index?
        regex.enumerateMatches(in: self, options: [], range: NSRange(self.startIndex..<self.endIndex, in: self)) { match, flags, _ in
            guard let match = match, let matchRange = Range(match.range, in: self) else {
                return
            }
            
            let gapStart = lastMatchEndIndex ?? startIndex
            let gapEnd = matchRange.lowerBound
            result.append(contentsOf: self[gapStart..<gapEnd])

            let replacedText = transform(String(self[matchRange]))
            result.append(contentsOf: replacedText)
            
            lastMatchEndIndex = matchRange.upperBound
        }
        
        let gapStart = lastMatchEndIndex ?? startIndex
        if gapStart < endIndex {
            result.append(contentsOf: self[gapStart..<endIndex])
        }
        return result
    }

}
