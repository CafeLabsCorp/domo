import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../casa/domain/models/casa_model.dart';
import '../providers/exclusao_de_conta_provider.dart';

/// Confirms and runs account deletion. On success the auth stream emits null
/// and the router sends the user to the login screen.
class ExcluirContaDialog extends ConsumerStatefulWidget {
  const ExcluirContaDialog({
    super.key,
    required this.uid,
    required this.casa,
    required this.membrosAtivos,
  });

  final String uid;
  final CasaModel? casa;
  final int membrosAtivos;

  @override
  ConsumerState<ExcluirContaDialog> createState() => _ExcluirContaDialogState();
}

class _ExcluirContaDialogState extends ConsumerState<ExcluirContaDialog> {
  final _senhaController = TextEditingController();
  bool _carregando = false;
  String? _erro;

  bool get _google => ref.read(authRepositoryProvider).usuarioEntraComGoogle;
  bool get _podeConfirmar =>
      !_carregando && (_google || _senhaController.text.isNotEmpty);

  @override
  void dispose() {
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_podeConfirmar) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await ref.read(exclusaoDeContaServiceProvider).excluir(
            uid: widget.uid,
            senha: _senhaController.text,
          );
      if (mounted) Navigator.pop(context);
    } on ReautenticacaoCancelada {
      if (mounted) setState(() => _carregando = false);
    } on FirebaseException catch (e) {
      final msg = switch (e.code) {
        'wrong-password' || 'invalid-credential' => l10n.wrongPasswordError,
        'network-request-failed' || 'unavailable' => l10n.errorNetwork,
        _ => l10n.errorUnexpected,
      };
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = msg;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = l10n.errorUnexpected;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final casa = widget.casa;
    final souDono = casa != null && casa.criadoPor == widget.uid;

    return AlertDialog(
      title: Text(l10n.deleteAccountTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteAccountBody),
            if (casa != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                souDono
                    ? l10n.deleteAccountOwnerWarning(
                        casa.nome, widget.membrosAtivos)
                    : l10n.deleteAccountMemberInfo(casa.nome),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: souDono ? theme.colorScheme.error : null,
                  fontWeight: souDono ? FontWeight.w700 : null,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (_google)
              Text(l10n.deleteAccountGoogleHint)
            else
              TextField(
                controller: _senhaController,
                obscureText: true,
                enabled: !_carregando,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: l10n.yourPasswordLabel),
              ),
            if (_erro != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _erro!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _carregando ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _podeConfirmar ? _confirmar : null,
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: _carregando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.deleteAccountConfirm),
        ),
      ],
    );
  }
}
