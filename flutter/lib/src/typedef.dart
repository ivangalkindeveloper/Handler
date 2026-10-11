/// A callback function that handles errors and stack traces.
///
/// This typedef represents a function that takes an error object and its stack trace
/// as parameters and returns void. It's commonly used for error handling scenarios
/// where you need to process an error but don't need to return any value.
typedef VoidErrorCallback = void Function(Object error, StackTrace stackTrace);

/// A callback function that handles errors and stack traces while potentially
/// returning a new state.
///
/// This typedef represents a function that takes an error object and its stack trace
/// as parameters and returns an optional State value. It's commonly used in state
/// management scenarios where you need to handle errors and potentially update
/// the state based on the error.
///
/// Type parameters:
/// * [State] - The type of state that can be returned
/// * [Error] - The type of error that can be handled
typedef StateErrorCallback<State, Error> =
    State? Function(Error error, StackTrace stackTrace);
