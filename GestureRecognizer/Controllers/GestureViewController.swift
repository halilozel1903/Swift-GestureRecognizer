import UIKit

/// Hosts the gesture playground: tapping the card swaps the profile, while the
/// remaining recognizers move, scale and rotate it.
final class GestureViewController: UIViewController {
    private enum Layout {
        static let cardWidthMultiplier: CGFloat = 0.8
        static let cardMaxWidth: CGFloat = 420
        static let minimumScale: CGFloat = 0.6
        static let maximumScale: CGFloat = 2.5
    }

    private let profiles = Profile.all
    private var profileIndex = 0

    private var translation: CGPoint = .zero
    private var scale: CGFloat = 1
    private var rotation: CGFloat = 0

    private let cardView = GestureCardView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Gesture Playground"
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Tap to swap the profile, swipe to browse, drag, pinch and rotate freely. \
        Double tap or long press to start over.
        """
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityTraits = .updatesFrequently
        return label
    }()

    private lazy var resetButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "Reset card"
        configuration.image = UIImage(systemName: "arrow.counterclockwise")
        configuration.imagePadding = 8
        configuration.cornerStyle = .large

        let action = UIAction { [weak self] _ in
            self?.resetCard(reason: "Reset button")
        }
        return UIButton(configuration: configuration, primaryAction: action)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        setUpGestures()
        showProfile(at: profileIndex, announcement: "Ready")
    }

    // MARK: - Layout

    private func setUpLayout() {
        view.backgroundColor = .systemGroupedBackground

        let stackView = UIStackView(arrangedSubviews: [titleLabel, hintLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        cardView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        view.addSubview(cardView)
        view.addSubview(statusLabel)
        view.addSubview(resetButton)

        let safeArea = view.safeAreaLayoutGuide
        let cardWidth = cardView.widthAnchor.constraint(
            equalTo: safeArea.widthAnchor,
            multiplier: Layout.cardWidthMultiplier
        )
        cardWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),

            cardView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            cardWidth,
            cardView.widthAnchor.constraint(lessThanOrEqualTo: safeArea.widthAnchor, multiplier: 0.9),
            cardView.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.cardMaxWidth),

            statusLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            statusLabel.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -16),

            resetButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            resetButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Gestures

    private func setUpGestures() {
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

        for recognizer in [doubleTap, singleTap, longPress, swipeLeft, swipeRight, pan, pinch, rotation] {
            recognizer.delegate = self
            cardView.addGestureRecognizer(recognizer)
        }
    }

    @objc
    private func handleSingleTap() {
        showProfile(at: profileIndex + 1, announcement: "Single tap")
        playFeedback(.light)
    }

    @objc
    private func handleDoubleTap() {
        resetCard(reason: "Double tap")
    }

    @objc
    private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
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
    private func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
        let isForward = recognizer.direction == .left
        showProfile(
            at: profileIndex + (isForward ? 1 : -1),
            announcement: isForward ? "Swipe left" : "Swipe right"
        )
    }

    @objc
    private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let delta = recognizer.translation(in: view)
        translation.x += delta.x
        translation.y += delta.y
        recognizer.setTranslation(.zero, in: view)

        applyCardTransform()
        updateStatus(String(format: "Pan — x: %.0f, y: %.0f", translation.x, translation.y))
    }

    @objc
    private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        scale = min(max(scale * recognizer.scale, Layout.minimumScale), Layout.maximumScale)
        recognizer.scale = 1

        applyCardTransform()
        updateStatus(String(format: "Pinch — scale: %.2fx", scale))
    }

    @objc
    private func handleRotation(_ recognizer: UIRotationGestureRecognizer) {
        rotation += recognizer.rotation
        recognizer.rotation = 0

        applyCardTransform()
        let degrees = rotation * 180 / .pi
        updateStatus(String(format: "Rotation — %.0f°", degrees))
    }

    // MARK: - State

    private func showProfile(at index: Int, announcement: String) {
        let count = profiles.count
        profileIndex = ((index % count) + count) % count
        let profile = profiles[profileIndex]

        UIView.transition(with: cardView, duration: 0.25, options: .transitionCrossDissolve) {
            self.cardView.configure(with: profile)
        }

        cardView.accessibilityLabel = "\(profile.name), \(profile.role)"
        updateStatus("\(announcement) — \(profile.name)")
    }

    private func resetCard(reason: String) {
        translation = .zero
        scale = 1
        rotation = 0

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.cardView.transform = .identity
        }
        playFeedback(.rigid)
        updateStatus("\(reason) — card reset")
    }

    private func applyCardTransform() {
        cardView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            .scaledBy(x: scale, y: scale)
            .rotated(by: rotation)
    }

    private func updateStatus(_ text: String) {
        statusLabel.text = text
    }

    private func playFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension GestureViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        isTransformGesture(gestureRecognizer) && isTransformGesture(otherGestureRecognizer)
    }

    /// Pan, pinch and rotation drive the same transform, so they must run together.
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
