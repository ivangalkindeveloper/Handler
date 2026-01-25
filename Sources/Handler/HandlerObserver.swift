// MARK: - Observer

public final class HandlerObserver {
    nonisolated(unsafe) static var onError: ((Error) -> Void)?
}
