import 'package:test/test.dart';

import 'test_bloc.dart';
import 'test_blocs.dart';

void main() {
  group('Api Error tests', () {
    test('Api Error Test', () {
      final TestBloc bloc = TestBloc1();
      bloc.add(const TestEvent());
      expectLater(bloc.stream, emitsInOrder([const ApiErrorState()]));
    });

    test('Another Api Error Test', () {
      final TestBloc bloc = TestBloc2();
      bloc.add(const TestEvent());
      expectLater(bloc.stream, emitsInOrder([const AnotherApiErrorState()]));
    });
  });

  group('Connection Error tests', () {
    test('Connection Error Test', () {
      final TestBloc bloc = TestBloc3();
      bloc.add(const TestEvent());
      expectLater(bloc.stream, emitsInOrder([const ConnectionErrorState()]));
    });

    test('Another Connection Error Test', () {
      final TestBloc bloc = TestBloc4();
      bloc.add(const TestEvent());
      expectLater(
        bloc.stream,
        emitsInOrder([const AnotherConnectionErrorState()]),
      );
    });
  });

  group('Unknown Error tests', () {
    test('Unknown Error Test', () {
      final TestBloc bloc = TestBloc5();
      bloc.add(const TestEvent());
      expectLater(bloc.stream, emitsInOrder([const UnknownErrorState()]));
    });

    test('Another Unknown Error Test', () {
      final TestBloc bloc = TestBloc6();
      bloc.add(const TestEvent());
      expectLater(
        bloc.stream,
        emitsInOrder([const AnotherUnknownErrorState()]),
      );
    });
  });

  group('Fallback Error tests', () {
    test('Fallback Error Test', () {
      final TestBloc bloc = TestBloc7();
      bloc.add(const TestEvent());
      expectLater(
        bloc.stream,
        emitsInOrder([const UnknownErrorState(), const TestState()]),
      );
      expect(bloc.state, isA<TestState>());
    });
  });
}
