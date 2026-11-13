import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../casa/presentation/providers/casa_provider.dart';
import '../../data/exclusao_de_conta_service.dart';

final exclusaoDeContaServiceProvider = Provider<ExclusaoDeContaService>((ref) {
  return ExclusaoDeContaService(
    auth: ref.watch(authRepositoryProvider),
    casas: ref.watch(casaRepositoryProvider),
    firestore: FirebaseFirestore.instance,
  );
});
