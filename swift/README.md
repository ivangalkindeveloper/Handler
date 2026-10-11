# Handler
Handler for throws closures, uses in Presenter, ViewModel or Controller.\
Has an extended API closures that are triggered by successful and unsuccessful processing of the main closure.\
The handler internally creates a Task, which is saved in a local variable, but also gives a reference to it to the main function of starting the processing.

# Installation
## CocoaPods
For projects with [CocoaPods](https://cocoapods.org):
```ruby
pod 'Handler'
```
## Carthage
For projects with [Carthage](https://github.com/Carthage/Carthage):
```
github "ivangalkindeveloper/Handler"
```
## Swift Package Manager
For projects with [Swift Package Manager](https://github.com/apple/swift-package-manager):
```
dependencies: [
    .package(url: "https://github.com/ivangalkindeveloper/Handler.git", from: "master")
]
```

# Usage
Easy to use when interacting with remote data sources:
```swift
protocol HttpError: Error {}
final class HttpApiError: HttpError {}
final class HttpConnectionError: HttpError {}

final class MyViewModel: Handler<HttpApiError, HttpConnectionError>  {
    private let view = ProfileView()
    private let repository = ProfileRepository()
    
    func fetchProfile() {
        self.handle(
            {
                self.repository.getProfile()
            },
            onMainSuccess: { profile in
                self.view.showProfile(profile)
            },
            onMainError: { error in
                self.view.showError()
            }
        )
    }
}
```

# API
```priority``` - task execution priority;\
```onDefer``` - callback triggered in the defer section;\
```onSuccess``` / ```onMainSuccess``` - callback triggered ass success result of execution;\
```onApiError``` / ```onMainApiError``` - callback triggered when ApiError type match;\
```onConnectionError``` / ```onMainConnectionError``` - callback triggered when ConnectionError match;\
```onUnknownError``` / ```onMainUnknownError``` - callback triggered when an unknown error occurs.\
Methods that contains 'Main' in their name work within the MainActor.

# HandlerObserver
HandlerObserver - a class with a static field onError, which is called inside the handle to notify globally about errors.
This is useful for centralizing all errors to error analytics.
```swift
HandlerObserver.onError = { error in
    MyCrushlytics.sendError(error)
}
```

# Additional information
For more details see example project.\
And feel free to open an issue if you find any bugs or errors or suggestions.
