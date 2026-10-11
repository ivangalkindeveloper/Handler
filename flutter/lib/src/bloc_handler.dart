import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_handler/bloc_handler.dart';

/// A mixin that provides error handling capabilities for BLoC classes.
///
/// This mixin extends the functionality of [Bloc] by adding robust error handling
/// mechanisms for different types of errors that might occur during bloc operations.
///
/// Type parameters:
/// * [Event] - The type of events that this bloc handles
/// * [State] - The type of states that this bloc emits
/// * [ApiError] - The type of errors that can occur during API calls
/// * [ConnectionError] - The type of errors that can occur during network operations
///
/// Example usage:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with BlocHandlerMixin<MyEvent, MyState, ApiException, NetworkException> {
///   // Implementation
/// }
/// ```
mixin BlocHandlerMixin<
  Event,
  State,
  ApiError extends Object,
  ConnectionError extends Object
>
    on Bloc<Event, State> {
  /// The default state to emit when an API error occurs.
  ///
  /// Override this getter to provide a custom default state for API errors.
  /// Returns null by default, which means no state will be emitted.
  State? get defaultApiErrorState => null;

  /// The default state to emit when a connection error occurs.
  ///
  /// Override this getter to provide a custom default state for connection errors.
  /// Returns null by default, which means no state will be emitted.
  State? get defaultConnectionErrorState => null;

  /// The default state to emit when an unknown error occurs.
  ///
  /// Override this getter to provide a custom default state for unknown errors.
  /// Returns null by default, which means no state will be emitted.
  State? get defaultUnknownErrorState => null;

  /// Handles the execution of a function with comprehensive error handling.
  ///
  /// This method provides a structured way to handle different types of errors
  /// that might occur during the execution of bloc operations.
  ///
  /// Parameters:
  /// * [emit] - The emitter used to emit states
  /// * [execute] - The function to execute
  /// * [fallback] - Whether to fall back to the previous state on error
  /// * [onError] - Optional callback for error handling
  /// * [getApiErrorState] - Optional callback to get state for API errors
  /// * [getConnectionErrorState] - Optional callback to get state for connection errors
  /// * [getUnknownErrorState] - Optional callback to get state for unknown errors
  /// * [getFallbackState] - Optional callback to get fallback state
  /// * [onFinally] - Optional callback to execute after all operations
  ///
  /// Example usage:
  /// ```dart
  /// await handle(
  ///   emit,
  ///   () async {
  ///     // Your code here
  ///   },
  ///   onError: (error, stackTrace) {
  ///     // Handle error
  ///   },
  /// );
  /// ```
  Future<void> handle(
    Emitter<State> emit,
    FutureOr<void> Function() execute, {
    bool fallback = false,
    VoidErrorCallback? onError,
    StateErrorCallback<State, ApiError>? getApiErrorState,
    StateErrorCallback<State, ConnectionError>? getConnectionErrorState,
    StateErrorCallback<State, Object>? getUnknownErrorState,
    StateErrorCallback<State, Object>? getFallbackState,
    void Function()? onFinally,
  }) async {
    State currentState = state;
    State? errorState;

    try {
      try {
        await execute();
      } catch (error, stackTrace) {
        onError?.call(error, stackTrace);
        if (fallback) {
          currentState =
              getFallbackState?.call(error, stackTrace) ?? currentState;
        }
        super.onError(error, stackTrace);
        rethrow;
      }
    } on ApiError catch (error, stackTrace) {
      errorState =
          getApiErrorState?.call(error, stackTrace) ?? defaultApiErrorState;
    } on ConnectionError catch (error, stackTrace) {
      errorState =
          getConnectionErrorState?.call(error, stackTrace) ??
          defaultConnectionErrorState;
    } on Object catch (error, stackTrace) {
      errorState =
          getUnknownErrorState?.call(error, stackTrace) ??
          defaultUnknownErrorState;
    } finally {
      if (errorState != null) {
        emit(errorState);
      }
      if (fallback) {
        emit(currentState);
      }
      onFinally?.call();
    }
  }
}
