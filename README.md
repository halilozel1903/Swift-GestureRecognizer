# Swift Gesture Recognizer

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![iOS](https://img.shields.io/badge/iOS-26.0%2B-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.3-FA7343?logo=swift&logoColor=white)](https://www.swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-26.6-1575F9?logo=xcode&logoColor=white)](https://developer.apple.com/xcode/)
[![UIKit](https://img.shields.io/badge/UI-UIKit-informational.svg)](https://developer.apple.com/documentation/uikit)
[![CI](https://github.com/halilozel1903/swift-gesturerecognizer/actions/workflows/ci.yml/badge.svg)](https://github.com/halilozel1903/swift-gesturerecognizer/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An interactive UIKit sample that demonstrates standard and custom `UIGestureRecognizer` APIs on a single profile card.
The demo is fully programmatic (no storyboards), uses Swift 6 language mode on the Swift 6.3 toolchain with
approachable concurrency, SF Symbols instead of bundled photos, and ships with a live gesture log, runtime toggles,
and unit tests for core gesture math.

## Gesture features

| Gesture | API | What it does |
| --- | --- | --- |
| Single tap | `UITapGestureRecognizer` | Advances to the next profile |
| Double tap | `UITapGestureRecognizer` (`numberOfTapsRequired = 2`) | Resets transform and profile layout |
| Long press | `UILongPressGestureRecognizer` | Dims the card while held, resets on release |
| Swipe left / right | `UISwipeGestureRecognizer` | Browses profiles forward / backward |
| Pan | `UIPanGestureRecognizer` | Drags the card; release applies deceleration + spring |
| Pinch | `UIPinchGestureRecognizer` | Scales the card between 0.6× and 2.5× |
| Rotation | `UIRotationGestureRecognizer` | Rotates the card and reports degrees |
| Screen edge pan | `UIScreenEdgePanGestureRecognizer` | Swipe from the left edge to open settings |
| Hover / pointer | `UIHoverGestureRecognizer` | Highlights the card when a pointer is over it (iPad / trackpad) |
| Circle stroke | `CircleStrokeGestureRecognizer` (custom) | Detects a closed circular path drawn on the card |
| Context menu | `UIContextMenuInteraction` | Quick actions: next profile, reset, clear log |

### Recognizer relationships

| Dependent | Waits for | Why |
| --- | --- | --- |
| Single tap | Double tap | `require(toFail:)` avoids stealing double taps |
| Pan | Swipe left / right | Keeps quick flicks separate from slow drags |
| Screen edge pan | Card pan | Edge drawer opens only when the card is not being dragged |

Pan, pinch, and rotation run simultaneously via `UIGestureRecognizerDelegate` because they compose a single
`CGAffineTransform`. A scrolling **Gesture log** panel records recognizer state transitions, and **Settings**
lets you disable individual recognizers at runtime (`isEnabled`).

## Requirements

| Tool | Version |
| --- | --- |
| Xcode | 26.6 or later (stable; Xcode 27 is preview-only on GitHub runners as of Oct 2026) |
| Swift | 6 language mode on the Swift 6.3 toolchain (`SWIFT_VERSION = 6.0`) |
| Concurrency | Approachable concurrency + `MainActor` default isolation in the app; hostless tests stay `nonisolated` |
| iOS deployment target | 26.0 or later |
| Devices | iPhone and iPad |
| CI | GitHub Actions `macos-26` with Xcode 26.6 (Swift 6.3.3) |

iOS 27 / Xcode 27 are available only as a public preview on GitHub-hosted runners as of October 2026, so this project
stays on the newest stable pair (iOS 26 + Xcode 26.6 / Swift 6.3).

## Getting started

```bash
git clone https://github.com/halilozel1903/swift-gesturerecognizer.git
cd swift-gesturerecognizer
open GestureRecognizer.xcodeproj
```

Select the **GestureRecognizer** scheme, choose an iOS simulator, and press **⌘R**.

### Command-line build & test

```bash
# Resolve an available iPhone simulator (prefer iOS 26 + iPhone 17)
udid="$(
  xcrun simctl list devices available -j |
  python3 -c '
import json, sys
data = json.load(sys.stdin)

def collect(runtime_substr):
    return [
        device
        for runtime, rows in data.get("devices", {}).items() if runtime_substr in runtime
        for device in rows
        if device.get("isAvailable") and "iPhone" in device.get("name", "")
    ]

devices = collect("iOS-26") or collect("iOS")
preferred = next((d for d in devices if d["name"].startswith("iPhone 17")), devices[-1])
print(preferred["udid"])
'
)"

# Build
xcodebuild build \
  -project GestureRecognizer.xcodeproj \
  -scheme GestureRecognizer \
  -destination "id=${udid}" \
  CODE_SIGN_IDENTITY=- \
  AD_HOC_CODE_SIGNING_ALLOWED=YES

# Unit tests (Swift Testing, hostless logic target)
xcodebuild test \
  -project GestureRecognizer.xcodeproj \
  -scheme GestureRecognizer \
  -destination "id=${udid}" \
  CODE_SIGN_IDENTITY=- \
  AD_HOC_CODE_SIGNING_ALLOWED=YES
```

### Lint

Requires [SwiftLint](https://github.com/realm/SwiftLint):

```bash
swiftlint lint --strict
```

## Project structure

```
swift-gesturerecognizer/
├── GestureRecognizer.xcodeproj/
│   └── xcshareddata/xcschemes/GestureRecognizer.xcscheme
├── GestureRecognizer/
│   ├── App/                         # @main, scene setup
│   ├── Controllers/                 # Playground + settings screens
│   ├── Gestures/                    # Custom recognizer, pan physics, circle detection
│   ├── Models/                      # Profile, log entries, recognizer catalog
│   ├── Services/                    # Log store, settings, state logging helper
│   ├── Views/                       # Card, log panel, dependency summary
│   └── Assets.xcassets/
├── GestureRecognizerTests/          # Swift Testing unit tests
├── .github/workflows/ci.yml         # macos-26 + Xcode 26.6 / Swift 6.3 build, test, SwiftLint
├── .swiftlint.yml
└── .swift-format
```

`Info.plist` is generated from build settings. The app target uses an Xcode synchronized root folder, so new Swift
files under `GestureRecognizer/` are picked up automatically. The project builds with Swift 6 language mode,
Swift 6.3 toolchain defaults (`SWIFT_APPROACHABLE_CONCURRENCY`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` in
the app), and complete strict concurrency checking. Shared gesture math stays `nonisolated` so hostless unit tests
can run off the main actor.

## Screenshots

No checked-in PNG/GIF assets yet. Run the app in the iPhone or iPad simulator and capture the card, gesture log,
and settings screen for documentation updates.

## Roadmap

- [ ] Recorded simulator GIFs in `README` / docs
- [ ] Additional custom recognizers (letter shapes, multi-finger taps)
- [ ] SwiftUI wrapper for comparison with UIKit recognizers
- [ ] Localized strings via String Catalog

## Contributing

Contributions are welcome.

1. Fork the repo and create a branch (`feature/my-improvement`).
2. Keep commits small with conventional subjects (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).
3. Ensure `xcodebuild build`, `xcodebuild test`, and `swiftlint lint --strict` pass.
4. Open a pull request describing the change and how you verified it.

## License

MIT — see [LICENSE](LICENSE).
