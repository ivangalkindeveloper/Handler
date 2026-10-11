part of 'bloc.dart';

sealed class State {
  const State();
}

final class LoadingState extends State {
  const LoadingState();
}

final class SuccessState extends State {
  const SuccessState({required this.profile});

  final Profile profile;
}

final class ApiErrorState extends State {
  const ApiErrorState();
}

final class ConnectionErrorState extends State {
  const ConnectionErrorState();
}

final class UnknownErrorState extends State {
  const UnknownErrorState();
}
