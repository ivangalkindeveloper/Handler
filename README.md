# Handler — platform differences

The Swift and Kotlin implementations wrap asynchronous operations and deliver results through callbacks. The Flutter/BLoC implementation integrates error handling into BLoC event handlers and emits application states.

| Aspect | Swift | Kotlin / Android | Flutter / BLoC |
|---|---|---|---|
| Implementation and usage | [swift/README.md](swift/README.md) | [kotlin/README.md](kotlin/README.md) | [flutter/README.md](flutter/README.md) |
| Package / namespace | `Handler` | `io.ivangalkindeveloper.handler` | `bloc_handler` |
| Runtime | iOS 13+, macOS 10.15+ | JVM; Android with Kotlin Coroutines | Dart applications using `bloc`, including Flutter |
| Requirements | Swift 6.1+ | JDK 17 for building; Java 8 bytecode | Dart 3.8.1+; no Flutter SDK dependency in the library |
| Integration | Class implementing `HandlerProtocol` | Class implementing `HandlerProtocol`, with a caller-provided `CoroutineScope` | `BlocHandlerMixin` on a `Bloc<Event, State>` |
| Execution | Swift `Task` and `TaskPriority` | Coroutine `Job` and configurable dispatchers | `Future<void>` inside a BLoC event handler |
| Success | `onSuccess` and `onMainSuccess` callbacks | `onSuccess` and `onMainSuccess` callbacks | The operation emits its own success state |
| Error delivery | Typed error callbacks | Typed error callbacks | Default or per-operation error states |
| Global error reporting | `HandlerObserver` | `HandlerObserver` | BLoC's `onError` / `BlocObserver` |
| Main-thread callbacks | `MainActor` | `Dispatchers.Main.immediate` by default | Normal Dart isolate execution; no separate main-thread callback API |
| Cleanup callback | `onDefer` | `onDefer` | `onFinally` |
| Task ownership | `lastTask` and explicit cancellation | Caller scope, returned `Job`, and `lastTask` | BLoC event-handler lifetime; no `lastTask` API |
| Error fallback | Application-defined callbacks | Application-defined callbacks | Optional restoration of the state captured before execution |

Swift task priority and Kotlin dispatchers have different meanings: priority influences scheduling, while a dispatcher selects the execution context. Dart futures do not expose either configuration through this mixin.

Kotlin propagates `CancellationException` without reporting it as an application error. Swift classifies an error thrown by cancellation through its normal error callbacks. The BLoC mixin does not provide operation cancellation.

The implementations have separate APIs and build systems. Installation, examples, callback ordering, and implementation-specific limitations are documented in the linked READMEs.
