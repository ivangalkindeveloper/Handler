sealed class HttpError implements Exception {
  const HttpError();
}

final class ApiError extends HttpError {
  const ApiError();
}

final class ConnectionError extends HttpError {
  const ConnectionError();
}
