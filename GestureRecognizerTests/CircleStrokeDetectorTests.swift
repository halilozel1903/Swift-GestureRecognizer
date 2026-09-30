import CoreGraphics
@testable import GestureRecognizer
import Testing

struct CircleStrokeDetectorTests {
    @Test
    func acceptsRoughCircle() {
        var points: [CGPoint] = []
        let center = CGPoint(x: 100, y: 100)
        let radius: CGFloat = 60
        for index in 0..<36 {
            let angle = CGFloat(index) / 36 * 2 * .pi
            points.append(
                CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )
            )
        }

        #expect(CircleStrokeDetector.isClosedCircle(points))
    }

    @Test
    func rejectsOpenPolyline() {
        let points = (0..<20).map { CGPoint(x: CGFloat($0 * 8), y: 0) }
        #expect(!CircleStrokeDetector.isClosedCircle(points))
    }
}
