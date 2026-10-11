# Handler for Kotlin / Android

Run asynchronous operations with success callbacks, categorized error callbacks, main-thread callbacks, cleanup, global error reporting, and cancellation of the latest operation. The library is a JVM JAR using Kotlin Coroutines.

[Platform comparison](../README.md). Run all commands below from this `kotlin/` directory.

## Installation

Build with JDK 17 and the included Gradle Wrapper. The project uses Kotlin 2.2.21 and Coroutines 1.10.2, with Java 8 bytecode.

```sh
./gradlew test publishToMavenLocal
```

Add `mavenLocal()` to `dependencyResolutionManagement.repositories` in your application's `settings.gradle.kts`, alongside `google()` and `mavenCentral()`:

```kotlin
dependencies {
    implementation("io.ivangalkindeveloper:handler:2.0.0")
    // Add this if viewModelScope is not already available:
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.9.4")
}
```

To consume the sources instead, add `includeBuild("/absolute/path/to/Handler/kotlin")` to the application's settings and keep the same dependency coordinate. Remote Maven publishing requires separate repository and credential configuration.

## ViewModel usage

```kotlin
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import io.ivangalkindeveloper.handler.Handler

class HttpApiError : Exception()
class HttpConnectionError : Exception()
data class Profile(val name: String)
interface ProfileRepository { suspend fun getProfile(): Profile }

class ProfileViewModel(private val repository: ProfileRepository) : ViewModel() {
    private val requests = Handler(
        scope = viewModelScope,
        apiErrorType = HttpApiError::class,
        connectionErrorType = HttpConnectionError::class,
    )

    var profile: Profile? = null
        private set
    var error: Throwable? = null
        private set

    fun fetchProfile() = requests.handle(
        execute = { repository.getProfile() },
        onMainSuccess = { profile = it },
        onMainApiError = { error = it },
        onMainConnectionError = { error = it },
        onMainUnknownError = { error = it },
    )

    fun cancelFetch() = requests.cancelLastTask()
}
```

Use `mutableStateOf` for observable Compose state or expose a `StateFlow` to your UI. Handler does not prescribe a state-storage mechanism.

Subclassing is supported:

```kotlin
class MyHandler(scope: CoroutineScope) : Handler<HttpApiError, HttpConnectionError>(
    scope, HttpApiError::class, HttpConnectionError::class
)
```

The `handler<HttpApiError, HttpConnectionError>(scope)` factory infers the error classes.

## Callbacks and dispatchers

Success order: `execute → onSuccess → onMainSuccess → onDefer`.

Error order: `execute → onDefer → HandlerObserver.onError → onApiError/onConnectionError/onUnknownError → corresponding onMain...`.

Error subclasses are recognized. When an error matches both configured types, API-error handling takes precedence. Callbacks receive the original throwable.

```kotlin
HandlerObserver.onError = { error -> analytics.record(error) }
HandlerObserver.onError = null // Remove the global observer.
```

`execute`, ordinary callbacks, the observer, and `onDefer` run on `executionDispatcher`, which defaults to `Dispatchers.Default`. The `onMain...` callbacks use `Dispatchers.Main.immediate`. Pass `dispatcher = Dispatchers.IO` to `handle` for blocking IO. Inject `mainDispatcher` when testing or using the library outside Android.

`handle` returns a `Job`. The supplied scope owns all operations; starting a new operation does not cancel the previous one. `cancelLastTask()` cancels only the latest job and clears the reference, making `isLastTaskCancelled` return `null`. Cancelling the returned job directly retains the reference, so the property returns `true`.

## Cancellation and callback failures

Cancellation is cooperative. `CancellationException` propagates without invoking the observer or error callbacks. `onDefer` runs for an operation that has started, including when it is cancelled. It does not run if a cancelled scope prevents the body from starting.

Fatal JVM `Error` instances are not converted into application errors. Callbacks and the observer should not throw; exceptions from error handlers propagate to the supplied scope.

`ResultErrorCallback`, `VoidErrorCallback`, and the legacy spelling `VoidErrorCollback` are available as callback aliases.

## Checks

```sh
./gradlew test
```

Tests cover callback ordering, error categories and subclasses, overlapping error types, main-thread delivery, cancellation, and independent concurrent operations.
