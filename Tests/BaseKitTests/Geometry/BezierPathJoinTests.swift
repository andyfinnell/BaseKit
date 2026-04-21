import Testing
@testable import BaseKit

struct BezierPathJoinTests {
    // MARK: - splitIntoSubpaths

    @Test func splitEmptyPathReturnsNoSubpaths() {
        let path = BezierPath()
        let subpaths = path.splitIntoSubpaths()
        #expect(subpaths.isEmpty)
    }

    @Test func splitSingleOpenSubpath() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 10, y: 10)),
        ])
        let subpaths = path.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        #expect(!subpaths[0].isClosed)
        #expect(subpaths[0].startPoint == Point(x: 0, y: 0))
        #expect(subpaths[0].endPoint == Point(x: 10, y: 10))
    }

    @Test func splitSingleClosedSubpath() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 10, y: 10)),
            .closeSubpath,
        ])
        let subpaths = path.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        #expect(subpaths[0].isClosed)
    }

    @Test func splitMultipleSubpaths() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .move(to: Point(x: 20, y: 0)),
            .line(to: Point(x: 30, y: 0)),
        ])
        let subpaths = path.splitIntoSubpaths()
        #expect(subpaths.count == 2)
        #expect(subpaths[0].startPoint == Point(x: 0, y: 0))
        #expect(subpaths[0].endPoint == Point(x: 10, y: 0))
        #expect(subpaths[1].startPoint == Point(x: 20, y: 0))
        #expect(subpaths[1].endPoint == Point(x: 30, y: 0))
    }

    // MARK: - closed()

    @Test func closedOnAlreadyClosedPathReturnsSame() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .closeSubpath,
        ])
        let result = path.closed()
        #expect(result.elements == path.elements)
    }

    @Test func closedOnOpenPathAppendsCloseSubpath() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 10, y: 10)),
        ])
        let result = path.closed()
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        #expect(subpaths[0].isClosed)
    }

    // MARK: - opened()

    @Test func openedOnAlreadyOpenPathReturnsSame() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 10, y: 10)),
        ])
        let result = path.opened()
        #expect(result.elements == path.elements)
    }

    @Test func openedOnClosedPathRemovesCloseSubpath() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 10, y: 10)),
            .closeSubpath,
        ])
        let result = path.opened()
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        #expect(!subpaths[0].isClosed)
        #expect(result.elements == [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 10, y: 10)),
        ])
    }

    @Test func openedOnMultipleClosedSubpathsOpensAll() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .closeSubpath,
            .move(to: Point(x: 20, y: 0)),
            .line(to: Point(x: 30, y: 0)),
            .closeSubpath,
        ])
        let result = path.opened()
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 2)
        #expect(!subpaths[0].isClosed)
        #expect(!subpaths[1].isClosed)
    }

    @Test func openedOnMixedSubpathsOpensClosedOnes() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .closeSubpath,
            .move(to: Point(x: 20, y: 0)),
            .line(to: Point(x: 30, y: 0)),
        ])
        let result = path.opened()
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 2)
        #expect(!subpaths[0].isClosed)
        #expect(!subpaths[1].isClosed)
    }

    @Test func openedOnEmptyPathReturnsEmpty() {
        let path = BezierPath()
        let result = path.opened()
        #expect(result.elements.isEmpty)
    }

    // MARK: - joined: two paths, end-to-start

    @Test func joinTwoPathsEndToStart() {
        // Path A ends at (10, 0), Path B starts at (10, 0)
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 20, y: 0)),
        ])

        let result = BezierPath.joined([pathA, pathB], tolerance: 1.0)
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        #expect(!subpaths[0].isClosed)
        #expect(subpaths[0].startPoint == Point(x: 0, y: 0))
        #expect(subpaths[0].endPoint == Point(x: 20, y: 0))
    }

    @Test func joinTwoPathsCoincidentEndpointsMerges() {
        // Endpoints are the same point — should merge without adding a line
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 20, y: 0)),
        ])

        let result = BezierPath.joined([pathA, pathB], tolerance: 1.0)
        // Should be: move(0,0), line(10,0), line(20,0) — no extra connector
        #expect(result.elements.count == 3)
        #expect(result.elements[0] == .move(to: Point(x: 0, y: 0)))
        #expect(result.elements[1] == .line(to: Point(x: 10, y: 0)))
        #expect(result.elements[2] == .line(to: Point(x: 20, y: 0)))
    }

    @Test func joinTwoPathsWithGapAddsLineSegment() {
        // Path A ends at (10, 0), Path B starts at (15, 0) — gap of 5
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 15, y: 0)),
            .line(to: Point(x: 25, y: 0)),
        ])

        let result = BezierPath.joined([pathA, pathB], tolerance: 1.0)
        // Should be: move(0,0), line(10,0), line(15,0), line(25,0)
        #expect(result.elements.count == 4)
        #expect(result.elements[0] == .move(to: Point(x: 0, y: 0)))
        #expect(result.elements[1] == .line(to: Point(x: 10, y: 0)))
        #expect(result.elements[2] == .line(to: Point(x: 15, y: 0)))
        #expect(result.elements[3] == .line(to: Point(x: 25, y: 0)))
    }

    // MARK: - joined: reversing for continuity

    @Test func joinTwoPathsEndToEndReversesSecond() {
        // Path A ends at (10, 0), Path B ends at (10, 5) — end-to-end is closest
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 20, y: 0)),
            .line(to: Point(x: 10, y: 5)),
        ])

        let result = BezierPath.joined([pathA, pathB], tolerance: 1.0)
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        // Should connect A.end(10,0) to B.end(10,5), reversing B
        // Result: move(0,0), line(10,0), line(10,5), line(20,0)
        #expect(subpaths[0].startPoint == Point(x: 0, y: 0))
        #expect(subpaths[0].endPoint == Point(x: 20, y: 0))
    }

    @Test func joinTwoPathsStartToStartReversesFirst() {
        // Path A starts at (10, 0), Path B starts at (10, 5) — start-to-start closest
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 0, y: 0)),
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 10, y: 5)),
            .line(to: Point(x: 20, y: 0)),
        ])

        let result = BezierPath.joined([pathA, pathB], tolerance: 6.0)
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        // The start-to-start distance is 5 (within tolerance 6), so merges
        #expect(!subpaths[0].isClosed)
    }

    // MARK: - joined: three or more paths

    @Test func joinThreePathsIteratively() {
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 20, y: 0)),
        ])
        let pathC = BezierPath(elements: [
            .move(to: Point(x: 20, y: 0)),
            .line(to: Point(x: 30, y: 0)),
        ])

        let result = BezierPath.joined([pathA, pathB, pathC], tolerance: 1.0)
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        #expect(subpaths[0].startPoint == Point(x: 0, y: 0))
        #expect(subpaths[0].endPoint == Point(x: 30, y: 0))
    }

    // MARK: - joined: preserves closed subpaths

    @Test func joinPreservesClosedSubpaths() {
        // Path A has a closed subpath, Path B and C are open
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .line(to: Point(x: 10, y: 10)),
            .closeSubpath,
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 20, y: 0)),
            .line(to: Point(x: 30, y: 0)),
        ])
        let pathC = BezierPath(elements: [
            .move(to: Point(x: 30, y: 0)),
            .line(to: Point(x: 40, y: 0)),
        ])

        let result = BezierPath.joined([pathA, pathB, pathC], tolerance: 1.0)
        let subpaths = result.splitIntoSubpaths()
        // Should have: one joined open subpath (B+C) and one closed subpath (A)
        #expect(subpaths.count == 2)

        let closedCount = subpaths.filter(\.isClosed).count
        let openCount = subpaths.filter { !$0.isClosed }.count
        #expect(closedCount == 1)
        #expect(openCount == 1)
    }

    // MARK: - joined: with curves

    @Test func joinPathsWithCurvesPreservesCurveData() {
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .curve(to: Point(x: 10, y: 0), control1: Point(x: 3, y: 5), control2: Point(x: 7, y: 5)),
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 10, y: 0)),
            .curve(to: Point(x: 20, y: 0), control1: Point(x: 13, y: -5), control2: Point(x: 17, y: -5)),
        ])

        let result = BezierPath.joined([pathA, pathB], tolerance: 1.0)
        #expect(result.elements.count == 3) // move + curve + curve
        if case let .curve(to: end, control1: _, control2: _) = result.elements[2] {
            #expect(end == Point(x: 20, y: 0))
        } else {
            Issue.record("Expected curve element")
        }
    }

    // MARK: - joined: single path returns as-is

    @Test func joinSinglePathReturnsUnchanged() {
        let path = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
        ])

        let result = BezierPath.joined([path], tolerance: 1.0)
        #expect(result.elements == path.elements)
    }

    // MARK: - joined: all closed paths returns unchanged

    @Test func joinAllClosedPathsPreservesAll() {
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 10, y: 0)),
            .closeSubpath,
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 20, y: 0)),
            .line(to: Point(x: 30, y: 0)),
            .closeSubpath,
        ])

        let result = BezierPath.joined([pathA, pathB], tolerance: 1.0)
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 2)
        #expect(subpaths[0].isClosed)
        #expect(subpaths[1].isClosed)
    }

    // MARK: - joined: nearest endpoint selection

    @Test func joinSelectsNearestEndpoints() {
        // Path A: (0,0) → (100,0)
        // Path B: (50,0) → (200,0)
        // Closest pair: A.end(100,0) to B.start(50,0) = 50
        // vs A.end(100,0) to B.end(200,0) = 100
        // vs A.start(0,0) to B.start(50,0) = 50
        // vs A.start(0,0) to B.end(200,0) = 200
        // Ties: A.end→B.start and A.start→B.start both = 50
        // The algorithm should pick one and produce a valid join
        let pathA = BezierPath(elements: [
            .move(to: Point(x: 0, y: 0)),
            .line(to: Point(x: 100, y: 0)),
        ])
        let pathB = BezierPath(elements: [
            .move(to: Point(x: 50, y: 0)),
            .line(to: Point(x: 200, y: 0)),
        ])

        let result = BezierPath.joined([pathA, pathB], tolerance: 1.0)
        let subpaths = result.splitIntoSubpaths()
        #expect(subpaths.count == 1)
        #expect(!subpaths[0].isClosed)
    }
}
