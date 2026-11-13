import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_provider.dart';

const _prefsKey = 'analytics_enabled';

/// Reads the saved "Medição de uso" choice (default: on, as the privacy
/// policy describes — legitimate interest with an opt-out). Never throws: if
/// storage is unavailable the default applies.
Future<bool> lerMedicaoDeUsoAtivada() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? true;
  } catch (_) {
    return true;
  }
}

/// State of the "Medição de uso" switch. Flipping it persists the choice on
/// the device and applies it to Firebase Analytics right away.
class MedicaoDeUsoNotifier extends StateNotifier<bool> {
  MedicaoDeUsoNotifier(this._ref) : super(true) {
    _carregar();
  }

  final Ref _ref;

  Future<void> _carregar() async {
    final ativada = await lerMedicaoDeUsoAtivada();
    if (mounted) state = ativada;
  }

  Future<void> definir(bool ativada) async {
    state = ativada;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, ativada);
    } catch (_) {}
    try {
      await _ref.read(analyticsServiceProvider).setEnabled(ativada);
    } catch (_) {}
  }
}

final medicaoDeUsoProvider =
    StateNotifierProvider<MedicaoDeUsoNotifier, bool>(
  (ref) => MedicaoDeUsoNotifier(ref),
);
