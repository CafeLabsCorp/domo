import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_provider.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> registerWithEmail(
    String displayName,
    String email,
    String password,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
            displayName: displayName,
            email: email,
            password: password,
          ),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}
