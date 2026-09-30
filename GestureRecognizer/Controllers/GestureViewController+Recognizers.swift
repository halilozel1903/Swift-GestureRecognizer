import UIKit

extension GestureViewController {
    func setUpGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTap.require(toFail: doubleTap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.4

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.maximumNumberOfTouches = 2
        pan.require(toFail: swipeLeft)
        pan.require(toFail: swipeRight)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))

        let circle = CircleStrokeGestureRecognizer(target: self, action: #selector(handleCircleStroke))

        let hover = UIHoverGestureRecognizer(target: self, action: #selector(handleHover))

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgePan))
        edgePan.edges = .left
        edgePan.require(toFail: pan)

        cardView.addInteraction(UIContextMenuInteraction(delegate: self))

        let cardRecognizers: [(UIGestureRecognizer, GestureRecognizerKind, String)] = [
            (doubleTap, .doubleTap, "Double tap"),
            (singleTap, .singleTap, "Single tap"),
            (longPress, .longPress, "Long press"),
            (swipeLeft, .swipeLeft, "Swipe left"),
            (swipeRight, .swipeRight, "Swipe right"),
            (pan, .pan, "Pan"),
            (pinch, .pinch, "Pinch"),
            (rotation, .rotation, "Rotation"),
            (circle, .circleStroke, "Circle stroke"),
            (hover, .hover, "Hover")
        ]

        for (recognizer, kind, name) in cardRecognizers {
            recognizer.delegate = self
            cardView.addGestureRecognizer(recognizer)
            register(recognizer, kind: kind, logName: name)
        }

        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)
        register(edgePan, kind: .screenEdgePan, logName: "Screen edge pan")
    }

    @objc
    func handleSingleTap() {
        guard settings.isEnabled(.singleTap) else { return }
        showProfile(at: profileIndex + 1, announcement: "Single tap")
        playFeedback(.light)
    }

    @objc
    func handleDoubleTap() {
        guard settings.isEnabled(.doubleTap) else { return }
        resetCard(reason: "Double tap")
    }

    @objc
    func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard settings.isEnabled(.longPress) else { return }
        switch recognizer.state {
        case .began:
            playFeedback(.medium)
            updateStatus("Long press — hold to preview, release to reset")
            UIView.animate(withDuration: 0.2) {
                self.cardView.alpha = 0.75
            }
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: 0.2) {
                self.cardView.alpha = 1
            }
            resetCard(reason: "Long press")
        default:
            break
        }
    }

    @objc
    func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
        let isLeft = recognizer.direction == .left
        guard settings.isEnabled(isLeft ? .swipeLeft : .swipeRight) else { return }
        showProfile(
            at: profileIndex + (isLeft ? 1 : -1),
            announcement: isLeft ? "Swipe left" : "Swipe right"
        )
    }

    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard settings.isEnabled(.pan) else { return }

        switch recognizer.state {
        case .began, .changed:
            let delta = recognizer.translation(in: view)
            translation.x += delta.x
            translation.y += delta.y
            recognizer.setTranslation(.zero, in: view)
            applyCardTransform()
            updateStatus(String(format: "Pan — x: %.0f, y: %.0f", translation.x, translation.y))
        case .ended:
            let velocity = recognizer.velocity(in: view)
            let projected = PanDecelerationPhysics.projectedTranslation(velocity: velocity)
            translation.x += projected.x
            translation.y += projected.y
            let distance = hypot(projected.x, projected.y)
            let duration = PanDecelerationPhysics.springDuration(forDistance: distance)
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.82,
                initialSpringVelocity: min(hypot(velocity.x, velocity.y) / 800, 2),
                animations: {
                    self.applyCardTransform()
                }
            )
            updateStatus(String(format: "Pan ended — momentum x: %.0f", projected.x))
        default:
            break
        }
    }

    @objc
    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        guard settings.isEnabled(.pinch) else { return }
        scale = min(max(scale * recognizer.scale, Layout.minimumScale), Layout.maximumScale)
        recognizer.scale = 1

        applyCardTransform()
        updateStatus(String(format: "Pinch — scale: %.2fx", scale))
    }

    @objc
    func handleRotation(_ recognizer: UIRotationGestureRecognizer) {
        guard settings.isEnabled(.rotation) else { return }
        rotation += recognizer.rotation
        recognizer.rotation = 0

        applyCardTransform()
        let degrees = rotation * 180 / .pi
        updateStatus(String(format: "Rotation — %.0f°", degrees))
    }

    @objc
    func handleCircleStroke() {
        guard settings.isEnabled(.circleStroke) else { return }
        playFeedback(.heavy)
        showProfile(at: profileIndex + 1, announcement: "Circle stroke")
        updateStatus("Custom recognizer — circle stroke detected")
    }

    @objc
    func handleHover(_ recognizer: UIHoverGestureRecognizer) {
        guard settings.isEnabled(.hover) else { return }
        switch recognizer.state {
        case .began, .changed:
            cardView.layer.shadowOpacity = 0.28
            cardView.layer.borderWidth = 2
            updateStatus("Hover — pointer over card")
        case .ended, .cancelled:
            cardView.layer.shadowOpacity = 0.12
            cardView.layer.borderWidth = 1
        default:
            break
        }
    }

    @objc
    func handleScreenEdgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard settings.isEnabled(.screenEdgePan) else { return }
        guard recognizer.state == .ended else { return }
        guard recognizer.translation(in: view).x > 60 else { return }

        playFeedback(.medium)
        openSettings()
        updateStatus("Screen edge pan — opening settings")
    }
}
