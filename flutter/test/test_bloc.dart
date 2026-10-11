import 'package:bloc/bloc.dart';
import 'package:bloc_handler/bloc_handler.dart';

import 'test_error.dart';

sealed class Event {
  const Event();
}

final class TestEvent extends Event {
  const TestEvent();
}

sealed class State {
  const State();
}

final class TestState extends State {
  const TestState();
}

final class ApiErrorState extends State {
  const ApiErrorState();
}

final class AnotherApiErrorState extends State {
  const AnotherApiErrorState();
}

final class ConnectionErrorState extends State {
  const ConnectionErrorState();
}

final class AnotherConnectionErrorState extends State {
  const AnotherConnectionErrorState();
}

final class UnknownErrorState extends State {
  const UnknownErrorState();
}

final class AnotherUnknownErrorState extends State {
  const AnotherUnknownErrorState();
}

base class TestBloc extends Bloc<Event, State>
    with BlocHandlerMixin<Event, State, ApiError, ConnectionError> {
  TestBloc() : super(TestState()) {
    on<Event>(request);
  }

  @override
  State? get defaultApiErrorState => const ApiErrorState();
  @override
  State? get defaultConnectionErrorState => const ConnectionErrorState();
  @override
  State? get defaultUnknownErrorState => const UnknownErrorState();

  Future<void> request(event, emit) async {}
}
