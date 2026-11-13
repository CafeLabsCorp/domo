import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/repositories/auth_repository.dart';
import '../../casa/domain/repositories/casa_repository.dart';

/// Self-service account deletion (Play Store + LGPD requirement), done
/// entirely on the client (Spark plan, no Cloud Function).
///
/// Order matters: identity is re-proven FIRST so nothing is erased on a wrong
/// password; the Auth user is deleted LAST so a mid-way failure leaves an
/// account the user can still sign in to and retry (every step is idempotent).
class ExclusaoDeContaService {
  ExclusaoDeContaService({
    required AuthRepository auth,
    required CasaRepository casas,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _casas = casas,
        _db = firestore;

  final AuthRepository _auth;
  final CasaRepository _casas;
  final FirebaseFirestore _db;

  Future<void> excluir({required String uid, String? senha}) async {
    await _auth.reautenticar(senha: senha);
    await apagarDados(uid);
    await _auth.excluirUsuario();
  }

  /// Removes the user's footprint from Firestore:
  /// - houses they created are deleted for everyone (items included);
  /// - houses they only joined: they leave (name/e-mail/photo go away);
  /// - houses where they are still pendente (found via `usuarios/{uid}`);
  /// - the `usuarios/{uid}` index itself.
  Future<void> apagarDados(String uid) async {
    final indice = _db.collection('usuarios').doc(uid);

    final pendentes =
        ((await indice.get()).data()?['pendenteEm'] as List?)?.cast<String>() ??
            const <String>[];
    for (final casaId in pendentes) {
      try {
        await _casas.removerMembroAtivo(casaId: casaId, userId: uid);
      } on FirebaseException catch (e) {
        // Stale index entry: the house was deleted or the request was already
        // refused/approved, so there is nothing of ours left in it.
        if (e.code != 'not-found' && e.code != 'permission-denied') rethrow;
      }
    }

    final ativas = await _db
        .collection('casas')
        .where('membrosAtivos', arrayContains: uid)
        .get();
    for (final casa in ativas.docs) {
      if (casa.data()['criadoPor'] == uid) {
        await _casas.deletarCasa(casaId: casa.id);
      } else {
        await _casas.removerMembroAtivo(casaId: casa.id, userId: uid);
      }
    }

    await indice.delete();
  }
}
