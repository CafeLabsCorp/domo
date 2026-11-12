import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domo/l10n/app_localizations.dart';
import 'package:domo/shared/widgets/erro_snack.dart';

final _ctrl = StateProvider<AsyncValue<void>>((ref) => const AsyncData(null));

class _Page extends ConsumerWidget {
  const _Page();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    escutarErroDoControlador(context, ref, _ctrl);
    return const Scaffold(body: SizedBox());
  }
}

void main() {
  Future<ProviderContainer> pump(WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _Page(),
        ),
      ),
    );
    return container;
  }

  testWidgets('permission-denied mostra aviso genérico em vez de falhar calado',
      (tester) async {
    final c = await pump(tester);
    c.read(_ctrl.notifier).state = AsyncError(
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      StackTrace.empty,
    );
    await tester.pump();
    expect(find.text('Erro inesperado. Tente novamente.'), findsOneWidget);
  });

  testWidgets('unavailable mostra aviso de sem conexão', (tester) async {
    final c = await pump(tester);
    c.read(_ctrl.notifier).state = AsyncError(
      FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      StackTrace.empty,
    );
    await tester.pump();
    expect(find.textContaining('conexão'), findsOneWidget);
  });

  testWidgets('sem erro, nada aparece', (tester) async {
    await pump(tester);
    expect(find.byType(SnackBar), findsNothing);
  });
}
