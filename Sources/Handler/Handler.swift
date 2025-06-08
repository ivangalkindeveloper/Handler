// The Swift Programming Language
// https://docs.swift.org/swift-book

// MARK: - Class

public final class Handler<ApiError: Error, ConnectionError: Error>: HandlerProtocol {
    public var lastTask: Task<Void, Never>?
}

// MARK: - Public methods

public extension Handler {
    func handle<T: Sendable>(
        _ execute: @escaping () async throws -> T,
        priority: TaskPriority? = nil,
        onDefer: (() -> Void)? = nil,
        onSuccess: ResultErrorCallback<T>? = nil,
        onMainSuccess: ResultErrorCallback<T>? = nil,
        onApiError: VoidErrorCollback? = nil,
        onMainApiError: VoidErrorCollback? = nil,
        onConnectionError: VoidErrorCollback? = nil,
        onMainConnectionError: VoidErrorCollback? = nil,
        onUnknownError: VoidErrorCollback? = nil,
        onMainUnknownError: VoidErrorCollback? = nil,
    ) -> Task<Void, Never>? {
        let task = Task(
            priority: priority
        ) {
            do {
                defer {
                    onDefer?()
                }

                let result: T = try await execute()
                onSuccess?(result)
                await MainActor.run {
                    onMainSuccess?(result)
                }
            } catch let error as ApiError {
                await self.handleError(
                    onApiError,
                    onMainApiError,
                    error
                )
            } catch let error as ConnectionError {
                await self.handleError(
                    onConnectionError,
                    onMainConnectionError,
                    error
                )
            } catch {
                await self.handleError(
                    onUnknownError,
                    onMainUnknownError,
                    error
                )
            }
        }

        self.lastTask = task
        return task
    }

    var isLastTaskCancelled: Bool? {
        self.lastTask?.isCancelled
    }

    func cancelLastTask() {
        self.lastTask?.cancel()
        self.lastTask = nil
    }
}

// MARK: - Private methods

private extension Handler {
    func handleError(
        _ on: VoidErrorCollback?,
        _ onMain: VoidErrorCollback?,
        _ error: any Error
    ) async {
        HandlerObserver.onError?(error)
        on?(error)
        await MainActor.run {
            onMain?(error)
        }
    }
}
