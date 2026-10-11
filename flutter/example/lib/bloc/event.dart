part of 'bloc.dart';

sealed class Event {
  const Event();
}

final class SomeEvent extends Event {
  const SomeEvent();
}
