import UIKit

final class GestureStateLogTarget: NSObject {
    private let name: String
    private weak var store: GestureLogStore?

    init(name: String, store: GestureLogStore) {
        self.name = name
        self.store = store
    }

    @objc
    func logState(_ recognizer: UIGestureRecognizer) {
        Task { @MainActor [weak store, name] in
            store?.append(recognizerName: name, state: recognizer.state)
        }
    }
}

extension UIGestureRecognizer {
    @discardableResult
    func attachStateLogging(name: String, store: GestureLogStore = .shared) -> GestureStateLogTarget {
        let target = GestureStateLogTarget(name: name, store: store)
        addTarget(target, action: #selector(GestureStateLogTarget.logState(_:)))
        return target
    }
}
