import UIKit

/// Interactive card that hosts every gesture recognizer of the demo.
final class GestureCardView: UIView {
    private let symbolView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 120,
            weight: .semibold
        )
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; this view is created in code.")
    }

    func configure(with profile: Profile) {
        symbolView.image = UIImage(systemName: profile.symbolName)
        symbolView.tintColor = profile.tint
        nameLabel.text = profile.name
        roleLabel.text = profile.role
        nameLabel.textColor = .label
        layer.borderColor = profile.tint.withAlphaComponent(0.35).cgColor
    }

    private func setUpView() {
        backgroundColor = .secondarySystemGroupedBackground
        isUserInteractionEnabled = true
        layer.cornerRadius = 28
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)

        // CGColor does not resolve dynamic colors automatically.
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: GestureCardView, _) in
            view.layer.shadowColor = UIColor.label.cgColor
            view.layer.borderColor = view.symbolView.tintColor
                .withAlphaComponent(0.35)
                .cgColor
        }

        let stackView = UIStackView(arrangedSubviews: [symbolView, nameLabel, roleLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32)
        ])
    }
}
