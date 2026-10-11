package io.github.ivangalkindeveloper.handler

import kotlin.reflect.KClass
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Runs work in the supplied lifecycle scope and dispatches errors by runtime type.
 * Owns no scope: cancelling the caller's scope also cancels every operation.
 */
open class Handler<ApiError : Throwable, ConnectionError : Throwable>(
    private val scope: CoroutineScope,
    private val apiErrorType: KClass<ApiError>,
    private val connectionErrorType: KClass<ConnectionError>,
    private val executionDispatcher: CoroutineDispatcher = Dispatchers.Default,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main.immediate,
) : HandlerProtocol<ApiError, ConnectionError> {
    private val taskLock = Any()

    @Volatile
    final override var lastTask: Job? = null
        private set

    override val isLastTaskCancelled: Boolean?
        get() = lastTask?.isCancelled

    override fun <T> handle(
        execute: suspend () -> T,
        dispatcher: CoroutineDispatcher?,
        onDefer: (() -> Unit)?,
        onSuccess: ResultErrorCallback<T>?,
        onMainSuccess: ResultErrorCallback<T>?,
        onApiError: VoidErrorCallback?,
        onMainApiError: VoidErrorCallback?,
        onConnectionError: VoidErrorCallback?,
        onMainConnectionError: VoidErrorCallback?,
        onUnknownError: VoidErrorCallback?,
        onMainUnknownError: VoidErrorCallback?,
    ): Job {
        // Lazy start ensures the job is visible in lastTask before any callback executes.
        val task = scope.launch(dispatcher ?: executionDispatcher, start = CoroutineStart.LAZY) {
            try {
                try {
                    val result = execute()
                    ensureActive()
                    onSuccess?.invoke(result)
                    if (onMainSuccess != null) {
                        withContext(mainDispatcher) { onMainSuccess(result) }
                    }
                } finally {
                    // Swift's defer runs before its catch block, and after success callbacks.
                    onDefer?.invoke()
                }
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (error: Exception) {
                ensureActive()
                val (on, onMain) = when {
                    apiErrorType.isInstance(error) -> onApiError to onMainApiError
                    connectionErrorType.isInstance(error) -> onConnectionError to onMainConnectionError
                    else -> onUnknownError to onMainUnknownError
                }
                HandlerObserver.onError?.invoke(error)
                on?.invoke(error)
                if (onMain != null) {
                    withContext(mainDispatcher) { onMain(error) }
                }
            }
        }
        synchronized(taskLock) { lastTask = task }
        task.start()
        return task
    }

    override fun cancelLastTask() {
        synchronized(taskLock) {
            lastTask?.cancel()
            lastTask = null
        }
    }
}

/** Type tokens are required on the JVM because generic exception types are erased. */
inline fun <reified A : Throwable, reified C : Throwable> handler(
    scope: CoroutineScope,
    executionDispatcher: CoroutineDispatcher = Dispatchers.Default,
    mainDispatcher: CoroutineDispatcher = Dispatchers.Main.immediate,
): Handler<A, C> = Handler(scope, A::class, C::class, executionDispatcher, mainDispatcher)
