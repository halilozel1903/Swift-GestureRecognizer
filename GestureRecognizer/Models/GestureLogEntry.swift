import Foundation
import UIKit

struct GestureLogEntry: Hashable, Sendable {
    let timestamp: Date
    let recognizerName: String
    let stateDescription: String

    var formattedLine: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return "\(formatter.string(from: timestamp))  \(recognizerName) → \(stateDescription)"
    }
}

extension UIGestureRecognizer.State {
    var logDescription: String {
        switch self {
        case .possible: "possible"
        case .began: "began"
        case .changed: "changed"
        case .ended: "ended"
        case .cancelled: "cancelled"
        case .failed: "failed"
        @unknown default: "unknown"
        }
    }
}
