import UIKit

final class GestureSettingsViewController: UITableViewController {
    private let settings = GestureSettings.shared

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gesture settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(resetAll)
        )
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        GestureRecognizerKind.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kind = GestureRecognizerKind.allCases[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = kind.displayName
        cell.detailTextLabel?.text = "Toggle at runtime via isEnabled"
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none

        let toggle = UISwitch()
        toggle.isOn = settings.isEnabled(kind)
        toggle.tag = indexPath.row
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        cell.accessoryView = toggle
        return cell
    }

    @objc
    private func toggleChanged(_ sender: UISwitch) {
        let kind = GestureRecognizerKind.allCases[sender.tag]
        settings.setEnabled(kind, enabled: sender.isOn)
    }

    @objc
    private func resetAll() {
        settings.resetAllToEnabled()
        tableView.reloadData()
    }
}
