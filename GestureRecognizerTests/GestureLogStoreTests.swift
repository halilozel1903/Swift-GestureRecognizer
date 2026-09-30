import Testing
import UIKit

@MainActor
struct GestureLogStoreTests {
    @Test
    func appendsAndTrimsEntries() {
        let store = GestureLogStore(capacity: 3)
        store.append(recognizerName: "Pan", state: .began)
        store.append(recognizerName: "Pan", state: .changed)
        store.append(recognizerName: "Pan", state: .ended)
        store.append(recognizerName: "Tap", state: .ended)

        #expect(store.entries.count == 3)
        #expect(store.entries.first?.recognizerName == "Pan")
        #expect(store.entries.last?.recognizerName == "Tap")
    }

    @Test
    func stateDescriptionsMatchUIKitNames() {
        #expect(UIGestureRecognizer.State.possible.logDescription == "possible")
        #expect(UIGestureRecognizer.State.failed.logDescription == "failed")
    }
}
