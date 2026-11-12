import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

/// Shows a snackbar whenever the given controller ends in an error, so write
/// failures (e.g. `permission-denied`, offline) never fail silently.
///
/// Call it from `build`, like any `ref.listen`.
void escutarErroDoControlador(
  BuildContext context,
  WidgetRef ref,
  ProviderListenable<AsyncValue<void>> controller,
) {
  ref.listen<AsyncValue<void>>(controller, (_, state) {
    if (!state.hasError) return;
    final l10n = AppLocalizations.of(context)!;
    final error = state.error;
    final semConexao =
        error is FirebaseException && error.code == 'unavailable';
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(semConexao ? l10n.errorNetwork : l10n.errorUnexpected),
          behavior: SnackBarBehavior.floating,
        ),
      );
  });
}
