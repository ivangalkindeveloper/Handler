package io.ivangalkindeveloper.handler

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Job

typealias ResultErrorCallback<T> = (T) -> Unit
typealias VoidErrorCallback = (Throwable) -> Unit
// Preserve the spelling used by the Swift API for source migration.
typealias VoidErrorCollback = VoidErrorCallback

interface HandlerProtocol<ApiError : Throwable, ConnectionError : Throwable> {
    val lastTask: Job?
    val isLastTaskCancelled: Boolean?

    fun <T> handle(
        execute: suspend () -> T,
        dispatcher: CoroutineDispatcher? = null,
        onDefer: (() -> Unit)? = null,
        onSuccess: ResultErrorCallback<T>? = null,
        onMainSuccess: ResultErrorCallback<T>? = null,
        onApiError: VoidErrorCallback? = null,
        onMainApiError: VoidErrorCallback? = null,
        onConnectionError: VoidErrorCallback? = null,
        onMainConnectionError: VoidErrorCallback? = null,
        onUnknownError: VoidErrorCallback? = null,
        onMainUnknownError: VoidErrorCallback? = null,
    ): Job

    fun cancelLastTask()
}
