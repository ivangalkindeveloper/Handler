# Changelog

## 2.0.0

This major release brings Swift, Kotlin / Android, and Flutter / BLoC implementations into the existing Handler repository. The repository layout and installation references change; each platform retains its own API and execution model.

### Changes

- Move the Swift implementation, tests, and usage guide into `swift/`.
- Add the Kotlin coroutine implementation in `kotlin/`, using the `io.ivangalkindeveloper.handler` namespace.
- Add the `bloc_handler` implementation and example in `flutter/`, without importing its separate Git repository or history.
- Retain the root `Package.swift` so existing Swift Package Manager repository URLs continue to resolve.
- Align the Swift release tag, Kotlin library version, BLoC package version, and example version at `2.0.0`.
- Provide English usage guides for each implementation and a root README focused on platform differences.
- Add GitHub Actions checks for Swift and Kotlin.

### Migration

- Swift: keep the existing repository URL and use `.package(url: "https://github.com/ivangalkindeveloper/Handler.git", from: "2.0.0")`. Direct source and local package paths now use `swift/`.
- Kotlin: open or include `kotlin/`, import `io.ivangalkindeveloper.handler`, and use `io.ivangalkindeveloper:handler:2.0.0` after publishing to Maven Local.
- Flutter / Dart: use the Handler Git repository with `ref: v2.0.0` and `path: flutter`. The Dart package name remains `bloc_handler`.
- Consult [Swift usage](swift/README.md), [Kotlin usage](kotlin/README.md), or [BLoC usage](flutter/README.md) for installation and callbacks.

### Validation

- Swift package build and tests passed.
- Kotlin tests and Maven Local publication passed.
- BLoC static analysis and all 7 tests passed.

This is a GitHub source release. Maven Central and pub.dev publication are separate distribution steps. Platform APIs and cancellation behavior remain different; see the [platform comparison](README.md).
