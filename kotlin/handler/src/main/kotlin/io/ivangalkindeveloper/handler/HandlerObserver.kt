package io.ivangalkindeveloper.handler

/** Global error hook, intended for analytics. Called before per-operation error callbacks. */
object HandlerObserver {
    @Volatile
    var onError: VoidErrorCallback? = null
}
