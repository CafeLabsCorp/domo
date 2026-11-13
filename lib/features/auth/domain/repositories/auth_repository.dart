import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();

  /// True when the signed-in account uses Google (no password to type).
  bool get usuarioEntraComGoogle;

  /// Re-proves identity right before a destructive action: password for
  /// e-mail accounts, the Google flow for Google accounts. Throws
  /// [FirebaseAuthException] on a wrong password and
  /// [ReautenticacaoCancelada] if the user dismisses the Google flow.
  Future<void> reautenticar({String? senha});

  /// Deletes the Firebase Auth user, then clears the Google session.
  Future<void> excluirUsuario();
}

class ReautenticacaoCancelada implements Exception {
  const ReautenticacaoCancelada();
}
