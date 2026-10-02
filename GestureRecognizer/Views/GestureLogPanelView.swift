import UIKit

final class GestureLogPanelView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Gesture log"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        return label
    }()

    private let textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = true
        view.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        view.backgroundColor = .tertiarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        view.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.accessibilityLabel = "Gesture recognizer state log"
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func display(lines: [String]) {
        textView.text = lines.joined(separator: "\n")
        if !lines.isEmpty {
            let range = NSRange(location: max(0, textView.text.count - 1), length: 1)
            textView.scrollRangeToVisible(range)
        }
    }

    private func setUp() {
        backgroundColor = .clear

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(textView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88)
        ])
    }
}
