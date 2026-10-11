import 'package:example/profile.dart';

abstract interface class Repository {
  const Repository();

  Future<Profile> getProfile();
}
