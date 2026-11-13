import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/legal_links_text.dart';
import '../providers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _aceitou = false;
  bool _aceiteFaltando = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _errorMessage(BuildContext context, Object? error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' => l10n.registerErrorEmailInUse,
        'invalid-email' => l10n.emailInvalid,
        'weak-password' => l10n.passwordTooShort,
        'network-request-failed' => l10n.errorNetwork,
        _ => l10n.registerErrorGeneric,
      };
    }
    return l10n.errorUnexpected;
  }

  Future<void> _register() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _aceiteFaltando = !_aceitou);
    if (!formOk || !_aceitou) return;
    await ref.read(authControllerProvider.notifier).registerWithEmail(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(authControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(_errorMessage(context, state.error)),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/auth/login')),
        title: Text(l10n.registerTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.registerIntro,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Campo nome (é o que os outros membros da casa veem)
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      maxLength: 40,
                      decoration: InputDecoration(
                        labelText: l10n.displayNameLabel,
                        helperText: l10n.displayNameHelper,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.displayNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Campo e-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.emailRequired;
                        }
                        if (!v.contains('@')) return l10n.emailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Campo senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.passwordRequiredRegister;
                        if (v.length < 6) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Campo confirmar senha
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                      decoration: InputDecoration(
                        labelText: l10n.confirmPasswordLabel,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.confirmPasswordRequired;
                        }
                        if (v != _passwordController.text) {
                          return l10n.passwordsDontMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Aceite dos Termos de uso e da Política de privacidade
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _aceitou,
                          onChanged: isLoading
                              ? null
                              : (v) => setState(() {
                                    _aceitou = v ?? false;
                                    if (_aceitou) _aceiteFaltando = false;
                                  }),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: LegalLinksText(prefix: l10n.legalAcceptRegister),
                          ),
                        ),
                      ],
                    ),
                    if (_aceiteFaltando)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 2),
                        child: Text(
                          l10n.legalAcceptRequired,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),

                    // Botão criar conta
                    FilledButton(
                      onPressed: isLoading ? null : _register,
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(l10n.registerTitle),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Link voltar ao login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.haveAccountPrompt,
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => context.go('/auth/login'),
                          child: Text(
                            l10n.loginButton,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
