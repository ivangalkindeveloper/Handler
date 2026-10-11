import 'package:bloc/bloc.dart';
import 'package:bloc_handler/bloc_handler.dart';
import 'package:example/profile.dart';
import 'package:example/repository.dart';

part 'event.dart';
part 'state.dart';

class ProfileBloc extends Bloc<Event, State>
    with BlocHandlerMixin<Event, State, ApiErrorState, ConnectionErrorState> {
  ProfileBloc({required Repository repository})
    : _repository = repository,
      super(const LoadingState()) {
    on<Event>(
      (event, emit) => switch (event) {
        SomeEvent() => _getProfile(event, emit),
      },
    );
  }

  final Repository _repository;

  @override
  State get defaultApiErrorState => const ApiErrorState();
  @override
  State get defaultConnectionErrorState => const ConnectionErrorState();
  @override
  State get defaultUnknownErrorState => const UnknownErrorState();

  Future<void> _getProfile(Event event, Emitter<State> emit) =>
      handle(emit, () async {
        final profile = await _repository.getProfile();
        emit(SuccessState(profile: profile));
      });
}
