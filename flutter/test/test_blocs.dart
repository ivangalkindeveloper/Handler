import 'package:test/test.dart';

import 'test_bloc.dart';
import 'test_error.dart';

final class TestBloc1 extends TestBloc {
  @override
  Future<void> request(event, emit) async => handle(
    emit,
    () => throw const ApiError(),
    onError: (error, stackTrace) => expect(error, isA<ApiError>()),
    onFinally: () => expect(true, true),
  );
}

final class TestBloc2 extends TestBloc {
  @override
  Future<void> request(event, emit) async => handle(
    emit,
    () => throw const ApiError(),
    onError: (error, stackTrace) => expect(error, isA<ApiError>()),
    getApiErrorState: (error, stackTrace) => const AnotherApiErrorState(),
    onFinally: () => expect(true, true),
  );
}

final class TestBloc3 extends TestBloc {
  @override
  Future<void> request(event, emit) async => handle(
    emit,
    () => throw const ConnectionError(),
    onError: (error, stackTrace) => expect(error, isA<ConnectionError>()),
    onFinally: () => expect(true, true),
  );
}

final class TestBloc4 extends TestBloc {
  @override
  Future<void> request(event, emit) async => handle(
    emit,
    () => throw const ConnectionError(),
    onError: (error, stackTrace) => expect(error, isA<ConnectionError>()),
    getConnectionErrorState: (error, stackTrace) =>
        const AnotherConnectionErrorState(),
    onFinally: () => expect(true, true),
  );
}

final class TestBloc5 extends TestBloc {
  @override
  Future<void> request(event, emit) async => handle(
    emit,
    () => throw const Object(),
    onError: (error, stackTrace) => expect(error, isA<Object>()),
    onFinally: () => expect(true, true),
  );
}

final class TestBloc6 extends TestBloc {
  @override
  Future<void> request(event, emit) async => handle(
    emit,
    () => throw const Object(),
    onError: (error, stackTrace) => expect(error, isA<ConnectionError>()),
    getUnknownErrorState: (error, stackTrace) =>
        const AnotherUnknownErrorState(),
    onFinally: () => expect(true, true),
  );
}

final class TestBloc7 extends TestBloc {
  @override
  Future<void> request(event, emit) async => handle(
    emit,
    () => throw const Object(),
    fallback: true,
    onError: (error, stackTrace) => expect(error, isA<Object>()),
    getFallbackState: (error, stackTrace) => const TestState(),
    onFinally: () => expect(true, true),
  );
}
