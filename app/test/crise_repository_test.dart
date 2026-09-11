// Testes do CriseRepository, focados no que os testes da Irma AINDA NÃO
// cobriam: atualizarCrise (RF2) e excluirCrise (RF4).
//
// Usa sqflite_common_ffi para rodar num banco SQLite em memória, sem
// precisar de emulador Android — mais rápido e não depende de dispositivo.
// Adicione ao pubspec.yaml, em dev_dependencies:
//   sqflite_common_ffi: ^2.3.0
//
// Rode junto com o resto: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:sqflite/sqflite.dart';

import '../lib/database/tables.dart';
import '../lib/models/crise_model.dart';
import '../lib/repositories/crise_repository.dart';

void main() {
  late Database db;
  late CriseRepository repository;

  setUpAll(() {
    // Necessário uma vez só, no início: registra o sqflite_common_ffi
    // como implementação do sqflite pros testes (em vez do plugin Android).
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Banco novo, em memória, do zero, a cada teste — evita o problema
    // que a Irma teve de um teste "vazar" dado pro outro.
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute(AppDatabaseTables.paciente);
    await db.execute(AppDatabaseTables.crise);
    await db.insert('paciente', {
      'id_paciente': 1,
      'nome': 'Paciente Teste',
      'data_cadastro': DateTime.now().toIso8601String(),
    });

    repository = CriseRepository(databaseProvider: () async => db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insere uma crise rápida (RF1) e consegue listar', () async {
    final id = await repository.inserirCrise(
      CriseModel(dataHoraInicio: DateTime.now(), duracao: const Duration(seconds: 30)),
    );

    final crises = await repository.buscarUltimasCrises();

    expect(id, greaterThan(0));
    expect(crises.length, 1);
    expect(crises.first.duracao?.inSeconds, 30);
  });

  test('atualizarCrise (RF2) salva o detalhamento complementar', () async {
    final id = await repository.inserirCrise(
      CriseModel(dataHoraInicio: DateTime.now(), duracao: const Duration(seconds: 45)),
    );

    final crise = await repository.buscarCrisePorId(id);
    final atualizada = crise!.copyWith(
      tipoCrise: 'Focal',
      atividadeAntesCrise: 'Acordado',
      estadoPosIctal: 'Confusão mental, Fadiga',
    );
    await repository.atualizarCrise(atualizada);

    final resultado = await repository.buscarCrisePorId(id);

    expect(resultado!.tipoCrise, 'Focal');
    expect(resultado.atividadeAntesCrise, 'Acordado');
    expect(resultado.estadoPosIctal, 'Confusão mental, Fadiga');
    // Campos que não foram tocados no copyWith continuam intactos:
    expect(resultado.duracao?.inSeconds, 45);
  });

  test('atualizarCrise sem idCrise lança erro (evita update sem alvo)', () async {
    final crise = CriseModel(dataHoraInicio: DateTime.now());
    expect(() => repository.atualizarCrise(crise), throwsArgumentError);
  });

  test('excluirCrise (RF4) remove o registro do banco', () async {
    final id = await repository.inserirCrise(
      CriseModel(dataHoraInicio: DateTime.now(), duracao: const Duration(seconds: 10)),
    );

    final linhasAfetadas = await repository.excluirCrise(id);
    final resultado = await repository.buscarCrisePorId(id);

    expect(linhasAfetadas, 1);
    expect(resultado, isNull);
  });

  test('excluirCrise com id inexistente não afeta nenhuma linha', () async {
    final linhasAfetadas = await repository.excluirCrise(9999);
    expect(linhasAfetadas, 0);
  });

  test('inserirCrise com paciente inexistente falha (valida a FK)', () async {
    final crise = CriseModel(
      idPaciente: 99, // não existe
      dataHoraInicio: DateTime.now(),
    );

    expect(() => repository.inserirCrise(crise), throwsA(isA<DatabaseException>()));
  });

  test('buscarCrisesPorPeriodo retorna só as crises dentro do intervalo', () async {
    final agora = DateTime.now();
    await repository.inserirCrise(
      CriseModel(dataHoraInicio: agora.subtract(const Duration(days: 10))), // fora
    );
    await repository.inserirCrise(
      CriseModel(dataHoraInicio: agora.subtract(const Duration(days: 2))), // dentro
    );

    final resultado = await repository.buscarCrisesPorPeriodo(
      inicio: agora.subtract(const Duration(days: 7)),
      fim: agora,
    );

    expect(resultado.length, 1);
  });

  test('contarCrisesUltimos7Dias conta certo (bug do blame.txt corrigido)', () async {
    final agora = DateTime.now();
    await repository.inserirCrise(CriseModel(dataHoraInicio: agora)); // agora mesmo, deve contar
    await repository.inserirCrise(
      CriseModel(dataHoraInicio: agora.subtract(const Duration(days: 20))),
    ); // fora do período

    final total = await repository.contarCrisesUltimos7Dias();

    expect(total, 1);
  });
}
