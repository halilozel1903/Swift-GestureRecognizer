import CoreGraphics
@testable import GestureRecognizer
import Testing

struct PanDecelerationPhysicsTests {
    @Test
    func projectedTranslationFollowsVelocitySign() {
        let projected = PanDecelerationPhysics.projectedTranslation(velocity: CGPoint(x: 500, y: -200))
        #expect(projected.x > 0)
        #expect(projected.y < 0)
    }

    @Test
    func springDurationIncreasesWithDistance() {
        let short = PanDecelerationPhysics.springDuration(forDistance: 20)
        let long = PanDecelerationPhysics.springDuration(forDistance: 400)
        #expect(long > short)
    }
}
