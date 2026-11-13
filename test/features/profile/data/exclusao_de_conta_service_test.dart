import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:domo/core/analytics/analytics_service.dart';
import 'package:domo/features/auth/domain/repositories/auth_repository.dart';
import 'package:domo/features/casa/data/repositories/casa_repository_impl.dart';
import 'package:domo/features/profile/data/exclusao_de_conta_service.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

class _MockAuth extends Mock implements AuthRepository {}

void main() {
  late FakeFirebaseFirestore db;
  late CasaRepositoryImpl casas;
  late _MockAuth auth;
  late ExclusaoDeContaService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    final analytics = _MockAnalytics();
    when(() => analytics.logCasaCriada()).thenAnswer((_) async {});
    when(() => analytics.logCasaEntrou()).thenAnswer((_) async {});
    casas = CasaRepositoryImpl(firestore: db, analytics: analytics);
    auth = _MockAuth();
    when(() => auth.reautenticar(senha: any(named: 'senha')))
        .thenAnswer((_) async {});
    when(() => auth.excluirUsuario()).thenAnswer((_) async {});
    service = ExclusaoDeContaService(auth: auth, casas: casas, firestore: db);
  });

  test('casa que a pessoa criou some pra todos, com itens e código', () async {
    final casa =
        await casas.criarCasa(nome: 'Minha', userId: 'u1', nomeUsuario: 'Ana');
    await db.collection('casas').doc(casa.id).collection('itens').doc('a').set({
      'nome': 'Arroz',
    });

    await service.excluir(uid: 'u1');

    expect((await db.collection('casas').doc(casa.id).get()).exists, isFalse);
    expect((await db.collection('codigos').doc(casa.codigo).get()).exists,
        isFalse);
    expect(
        (await db.collection('casas').doc(casa.id).collection('itens').get())
            .docs,
        isEmpty);
    verify(() => auth.excluirUsuario()).called(1);
  });

  test('casa onde é só membro continua, sem o nome da pessoa', () async {
    final casa =
        await casas.criarCasa(nome: 'Do dono', userId: 'dono', nomeUsuario: 'D');
    await db.collection('casas').doc(casa.id).update({
      'membros.u2': {'userId': 'u2', 'nome': 'Bia', 'status': 'ativo'},
      'membrosAtivos': FieldValue.arrayUnion(['u2']),
    });

    await service.excluir(uid: 'u2');

    final data = (await db.collection('casas').doc(casa.id).get()).data()!;
    expect((data['membros'] as Map).containsKey('u2'), isFalse);
    expect(data['membrosAtivos'], ['dono']);
  });

  test('pendente em outra casa é removida pelo índice usuarios/{uid}',
      () async {
    final casa =
        await casas.criarCasa(nome: 'Do dono', userId: 'dono', nomeUsuario: 'D');
    await casas.entrarNaCasa(
        codigo: casa.codigo, userId: 'u3', nomeUsuario: 'Caio');
    expect(
        ((await db.collection('casas').doc(casa.id).get()).data()!['membros']
                as Map)
            .containsKey('u3'),
        isTrue);

    await service.excluir(uid: 'u3');

    final data = (await db.collection('casas').doc(casa.id).get()).data()!;
    expect((data['membros'] as Map).containsKey('u3'), isFalse);
    expect((await db.collection('usuarios').doc('u3').get()).exists, isFalse);
  });

  test('entrada obsoleta no índice (casa já apagada) é ignorada', () async {
    await db.collection('usuarios').doc('u4').set({
      'pendenteEm': ['casa-que-nao-existe'],
    });
    await service.excluir(uid: 'u4');
    expect((await db.collection('usuarios').doc('u4').get()).exists, isFalse);
    verify(() => auth.excluirUsuario()).called(1);
  });

  test('reautenticação falha: nada é apagado', () async {
    final casa =
        await casas.criarCasa(nome: 'Minha', userId: 'u1', nomeUsuario: 'Ana');
    when(() => auth.reautenticar(senha: any(named: 'senha')))
        .thenThrow(const ReautenticacaoCancelada());

    await expectLater(
        service.excluir(uid: 'u1'), throwsA(isA<ReautenticacaoCancelada>()));

    expect((await db.collection('casas').doc(casa.id).get()).exists, isTrue);
    verifyNever(() => auth.excluirUsuario());
  });
}
