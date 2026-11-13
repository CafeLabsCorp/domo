import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/legal/legal_links.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // The name is what other house members see; without it the app would
    // fall back to nothing personal (never the e-mail).
    final user = cred.user;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.reload();
      await _registrarAceite(user.uid);
    }
  }

  /// Records which version of the Terms / Privacy Policy the user accepted
  /// (`usuarios/{uid}.aceite`). Best effort: a failure here must never block
  /// sign-up, the screen already made the user accept explicitly.
  Future<void> _registrarAceite(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'aceite': {
          'versao': LegalLinks.termsVersion,
          'em': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final cred = await _auth.signInWithPopup(provider);
      if (cred.additionalUserInfo?.isNewUser ?? false) {
        await _registrarAceite(cred.user!.uid);
      }
      return;
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // usuário cancelou

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    if (cred.additionalUserInfo?.isNewUser ?? false) {
      await _registrarAceite(cred.user!.uid);
    }
  }

  @override
  bool get usuarioEntraComGoogle =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'google.com') ??
      false;

  @override
  Future<void> reautenticar({String? senha}) async {
    final user = _auth.currentUser!;
    if (usuarioEntraComGoogle) {
      if (kIsWeb) {
        await user.reauthenticateWithPopup(GoogleAuthProvider());
        return;
      }
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const ReautenticacaoCancelada();
      final googleAuth = await googleUser.authentication;
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );
      return;
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: senha ?? ''),
    );
  }

  @override
  Future<void> excluirUsuario() async {
    await _auth.currentUser!.delete();
    await _googleSignIn.signOut();
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
