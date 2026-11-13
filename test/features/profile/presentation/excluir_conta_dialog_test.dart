import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:domo/features/auth/domain/repositories/auth_repository.dart';
import 'package:domo/features/auth/presentation/providers/auth_provider.dart';
import 'package:domo/features/casa/domain/models/casa_model.dart';
import 'package:domo/features/profile/data/exclusao_de_conta_service.dart';
import 'package:domo/features/profile/presentation/providers/exclusao_de_conta_provider.dart';
import 'package:domo/features/profile/presentation/widgets/excluir_conta_dialog.dart';
import 'package:domo/l10n/app_localizations.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockService extends Mock implements ExclusaoDeContaService {}

void main() {
  late _MockAuth auth;
  late _MockService service;

  setUp(() {
    auth = _MockAuth();
    service = _MockService();
    when(() => auth.usuarioEntraComGoogle).thenReturn(false);
  });

  Future<void> abrir(WidgetTester tester, {CasaModel? casa}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          exclusaoDeContaServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ExcluirContaDialog(uid: 'u1', casa: casa, membrosAtivos: 3),
          ),
        ),
      ),
    );
  }

  final casaDela = CasaModel(
    id: 'c1',
    nome: 'Casa Azul',
    codigo: 'ABC234',
    criadoPor: 'u1',
    criadoEm: DateTime(2026, 1, 1),
  );

  testWidgets('botão só habilita com a senha preenchida', (tester) async {
    await abrir(tester);
    final botao = find.widgetWithText(TextButton, 'Excluir minha conta');
    expect(tester.widget<TextButton>(botao).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'segredo');
    await tester.pump();
    expect(tester.widget<TextButton>(botao).onPressed, isNotNull);
  });

  testWidgets('quem criou a casa vê o aviso de que ela some pra todos',
      (tester) async {
    await abrir(tester, casa: casaDela);
    expect(find.textContaining('será apagada para todos os 3 membros'),
        findsOneWidget);
  });

  testWidgets('senha errada mostra o erro e não fecha', (tester) async {
    when(() => service.excluir(
            uid: any(named: 'uid'), senha: any(named: 'senha')))
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));
    await abrir(tester);
    await tester.enterText(find.byType(TextField), 'errada');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir minha conta'));
    await tester.pumpAndSettle();
    expect(find.text('Senha incorreta. Verifique e tente novamente.'),
        findsOneWidget);
    expect(find.byType(ExcluirContaDialog), findsOneWidget);
  });
}
