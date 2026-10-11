# Handler для Kotlin / Android

Эта реализация находится в общем репозитории Handler. [Обзор проекта и Swift-версия](../README.md). Все команды ниже выполняются из каталога `kotlin/`; открывайте его в Android Studio.

Порт Swift-пакета `Handler`: асинхронная операция, callback результата, классификация ошибок, callbacks на главном потоке, `onDefer`, глобальный `HandlerObserver`, ссылка на последнюю задачу и её отмена. Библиотека поставляется как JVM JAR и работает в Android с Kotlin Coroutines.

## Сборка и подключение

Требуется JDK 17. Gradle Wrapper включён в репозиторий. Используются Kotlin 2.2.21 и Coroutines 1.10.2; байткод совместим с Java 8. Проверка и публикация в локальный Maven:

```sh
./gradlew test publishToMavenLocal
```

В `settings.gradle.kts` Android-проекта добавьте `mavenLocal()` в `dependencyResolutionManagement.repositories`, сохранив `google()` и `mavenCentral()`. Затем:

```kotlin
dependencies {
    implementation("io.ivangalkindeveloper:handler:1.0.0")
    // Если viewModelScope ещё не подключён:
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.9.4")
}
```

Можно подключить исходники через `includeBuild("/absolute/path/to/Handler/kotlin")` в settings вместо локальной публикации; строка зависимости остаётся той же.

## Использование в ViewModel

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

Для Compose состояние результата можно хранить в `mutableStateOf`, для остальных экранов — в `StateFlow`. `Handler` не навязывает способ хранения состояния.

Наследование тоже поддерживается: `class MyHandler(scope: CoroutineScope) : Handler<HttpApiError, HttpConnectionError>(scope, HttpApiError::class, HttpConnectionError::class)`. Фабрика `handler<HttpApiError, HttpConnectionError>(scope)` позволяет не передавать `KClass` вручную.

## API и порядок callbacks

| Swift | Kotlin |
|---|---|
| `Task<Void, Never>` | `Job`, возвращаемый `handle` |
| `TaskPriority` | `dispatcher` для конкретной операции |
| `MainActor.run` | `withContext(mainDispatcher)` |
| `lastTask`, `isLastTaskCancelled`, `cancelLastTask` | Те же имена |
| `ResultErrorCallback`, `VoidErrorCollback` | Сохранены; также есть исправленное имя `VoidErrorCallback` |

Успех: `execute → onSuccess → onMainSuccess → onDefer`.

Ошибка: `execute → onDefer → HandlerObserver.onError → onApiError/onConnectionError/onUnknownError → соответствующий onMain...`. Подклассы ошибок распознаются; при пересечении типов приоритет у API-ошибки, как в Swift. Callback ошибки получает исходный `Throwable`.

```kotlin
HandlerObserver.onError = { error -> analytics.record(error) }
// Удаление глобального обработчика:
HandlerObserver.onError = null
```

`execute`, обычные callbacks, observer и `onDefer` выполняются на `executionDispatcher` (`Dispatchers.Default` по умолчанию), а `onMain...` — на `Dispatchers.Main.immediate`. Для блокирующего IO передайте `dispatcher = Dispatchers.IO`. У Kotlin Coroutines нет прямого аналога приоритета Swift Task; dispatcher выбирает место выполнения, а не приоритет ОС. Dispatcher главного потока можно подменить при тестировании.

Scope задаёт время жизни всех задач. Новая операция не отменяет предыдущую. `cancelLastTask()` отменяет только последнюю и очищает ссылку; после этого `isLastTaskCancelled == null`. Можно отменить возвращённый `Job` напрямую — тогда ссылка остаётся и свойство показывает `true`.

Отмена кооперативная: suspend-функции должны соблюдать cancellation. `CancellationException` пробрасывается, не уведомляет observer и не вызывает callbacks ошибок. `onDefer` вызывается для начавшейся операции, в том числе при отмене. Если scope уже отменён и тело задачи не запускалось, `onDefer` не вызывается. Фатальные JVM `Error` не преобразуются в ошибки приложения. Callbacks и observer должны завершаться без исключений; исключения из обработчиков ошибок поступают в переданный scope.

## Проверки

Тесты проверяют порядок callbacks, три категории ошибок, подклассы и пересечение типов, фактический поток `onMainSuccess`, отмену и независимость одновременно выполняемых задач. CI выполняет сборку и тесты через GitHub Actions.

## Репозиторий и публикация

Swift- и Kotlin-реализации размещаются в одном репозитории; Git-команды выполняйте из его корня. Общие GitHub Actions находятся в `../.github/`.

Maven-публикации настроены для `publishToMavenLocal`. Адрес и credentials удалённого Maven-репозитория настраиваются отдельно.
