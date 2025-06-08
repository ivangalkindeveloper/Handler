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

# API
```priority``` - 
```onDefer``` - 
```onSuccess / onMainSuccess``` - 
```onApiError / onMainApiError``` - 
```onConnectionError / onMainConnectionError``` - 
```onUnknownError / onMainUnknownError``` - 
Methods that contains 'Main' in their name work within the MainActor.

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
        handle(
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

# Additional information
For more details see example project.\
And feel free to open an issue if you find any bugs or errors or suggestions.
