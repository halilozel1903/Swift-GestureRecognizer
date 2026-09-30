import UIKit

struct GestureDependencyRule: Sendable {
    let dependent: String
    let prerequisite: String
    let reason: String
}

enum GestureDependencyCatalog {
    static let rules: [GestureDependencyRule] = [
        GestureDependencyRule(
            dependent: "Single tap",
            prerequisite: "Double tap",
            reason: "require(toFail:) keeps double tap from being swallowed by single tap."
        ),
        GestureDependencyRule(
            dependent: "Pan",
            prerequisite: "Swipe left / right",
            reason: "Pan waits for swipes to fail so quick flicks stay distinct from drags."
        ),
        GestureDependencyRule(
            dependent: "Screen edge pan",
            prerequisite: "Card pan",
            reason: "Edge drawer waits for the card pan to fail before taking over."
        )
    ]
}

final class GestureDependencySummaryView: UIView {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private func setUp() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous

        let heading = UILabel()
        heading.text = "Failure requirements"
        heading.font = .preferredFont(forTextStyle: .footnote)
        heading.textColor = .secondaryLabel

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(heading)
        heading.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heading.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            heading.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            heading.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            stackView.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])

        addSubview(stackView)

        for rule in GestureDependencyCatalog.rules {
            stackView.addArrangedSubview(makeRow(for: rule))
        }
    }

    private func makeRow(for rule: GestureDependencyRule) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .label
        label.text = "\(rule.dependent) → \(rule.prerequisite)\n\(rule.reason)"
        return label
    }
}
