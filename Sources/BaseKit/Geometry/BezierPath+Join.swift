public extension BezierPath {
    struct Subpath: Equatable, Sendable {
        public let elements: [Element]
        public let isClosed: Bool

        public var startPoint: Point? {
            elements.first?.endPoint
        }

        public var endPoint: Point? {
            elements.last(where: { $0.endPoint != nil })?.endPoint
        }
    }

    func splitIntoSubpaths() -> [Subpath] {
        var subpaths = [Subpath]()
        var current = [Element]()
        var isClosed = false

        for element in elements {
            switch element {
            case .move:
                if !current.isEmpty {
                    subpaths.append(Subpath(elements: current, isClosed: isClosed))
                    current = []
                    isClosed = false
                }
                current.append(element)
            case .line, .curve:
                current.append(element)
            case .closeSubpath:
                isClosed = true
                if !current.isEmpty {
                    subpaths.append(Subpath(elements: current, isClosed: isClosed))
                    current = []
                    isClosed = false
                }
            }
        }

        if !current.isEmpty {
            subpaths.append(Subpath(elements: current, isClosed: isClosed))
        }

        return subpaths
    }

    /// Returns a closed version of this path by appending `.closeSubpath`
    /// to any open subpaths.
    func closed() -> BezierPath {
        let subpaths = splitIntoSubpaths()
        guard !subpaths.isEmpty else { return self }

        var result = BezierPath()
        for subpath in subpaths {
            result.append(contentsOf: BezierPath(elements: subpath.elements))
            result.closeSubpath()
        }
        return result
    }

    /// Joins multiple open paths into a single continuous path by connecting
    /// their nearest endpoints. Closed subpaths are preserved unchanged.
    ///
    /// The algorithm greedily finds the closest pair of open-subpath endpoints
    /// across all paths and connects them with a line segment (or merges them
    /// if within `tolerance`). It repeats until only one open subpath remains.
    static func joined(_ paths: [BezierPath], tolerance: Real) -> BezierPath {
        // Collect all subpaths from all input paths
        var openSubpaths = [OpenSubpathElements]()
        var closedSubpaths = [[Element]]()

        for path in paths {
            for subpath in path.splitIntoSubpaths() {
                if subpath.isClosed {
                    closedSubpaths.append(subpath.elements)
                } else {
                    openSubpaths.append(OpenSubpathElements(subpath.elements))
                }
            }
        }

        // Greedily join open subpaths by nearest endpoints
        while openSubpaths.count >= 2 {
            let (indexA, indexB, connection) = findClosestEndpointPair(openSubpaths)
            let subpathA = openSubpaths[indexA]
            let subpathB = openSubpaths[indexB]

            let joined = connect(subpathA, to: subpathB, via: connection, tolerance: tolerance)

            // Remove both (higher index first to preserve lower index)
            let removeFirst = Swift.max(indexA, indexB)
            let removeSecond = Swift.min(indexA, indexB)
            openSubpaths.remove(at: removeFirst)
            openSubpaths.remove(at: removeSecond)
            openSubpaths.append(joined)
        }

        // Assemble result: open subpath first, then closed subpaths
        var result = BezierPath()

        if let remaining = openSubpaths.first {
            result.append(contentsOf: BezierPath(elements: remaining.elements))
        }

        for closed in closedSubpaths {
            result.append(contentsOf: BezierPath(elements: closed))
            result.closeSubpath()
        }

        return result
    }
}

// MARK: - Join internals

private struct OpenSubpathElements {
    var elements: [BezierPath.Element]

    var startPoint: Point? {
        elements.first?.endPoint
    }

    var endPoint: Point? {
        elements.last(where: { $0.endPoint != nil })?.endPoint
    }

    init(_ elements: [BezierPath.Element]) {
        self.elements = elements
    }

    func reversed() -> OpenSubpathElements {
        var result = BezierPath()
        result.appendReverse(elements)
        return OpenSubpathElements(result.elements)
    }
}

/// Describes which endpoints of two subpaths are closest.
private enum EndpointConnection {
    case endToStart   // A.end → B.start (simplest: concatenate)
    case endToEnd     // A.end → B.end (reverse B)
    case startToStart // A.start → B.start (reverse A)
    case startToEnd   // A.start → B.end (reverse A, then append B reversed — or just swap order)
}

private extension BezierPath {
    static func findClosestEndpointPair(
        _ subpaths: [OpenSubpathElements]
    ) -> (Int, Int, EndpointConnection) {
        var bestDistance = Real.greatestFiniteMagnitude
        var bestA = 0
        var bestB = 1
        var bestConnection = EndpointConnection.endToStart

        for i in 0..<subpaths.count {
            guard let startI = subpaths[i].startPoint,
                let endI = subpaths[i].endPoint
            else { continue }

            for j in (i + 1)..<subpaths.count {
                guard let startJ = subpaths[j].startPoint,
                    let endJ = subpaths[j].endPoint
                else { continue }

                let pairs: [(Real, EndpointConnection)] = [
                    (endI.distance(to: startJ), .endToStart),
                    (endI.distance(to: endJ), .endToEnd),
                    (startI.distance(to: startJ), .startToStart),
                    (startI.distance(to: endJ), .startToEnd),
                ]

                for (distance, connection) in pairs {
                    if distance < bestDistance {
                        bestDistance = distance
                        bestA = i
                        bestB = j
                        bestConnection = connection
                    }
                }
            }
        }

        return (bestA, bestB, bestConnection)
    }

    static func connect(
        _ a: OpenSubpathElements,
        to b: OpenSubpathElements,
        via connection: EndpointConnection,
        tolerance: Real
    ) -> OpenSubpathElements {
        // Orient both subpaths so we always connect A.end → B.start
        let orientedA: OpenSubpathElements
        let orientedB: OpenSubpathElements

        switch connection {
        case .endToStart:
            orientedA = a
            orientedB = b
        case .endToEnd:
            orientedA = a
            orientedB = b.reversed()
        case .startToStart:
            orientedA = a.reversed()
            orientedB = b
        case .startToEnd:
            orientedA = b
            orientedB = a
        }

        guard let endA = orientedA.endPoint,
            let startB = orientedB.startPoint
        else {
            // Fallback: just concatenate
            return OpenSubpathElements(orientedA.elements + orientedB.elements)
        }

        let distance = endA.distance(to: startB)

        // Build joined elements: A's elements, optional connector, B's elements (skipping B's move)
        var joined = orientedA.elements

        let bSegments = Array(orientedB.elements.dropFirst()) // Drop the leading .move

        if distance >= tolerance {
            // Add a line segment to bridge the gap
            joined.append(.line(to: startB))
        }
        // If within tolerance, we skip the connector — the endpoints merge

        joined.append(contentsOf: bSegments)

        return OpenSubpathElements(joined)
    }
}
