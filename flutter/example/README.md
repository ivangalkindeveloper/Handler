# Profile BLoC example

This directory contains a profile-loading BLoC, its event and state types, a profile model, and a repository interface. The local `bloc_handler` dependency points to the parent package.

```sh
dart pub get
dart analyze
```

There is no application entrypoint or Flutter UI in this example. Integrate the BLoC into your application and provide a repository implementation. The original example uses its error-state classes as mixin error types; use the actual thrown exception types in application code, as shown in the [package usage guide](../README.md).
