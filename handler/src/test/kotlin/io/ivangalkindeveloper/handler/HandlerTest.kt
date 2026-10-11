package io.ivangalkindeveloper.handler

import kotlin.test.*
import java.util.concurrent.Executors
import kotlinx.coroutines.*
import kotlinx.coroutines.test.*
import org.junit.After
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class HandlerTest {
    open class ApiError : Exception()
    class ChildApiError : ApiError()
    class ConnectionError : Exception()

    @After fun resetObserver() { HandlerObserver.onError = null }

    @Test fun successOrderAndReturnedJob() = runTest {
        val events = mutableListOf<String>()
        val dispatcher = StandardTestDispatcher(testScheduler)
        val h = handler<ApiError, ConnectionError>(this, dispatcher, dispatcher)
        assertNull(h.lastTask)
        assertNull(h.isLastTaskCancelled)
        val job = h.handle(
            execute = { 42 },
            onSuccess = { events += "success:$it" },
            onMainSuccess = { events += "main:$it" },
            onDefer = { events += "defer" },
        )
        assertSame(job, h.lastTask)
        job.join()
        assertEquals(listOf("success:42", "main:42", "defer"), events)
        assertFalse(h.isLastTaskCancelled!!)
    }

    @Test fun routesAllErrorsAndNotifiesObserverAfterDefer() = runTest {
        val dispatcher = StandardTestDispatcher(testScheduler)
        val h = handler<ApiError, ConnectionError>(this, dispatcher, dispatcher)
        for ((error, expected) in listOf(ChildApiError() to "api", ConnectionError() to "connection", IllegalStateException() to "unknown")) {
            val events = mutableListOf<String>()
            HandlerObserver.onError = { assertSame(error, it); events += "observer" }
            h.handle<Unit>(
                execute = { throw error },
                onDefer = { events += "defer" },
                onApiError = { events += "api" }, onMainApiError = { events += "main-api" },
                onConnectionError = { events += "connection" }, onMainConnectionError = { events += "main-connection" },
                onUnknownError = { events += "unknown" }, onMainUnknownError = { events += "main-unknown" },
            ).join()
            assertEquals(listOf("defer", "observer", expected, "main-$expected"), events)
        }
    }

    @Test fun mainCallbacksUseMainDispatcher() = runBlocking {
        Executors.newSingleThreadExecutor { Thread(it, "handler-worker") }.asCoroutineDispatcher().use { worker ->
            Executors.newSingleThreadExecutor { Thread(it, "handler-main") }.asCoroutineDispatcher().use { main ->
                val h = handler<ApiError, ConnectionError>(this, worker, main)
                var successThread = ""
                var mainThread = ""
                h.handle(execute = { 1 }, onSuccess = { successThread = Thread.currentThread().name.substringBefore(" @") }, onMainSuccess = { mainThread = Thread.currentThread().name.substringBefore(" @") }).join()
                assertEquals("handler-worker", successThread)
                assertEquals("handler-main", mainThread)
            }
        }
    }

    @Test fun cancellationRunsDeferWithoutErrorCallbacks() = runTest {
        val dispatcher = StandardTestDispatcher(testScheduler)
        val h = handler<ApiError, ConnectionError>(this, dispatcher, dispatcher)
        val events = mutableListOf<String>()
        HandlerObserver.onError = { events += "error" }
        val job = h.handle(execute = { awaitCancellation() }, onDefer = { events += "defer" }, onUnknownError = { events += "unknown" })
        runCurrent()
        h.cancelLastTask()
        job.join()
        assertTrue(job.isCancelled)
        assertNull(h.lastTask)
        assertNull(h.isLastTaskCancelled)
        assertEquals(listOf("defer"), events)
    }

    @Test fun lastTaskCancellationDoesNotCancelEarlierTasks() = runTest {
        val dispatcher = StandardTestDispatcher(testScheduler)
        val h = handler<ApiError, ConnectionError>(this, dispatcher, dispatcher)
        val gate = CompletableDeferred<Unit>()
        val first = h.handle(execute = { gate.await() })
        val second = h.handle(execute = { awaitCancellation() })
        runCurrent()
        h.cancelLastTask()
        second.join()
        assertFalse(first.isCancelled)
        gate.complete(Unit)
        first.join()
    }

    @Test fun apiErrorTakesPrecedenceWhenTypesOverlap() = runTest {
        val dispatcher = StandardTestDispatcher(testScheduler)
        val h = handler<Exception, ApiError>(this, dispatcher, dispatcher)
        var route = ""
        h.handle<Unit>(execute = { throw ApiError() }, onApiError = { route = "api" }, onConnectionError = { route = "connection" }).join()
        assertEquals("api", route)
    }
}
