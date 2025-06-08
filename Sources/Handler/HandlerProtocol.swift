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
}
