# Swift Gesture Recognizer

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![iOS](https://img.shields.io/badge/iOS-18.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-16%2B-blue.svg)](https://developer.apple.com/xcode/)
[![UIKit](https://img.shields.io/badge/UI-UIKit-informational.svg)](https://developer.apple.com/documentation/uikit)
[![CI](https://github.com/halilozel1903/swift-gesturerecognizer/actions/workflows/ci.yml/badge.svg)](https://github.com/halilozel1903/swift-gesturerecognizer/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An interactive UIKit sample that demonstrates standard and custom `UIGestureRecognizer` APIs on a single profile card.
The demo is fully programmatic (no storyboards), uses Swift 6 strict concurrency, SF Symbols instead of bundled photos,
and ships with a live gesture log, runtime toggles, and unit tests for core gesture math.

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
| Xcode | 16 or newer (`objectVersion = 77`, buildable folders) |
| Swift | 6.0 language mode, strict concurrency |
| iOS deployment target | 18.0+ |
| Devices | iPhone and iPad |

## Getting started

```bash
git clone https://github.com/halilozel1903/swift-gesturerecognizer.git
cd swift-gesturerecognizer
open GestureRecognizer.xcodeproj
```

Select the **GestureRecognizer** scheme, choose an iOS simulator, and press **⌘R**.

### Command-line build & test

```bash
# Build
xcodebuild build \
  -project GestureRecognizer.xcodeproj \
  -scheme GestureRecognizer \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO

# Unit tests (Swift Testing)
xcodebuild test \
  -project GestureRecognizer.xcodeproj \
  -scheme GestureRecognizer \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  CODE_SIGNING_ALLOWED=NO
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
├── .github/workflows/ci.yml         # macOS build, test, SwiftLint
├── .swiftlint.yml
└── .swift-format
```

`Info.plist` is generated from build settings. The app target uses an Xcode synchronized root folder, so new Swift
files under `GestureRecognizer/` are picked up automatically.

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
