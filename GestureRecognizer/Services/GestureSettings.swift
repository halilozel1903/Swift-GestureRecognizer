import Foundation

@MainActor
final class GestureSettings {
    static let shared = GestureSettings()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isEnabled(_ kind: GestureRecognizerKind) -> Bool {
        if defaults.object(forKey: kind.settingsKey) == nil {
            return true
        }
        return defaults.bool(forKey: kind.settingsKey)
    }

    func setEnabled(_ kind: GestureRecognizerKind, enabled: Bool) {
        defaults.set(enabled, forKey: kind.settingsKey)
        NotificationCenter.default.post(name: .gestureSettingsDidChange, object: kind)
    }

    func resetAllToEnabled() {
        for kind in GestureRecognizerKind.allCases {
            defaults.removeObject(forKey: kind.settingsKey)
        }
        NotificationCenter.default.post(name: .gestureSettingsDidChange, object: nil)
    }
}

extension Notification.Name {
    static let gestureSettingsDidChange = Notification.Name("GestureSettingsDidChange")
}
