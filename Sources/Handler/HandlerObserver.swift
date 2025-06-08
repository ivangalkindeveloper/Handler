//
//  HandlerObserver.swift
//  Handler
//
//  Created by Иван Галкин on 08.06.2025.
//

// MARK: - Observer

public enum HandlerObserver {
    nonisolated(unsafe) static var onError: ((Error) -> Void)?
}
