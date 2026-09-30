import CoreGraphics
import Foundation

enum PanDecelerationPhysics {
    /// Projects how far a pan would travel if deceleration matched UIScrollView defaults.
    static func projectedTranslation(
        velocity: CGPoint,
        decelerationRate: CGFloat = 0.998,
        frameDuration: CGFloat = 1.0 / 60.0
    ) -> CGPoint {
        guard decelerationRate > 0, decelerationRate < 1 else { return .zero }

        var remaining = velocity
        var offset = CGPoint.zero
        var speed = hypot(remaining.x, remaining.y)

        while speed > 1 {
            offset.x += remaining.x * frameDuration
            offset.y += remaining.y * frameDuration
            let scale = pow(decelerationRate, frameDuration * 1000)
            remaining.x *= scale
            remaining.y *= scale
            speed = hypot(remaining.x, remaining.y)
        }

        return offset
    }

    static func springDuration(forDistance distance: CGFloat) -> TimeInterval {
        let clamped = min(max(distance, 0), 800)
        return TimeInterval(0.25 + clamped / 2000)
    }
}
