import UIKit

/// A single card shown in the demo. The original project toggled between two
/// pictures; profiles keep that idea while relying on SF Symbols so the demo
/// ships without binary image assets.
struct Profile: Hashable, Identifiable {
    let id: Int
    let name: String
    let role: String
    let symbolName: String
    let tintName: String

    var tint: UIColor {
        UIColor(named: tintName) ?? .systemIndigo
    }
}

extension Profile {
    static let all: [Profile] = [
        Profile(
            id: 0,
            name: "Halil",
            role: "iOS Developer",
            symbolName: "person.crop.circle.fill",
            tintName: "ProfilePrimary"
        ),
        Profile(
            id: 1,
            name: "İbrahim",
            role: "Mobile Engineer",
            symbolName: "person.crop.square.fill",
            tintName: "ProfileSecondary"
        )
    ]
}
