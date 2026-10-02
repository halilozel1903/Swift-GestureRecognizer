import UIKit

@MainActor
final class GestureLogStore {
    static let shared = GestureLogStore()

    private(set) var entries: [GestureLogEntry] = []
    var onUpdate: (() -> Void)?

    private let capacity: Int

    init(capacity: Int = 120) {
        self.capacity = capacity
    }

    func append(recognizerName: String, state: UIGestureRecognizer.State) {
        let entry = GestureLogEntry(
            timestamp: Date(),
            recognizerName: recognizerName,
            stateDescription: state.logDescription
        )
        entries.append(entry)
        if entries.count > capacity {
            entries.removeFirst(entries.count - capacity)
        }
        onUpdate?()
    }

    func clear() {
        entries.removeAll()
        onUpdate?()
    }
}
