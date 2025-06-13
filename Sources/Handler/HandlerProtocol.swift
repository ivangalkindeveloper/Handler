//
//  HandlerProtocol.swift
//  Handler
//
//  Created by Иван Галкин on 08.06.2025.
//

// MARK: - Protocol

@MainActor
public protocol HandlerProtocol {
    associatedtype ApiError: Error
    associatedtype ConnectionError: Error

    var lastTask: Task<Void, Never>? { get }

    func handle<T: Sendable>(
        _ execute: @escaping () async throws -> T,
        priority: TaskPriority?,
        onDefer: (() -> Void)?,
        onSuccess: ResultErrorCallback<T>?,
        onMainSuccess: ResultErrorCallback<T>?,
        onApiError: VoidErrorCollback?,
        onMainApiError: VoidErrorCollback?,
        onConnectionError: VoidErrorCollback?,
        onMainConnectionError: VoidErrorCollback?,
        onUnknownError: VoidErrorCollback?,
        onMainUnknownError: VoidErrorCollback?,
    ) -> Task<Void, Never>?
    
    var isLastTaskCancelled: Bool? { get }

    func cancelLastTask() -> Void
}
