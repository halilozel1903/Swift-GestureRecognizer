import Foundation

enum GestureRecognizerKind: String, CaseIterable, Identifiable, Sendable {
    case singleTap
    case doubleTap
    case longPress
    case swipeLeft
    case swipeRight
    case pan
    case pinch
    case rotation
    case screenEdgePan
    case hover
    case circleStroke
    case contextMenu

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .singleTap: "Single tap"
        case .doubleTap: "Double tap"
        case .longPress: "Long press"
        case .swipeLeft: "Swipe left"
        case .swipeRight: "Swipe right"
        case .pan: "Pan"
        case .pinch: "Pinch"
        case .rotation: "Rotation"
        case .screenEdgePan: "Screen edge pan"
        case .hover: "Hover / pointer"
        case .circleStroke: "Circle stroke (custom)"
        case .contextMenu: "Context menu"
        }
    }

    var settingsKey: String { "gesture.enabled.\(rawValue)" }
}
