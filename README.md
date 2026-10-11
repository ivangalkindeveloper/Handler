# Handler

Handler запускает асинхронные операции, передаёт результаты в callbacks и разделяет ошибки на API, соединение и неизвестные. Подходит для Presenter, ViewModel и Controller; поддерживает callbacks на главном потоке, `onDefer`, глобальный `HandlerObserver` и отмену последней задачи.

В одном репозитории находятся самостоятельные реализации для Apple-платформ и Android:

| | Swift | Kotlin |
|---|---|---|
| Исходники и документация | [swift/](swift/) · [Swift README](swift/README.md) | [kotlin/](kotlin/) · [Kotlin README](kotlin/README.md) |
| Платформы | iOS 13+, macOS 10.15+ | JVM; Android с Kotlin Coroutines |
| Инструменты сборки | Swift 6.1+, Swift Package Manager | JDK 17, Gradle Wrapper |
| Модуль / namespace | `Handler` | `io.ivangalkindeveloper.handler` |
| Асинхронная задача | `Task<Void, Never>` | `Job` в переданном `CoroutineScope` |
| Главный поток | `MainActor` | `Dispatchers.Main.immediate` |
| Настройка выполнения | `TaskPriority` | `CoroutineDispatcher` |

Общий контракт сохраняется: классификация ошибок, callbacks результата и ошибки, observer, `lastTask` и `cancelLastTask()`. В Kotlin scope определяет время жизни задач; для Android обычно передают `viewModelScope` или `lifecycleScope`. Dispatcher выбирает контекст выполнения и не является аналогом приоритета ОС. Kotlin-реализация передаёт отмену через `CancellationException`, не вызывая callbacks ошибок и observer; Swift-реализация обрабатывает выброшенную ошибку отмены через обычную классификацию ошибок.

## Swift

Подключение через Swift Package Manager использует существующий URL репозитория:

```swift
.package(
    url: "https://github.com/ivangalkindeveloper/Handler.git",
    branch: "master"
)
```

Корневой `Package.swift` указывает на `swift/Sources` и `swift/Tests`, поэтому пакет можно подключить по URL или открыть корень в Xcode. В `swift/` сохранён самостоятельный Swift-пакет с собственным манифестом.

```sh
swift test
# Либо непосредственно Swift-реализацию:
swift test --package-path swift
```

Примеры использования и описание API — в [swift/README.md](swift/README.md).

## Kotlin / Android

Откройте `kotlin/` в Android Studio или выполните из корня репозитория:

```sh
cd kotlin
./gradlew test publishToMavenLocal
```

После локальной публикации добавьте `mavenLocal()` в repositories Android-проекта и зависимость:

```kotlin
implementation("io.ivangalkindeveloper:handler:1.0.0")
```

Исходники также можно подключить из `settings.gradle.kts` приложения через `includeBuild("/absolute/path/to/Handler/kotlin")`, сохранив ту же строку зависимости. Настройка scope, dispatchers, порядок callbacks и примеры — в [kotlin/README.md](kotlin/README.md). Публикация в удалённый Maven-репозиторий настраивается отдельно.

## Структура и проверки

- `swift/` — Swift Package, исходники, тесты и документация Apple-реализации.
- `kotlin/` — Gradle-проект, JVM-библиотека, тесты и документация Android-реализации.
- `Package.swift` — вход для Swift Package Manager из корня репозитория.
- `.github/` — общие GitHub Actions; Kotlin-команды выполняются в `kotlin/`.

Реализации собираются независимо. История Swift и история Kotlin сохранены в общем Git-репозитории; существующие Swift-теги продолжают указывать на прежние версии.
