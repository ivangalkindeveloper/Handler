# Handler for Swift

Execute throwing asynchronous closures with success callbacks, categorized error callbacks, main-actor delivery, cleanup, global error reporting, and cancellation of the latest task.

[Platform comparison](../README.md).

## Installation

Requires Swift 6.1+, iOS 13+ or macOS 10.15+. Add the package using Swift Package Manager:

```swift
.package(
    url: "https://github.com/ivangalkindeveloper/Handler.git",
    branch: "master"
)
```

Add the `Handler` product to your target. The repository root supports remote package resolution; this `swift/` directory can also be opened directly as a local package.

## Usage

```swift
import Handler

struct HttpApiError: Error {}
struct HttpConnectionError: Error {}
struct Profile: Sendable { let name: String }

@MainActor
protocol ProfileRepository {
    func getProfile() async throws -> Profile
}

@MainActor
final class ProfileViewModel: Handler<HttpApiError, HttpConnectionError> {
    private let repository: any ProfileRepository
    private(set) var profile: Profile?
    private(set) var error: (any Error)?

    init(repository: any ProfileRepository) {
        self.repository = repository
        super.init()
    }

    func fetchProfile() {
        handle(
            { try await self.repository.getProfile() },
            onMainSuccess: { self.profile = $0 },
            onMainApiError: { self.error = $0 },
            onMainConnectionError: { self.error = $0 },
            onMainUnknownError: { self.error = $0 }
        )
    }
}
```

You can also create `Handler<ApiError, ConnectionError>()` directly and delegate operations to it. The handler is main-actor isolated through `HandlerProtocol`.

## Callbacks

| Parameter | Purpose |
|---|---|
| `priority` | Optional `TaskPriority` for the operation |
| `onSuccess`, `onMainSuccess` | Receive the returned value |
| `onApiError`, `onMainApiError` | Handle the configured API error type |
| `onConnectionError`, `onMainConnectionError` | Handle the configured connection error type |
| `onUnknownError`, `onMainUnknownError` | Handle all other thrown errors |
| `onDefer` | Cleanup for the executed operation |

Callbacks whose names contain `Main` are delivered through `MainActor.run`. API errors take precedence if the thrown error matches both configured types. Results must conform to `Sendable`.

Success order: `execute → onSuccess → onMainSuccess → onDefer`.

Error order: `execute → onDefer → HandlerObserver.onError → category callback → corresponding main callback`.

```swift
HandlerObserver.onError = { error in
    // Report the error to your analytics service.
}
HandlerObserver.onError = nil
```

Callbacks are nonthrowing. Avoid long-running synchronous work on the main actor.

## Task lifetime and cancellation

`handle` returns the created `Task<Void, Never>?` and stores it in `lastTask`. Starting another operation replaces the reference without cancelling the earlier task.

```swift
handler.cancelLastTask()
let cancelled = handler.isLastTaskCancelled
```

`cancelLastTask()` cancels the latest task and clears the reference. `isLastTaskCancelled` is then `nil`. Cancelling the returned task directly retains the reference.

Cancellation is cooperative: the operation must observe it. An error thrown because of cancellation follows the normal error classification. The task's failure type is `Never` because the handler catches errors from the operation.

## Checks

From this directory:

```sh
swift test
```
