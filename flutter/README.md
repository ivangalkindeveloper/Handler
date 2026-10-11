# bloc_handler

Use `BlocHandlerMixin` to handle operation errors inside BLoC event handlers, emit categorized error states, optionally restore an earlier state, and run a cleanup callback.

[Platform comparison](../README.md).

## Installation

Requires Dart 3.8.1+ and `bloc` 9.x. The library uses Dart and BLoC APIs and has no Flutter SDK dependency.

To consume this implementation from the shared repository:

```yaml
dependencies:
  bloc_handler:
    git:
      url: https://github.com/ivangalkindeveloper/Handler.git
      ref: master
      path: flutter
```

For a local checkout, use an absolute or relative path to `Handler/flutter`:

```yaml
dependencies:
  bloc_handler:
    path: /absolute/path/to/Handler/flutter
```

Run `flutter pub get` in a Flutter application, or `dart pub get` in a Dart application.

## BLoC usage

The mixin's last two type arguments are the types of thrown errors, not state types. Define the states emitted for those errors separately:

```dart
import 'package:bloc/bloc.dart';
import 'package:bloc_handler/bloc_handler.dart';

class ApiException implements Exception {}
class ConnectionException implements Exception {}
class LoadProfile {}

sealed class ProfileState {}
class Idle extends ProfileState {}
class Loading extends ProfileState {}
class Loaded extends ProfileState {
  Loaded(this.name);
  final String name;
}
class ApiFailed extends ProfileState {}
class ConnectionFailed extends ProfileState {}
class UnknownFailed extends ProfileState {}

class ProfileBloc extends Bloc<LoadProfile, ProfileState>
    with BlocHandlerMixin<LoadProfile, ProfileState,
        ApiException, ConnectionException> {
  ProfileBloc(this.loadName) : super(Idle()) {
    on<LoadProfile>((event, emit) => handle(emit, () async {
      emit(Loading());
      final name = await loadName();
      emit(Loaded(name));
    }));
  }

  final Future<String> Function() loadName;

  @override
  ProfileState get defaultApiErrorState => ApiFailed();
  @override
  ProfileState get defaultConnectionErrorState => ConnectionFailed();
  @override
  ProfileState get defaultUnknownErrorState => UnknownFailed();
}
```

`execute` can be synchronous or asynchronous and returns no result. Emit success states inside that operation. Await or return the `handle` future from the event handler so its emitter remains active until the work finishes.

## Error states and callbacks

| Parameter / getter | Behavior |
|---|---|
| `defaultApiErrorState` | Default state for the configured API error type |
| `defaultConnectionErrorState` | Default state for the configured connection error type |
| `defaultUnknownErrorState` | Default state for other errors |
| `getApiErrorState` | Per-operation API error state factory |
| `getConnectionErrorState` | Per-operation connection error state factory |
| `getUnknownErrorState` | Per-operation unknown error state factory |
| `onError` | Receives the error and stack trace before classification |
| `onFinally` | Runs after error and fallback emissions |
| `fallback` | Enables restoration of the state captured before execution |
| `getFallbackState` | Overrides the captured fallback state on an error |

The default getters return `null`, so no error state is emitted unless you supply one. A factory returning `null` falls back to its default getter. API error handling takes precedence over connection error handling when both types match.

Errors are also passed to BLoC's `onError`, allowing a `BlocObserver` to record them globally. The error state, if present, is emitted in `finally`, followed by fallback when enabled, then `onFinally`.

In the current implementation, `fallback: true` restores the captured state after both successful and failed execution. Use it only when that final restoration is intended. The mixin exposes no cancellation handle; application work must manage its own cancellation or disposal.

## Examples and checks

Run from this directory:

```sh
dart pub get
dart analyze
dart test
```

The [example](example/README.md) contains a profile BLoC, event and state definitions, and a repository interface. It is a source example rather than a runnable Flutter application.
