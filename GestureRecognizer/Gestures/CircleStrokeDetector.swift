import CoreGraphics

enum CircleStrokeDetector {
    private static let minimumSampleCount = 12
    private static let closureRatioThreshold: CGFloat = 0.35

    /// Returns whether sampled touch points approximate a closed loop.
    static func isClosedCircle(_ points: [CGPoint]) -> Bool {
        guard points.count >= minimumSampleCount,
              let first = points.first,
              let last = points.last else {
            return false
        }

        let pathLength = polylineLength(points)
        guard pathLength > 40 else { return false }

        let closureDistance = hypot(last.x - first.x, last.y - first.y)
        guard closureDistance / pathLength <= closureRatioThreshold else { return false }

        let centroid = points.reduce(CGPoint.zero) { partial, point in
            CGPoint(x: partial.x + point.x, y: partial.y + point.y)
        }
        let center = CGPoint(x: centroid.x / CGFloat(points.count), y: centroid.y / CGFloat(points.count))

        let radii = points.map { hypot($0.x - center.x, $0.y - center.y) }
        guard let average = radii.average, average > 10 else { return false }

        let variance = radii.map { abs($0 - average) / average }.average ?? 1
        return variance < 0.28
    }

    private static func polylineLength(_ points: [CGPoint]) -> CGFloat {
        guard points.count > 1 else { return 0 }
        return zip(points, points.dropFirst()).reduce(0) { partial, pair in
            partial + hypot(pair.1.x - pair.0.x, pair.1.y - pair.0.y)
        }
    }
}

private extension Array where Element == CGFloat {
    var average: CGFloat? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / CGFloat(count)
    }
}
