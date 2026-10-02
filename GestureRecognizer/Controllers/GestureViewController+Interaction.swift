import UIKit

extension GestureViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        isTransformGesture(gestureRecognizer) && isTransformGesture(otherGestureRecognizer)
    }

    private func isTransformGesture(_ recognizer: UIGestureRecognizer) -> Bool {
        switch recognizer {
        case is UIPinchGestureRecognizer, is UIRotationGestureRecognizer:
            true
        case is UIPanGestureRecognizer:
            !(recognizer is UIScreenEdgePanGestureRecognizer)
        default:
            false
        }
    }
}

extension GestureViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard settings.isEnabled(.contextMenu) else { return nil }
        logStore.append(recognizerName: "Context menu", state: .began)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let next = UIAction(
                title: "Next profile",
                image: UIImage(systemName: "person.crop.circle.badge.plus")
            ) { _ in
                self.showProfile(at: self.profileIndex + 1, announcement: "Context menu")
            }
            let reset = UIAction(title: "Reset card", image: UIImage(systemName: "arrow.counterclockwise")) { _ in
                self.resetCard(reason: "Context menu")
            }
            let clearLog = UIAction(title: "Clear gesture log", image: UIImage(systemName: "trash")) { _ in
                self.logStore.clear()
            }
            return UIMenu(title: "Card actions", children: [next, reset, clearLog])
        }
    }
}
