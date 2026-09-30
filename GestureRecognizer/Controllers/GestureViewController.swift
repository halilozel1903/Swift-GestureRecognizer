import UIKit

/// Hosts the gesture playground: tapping the card swaps the profile, while the
/// remaining recognizers move, scale and rotate it.
final class GestureViewController: UIViewController {
    enum Layout {
        static let cardWidthMultiplier: CGFloat = 0.8
        static let cardMaxWidth: CGFloat = 420
        static let minimumScale: CGFloat = 0.6
        static let maximumScale: CGFloat = 2.5
    }

    let profiles = Profile.all
    var profileIndex = 0

    var translation: CGPoint = .zero
    var scale: CGFloat = 1
    var rotation: CGFloat = 0

    let settings = GestureSettings.shared
    let logStore = GestureLogStore.shared
    var recognizersByKind: [GestureRecognizerKind: UIGestureRecognizer] = [:]
    var logTargets: [GestureStateLogTarget] = []

    let cardView = GestureCardView()
    private let logPanel = GestureLogPanelView()
    private let dependencySummary = GestureDependencySummaryView()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

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
        Tap to swap profiles, swipe to browse, drag with momentum, pinch and rotate. \
        Draw a circle on the card, hover with a pointer, long-press for a context menu, \
        or swipe in from the left screen edge. Toggle recognizers in Settings.
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            primaryAction: UIAction { [weak self] _ in self?.openSettings() },
            accessibilityLabel: "Gesture settings"
        )

        setUpLayout()
        setUpGestures()
        bindLogPanel()
        applySettingsToRecognizers()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: .gestureSettingsDidChange,
            object: nil
        )

        showProfile(at: profileIndex, announcement: "Ready")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setUpLayout() {
        view.backgroundColor = .systemGroupedBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        for item in [titleLabel, hintLabel, dependencySummary, cardView, statusLabel, logPanel, resetButton] {
            contentStack.addArrangedSubview(item)
        }

        let safeArea = view.safeAreaLayoutGuide
        let cardWidth = cardView.widthAnchor.constraint(
            equalTo: safeArea.widthAnchor,
            multiplier: Layout.cardWidthMultiplier
        )
        cardWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -48
            ),

            cardWidth,
            cardView.widthAnchor.constraint(lessThanOrEqualTo: contentStack.widthAnchor, multiplier: 0.95),
            cardView.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.cardMaxWidth)
        ])
    }

    private func bindLogPanel() {
        logStore.onUpdate = { [weak self] in
            guard let self else { return }
            let lines = logStore.entries.map(\.formattedLine)
            logPanel.display(lines: lines)
        }
        logPanel.display(lines: [])
    }

    func openSettings() {
        navigationController?.pushViewController(GestureSettingsViewController(), animated: true)
    }

    @objc
    private func settingsDidChange() {
        applySettingsToRecognizers()
    }

    func applySettingsToRecognizers() {
        for (kind, recognizer) in recognizersByKind {
            recognizer.isEnabled = settings.isEnabled(kind)
        }
    }

    func register(_ recognizer: UIGestureRecognizer, kind: GestureRecognizerKind, logName: String) {
        recognizersByKind[kind] = recognizer
        logTargets.append(recognizer.attachStateLogging(name: logName))
        recognizer.isEnabled = settings.isEnabled(kind)
    }

    func showProfile(at index: Int, announcement: String) {
        let count = profiles.count
        profileIndex = ((index % count) + count) % count
        let profile = profiles[profileIndex]

        UIView.transition(with: cardView, duration: 0.25, options: .transitionCrossDissolve) {
            self.cardView.configure(with: profile)
        }

        cardView.accessibilityLabel = "\(profile.name), \(profile.role)"
        updateStatus("\(announcement) — \(profile.name)")
    }

    func resetCard(reason: String) {
        translation = .zero
        scale = 1
        rotation = 0

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.cardView.transform = .identity
        }
        playFeedback(.rigid)
        updateStatus("\(reason) — card reset")
    }

    func applyCardTransform() {
        cardView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            .scaledBy(x: scale, y: scale)
            .rotated(by: rotation)
    }

    func updateStatus(_ text: String) {
        statusLabel.text = text
    }

    func playFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
