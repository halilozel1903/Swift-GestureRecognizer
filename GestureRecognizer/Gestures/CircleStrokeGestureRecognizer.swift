import UIKit

/// Custom recognizer that fires when the user draws a roughly closed circle on the view.
final class CircleStrokeGestureRecognizer: UIGestureRecognizer {
    private var samples: [CGPoint] = []

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else {
            state = .failed
            return
        }
        samples = [touch.location(in: view)]
        state = .began
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else { return }
        samples.append(touch.location(in: view))
        state = .changed

        if CircleStrokeDetector.isClosedCircle(samples) {
            state = .ended
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if CircleStrokeDetector.isClosedCircle(samples) {
            state = .ended
        } else {
            state = .failed
        }
        samples.removeAll()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        samples.removeAll()
        state = .cancelled
    }

    override func reset() {
        super.reset()
        samples.removeAll()
    }
}
