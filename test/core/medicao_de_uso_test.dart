import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:domo/core/analytics/analytics_opt_out.dart';
import 'package:domo/core/analytics/analytics_provider.dart';
import 'package:domo/core/analytics/analytics_service.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

void main() {
  late _MockAnalytics analytics;

  setUp(() {
    analytics = _MockAnalytics();
    when(() => analytics.setEnabled(any())).thenAnswer((_) async {});
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [analyticsServiceProvider.overrideWithValue(analytics)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('por padrão a medição de uso está ligada', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await lerMedicaoDeUsoAtivada(), isTrue);
  });

  test('desligar grava a escolha e desliga o Analytics na hora', () async {
    SharedPreferences.setMockInitialValues({});
    final c = container();
    await c.read(medicaoDeUsoProvider.notifier).definir(false);

    expect(c.read(medicaoDeUsoProvider), isFalse);
    verify(() => analytics.setEnabled(false)).called(1);
    expect(await lerMedicaoDeUsoAtivada(), isFalse);
  });

  test('a escolha salva é lida no próximo boot', () async {
    SharedPreferences.setMockInitialValues({'analytics_enabled': false});
    expect(await lerMedicaoDeUsoAtivada(), isFalse);
  });
}
