import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domo/features/auth/domain/repositories/auth_repository.dart';
import 'package:domo/features/auth/presentation/pages/register_page.dart';
import 'package:domo/features/auth/presentation/providers/auth_provider.dart';
import 'package:domo/l10n/app_localizations.dart';

class _FakeAuthRepo implements AuthRepository {
  String? nome;
  String? email;

  @override
  Stream<User?> authStateChanges() => const Stream.empty();
  @override
  Future<void> signInWithEmailAndPassword(
          {required String email, required String password}) async {}
  @override
  Future<void> createUserWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    nome = displayName;
    this.email = email;
  }

  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> signOut() async {}
  @override
  bool get usuarioEntraComGoogle => false;
  @override
  Future<void> reautenticar({String? senha}) async {}
  @override
  Future<void> excluirUsuario() async {}
}

void main() {
  Future<_FakeAuthRepo> pump(WidgetTester tester) async {
    final repo = _FakeAuthRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          locale: Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterPage(),
        ),
      ),
    );
    return repo;
  }

  Future<void> preencher(WidgetTester tester,
      {String nome = '', String email = 'ana@exemplo.com'}) async {
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), nome);
    await tester.enterText(campos.at(1), email);
    await tester.enterText(campos.at(2), 'senha123');
    await tester.enterText(campos.at(3), 'senha123');
    await tester.ensureVisible(find.byType(FilledButton).first);
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
  }

  testWidgets('sem nome o cadastro não envia e pede o nome', (tester) async {
    final repo = await pump(tester);
    await preencher(tester);
    expect(find.text('Informe seu nome.'), findsOneWidget);
    expect(repo.nome, isNull);
  });

  testWidgets('com nome o cadastro envia o nome junto com o e-mail',
      (tester) async {
    final repo = await pump(tester);
    await preencher(tester, nome: '  Ana  ');
    expect(repo.nome, 'Ana');
    expect(repo.email, 'ana@exemplo.com');
  });
}
