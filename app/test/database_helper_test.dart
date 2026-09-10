import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app/database/database_helper.dart';
import 'package:app/models/crise_model.dart';
import 'package:app/repositories/crise_repository.dart';

void main() {
  // Inicializa o SQLite pra rodar no PC (não no emulador)
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Limpa a tabela crise ANTES de cada teste
  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('crise');
  });

  test('Deve inserir uma crise e listar', () async {
    final repo = CriseRepository();

    final crise = CriseModel(
      dataHoraInicio: DateTime(2026, 9, 10, 15, 0, 0),
      duracao: const Duration(seconds: 30),
    );

    final id = await repo.inserirCrise(crise);
    expect(id, greaterThan(0));

    final crises = await repo.buscarUltimasCrises();
    expect(crises.length, greaterThanOrEqualTo(1));

    final salva = crises.firstWhere((c) => c.idCrise == id);
    expect(salva.duracao?.inSeconds, 30);
  });

  test('Deve inserir crise com campos opcionais', () async {
    final repo = CriseRepository();

    final crise = CriseModel(
      dataHoraInicio: DateTime(2026, 9, 10, 16, 0, 0),
      duracao: const Duration(seconds: 120),
      tipoCrise: 'Focal',
      prodromosAuras: 'Dormência',
      desencadeantes: 'Estresse',
      estadoPosIctal: 'Confusão',
      atividadeAntesCrise: 'Acordado',
      anotacoes: 'Teste automatizado',
    );

    final id = await repo.inserirCrise(crise);
    expect(id, greaterThan(0));

    final salva = await repo.buscarCrisePorId(id);
    expect(salva, isNotNull);
    expect(salva!.tipoCrise, 'Focal');
    expect(salva.anotacoes, 'Teste automatizado');
    expect(salva.duracao?.inSeconds, 120);
  });

  test('Deve falhar ao inserir crise com paciente inexistente (FK)', () async {
    final repo = CriseRepository();

    final crise = CriseModel(
      idPaciente: 999,
      dataHoraInicio: DateTime.now(),
      duracao: const Duration(seconds: 10),
    );

    expect(
      () => repo.inserirCrise(crise),
      throwsA(isA<Exception>()),
    );
  });
}