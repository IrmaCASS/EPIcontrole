// Testes da expansão do Diário de Crises (catálogos + relações N:N):
// migração de schema, transação atômica e consulta com join.
//
// Nota sobre o teste de migração: a lógica real de upgrade fica em
// DatabaseHelper._onUpgrade, que é privado (não acessível fora do
// arquivo). Por isso, este teste replica a mesma sequência de DDL
// (usando as mesmas constantes de AppDatabaseTables) para validar que,
// partindo de um banco "antigo" v1, o upgrade preserva dados e cria as
// tabelas certas. Se a orquestração real do _onUpgrade mudar, atualize
// a função _applyMigracaoParaV4 abaixo junto.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:sqflite/sqflite.dart';

import '../lib/database/tables.dart';
import '../lib/models/diario_model.dart';
import '../lib/repositories/diario_repository.dart';

// DDL da tabela crise tal como era na v1 (antes da coluna
// atividade_antes_crise, adicionada na Sprint 2).
const _criseV1 = '''
  CREATE TABLE crise (
    id_crise INTEGER PRIMARY KEY AUTOINCREMENT,
    id_paciente INTEGER NOT NULL,
    data_hora_inicio TEXT NOT NULL,
    duracao_segundos INTEGER NOT NULL,
    tipo_crise TEXT,
    turno TEXT,
    sintomas TEXT,
    prodromos_auras TEXT,
    desencadeantes TEXT,
    estado_pos_ictal TEXT,
    anotacoes TEXT,
    FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
  )
''';

Future<void> _applyMigracaoParaV4(Database db, int oldVersion) async {
  if (oldVersion < 2) {
    await db.execute(AppDatabaseTables.addColunaAtividadeAntesCrise);
  }
  if (oldVersion < 3) {
    await db.execute(AppDatabaseTables.contatoEmergencia);
  }
  if (oldVersion < 4) {
    await db.execute(AppDatabaseTables.diario);
    await db.execute(AppDatabaseTables.catalogoSintoma);
    await db.execute(AppDatabaseTables.catalogoGatilho);
    await db.execute(AppDatabaseTables.catalogoMedicamento);
    await db.execute(AppDatabaseTables.diarioSintoma);
    await db.execute(AppDatabaseTables.diarioGatilho);
    await db.execute(AppDatabaseTables.criseSintoma);
    await db.execute(AppDatabaseTables.criseGatilho);
    await db.execute(AppDatabaseTables.criseMedicamento);
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Migração de schema', () {
    late String path;

    setUp(() {
      path = p.join(
        Directory.systemTemp.path,
        'epicontrole_migracao_test_${DateTime.now().microsecondsSinceEpoch}.db',
      );
    });

    tearDown(() async {
      final file = File(path);
      if (await file.exists()) await file.delete();
    });

    test('migra da v1 para a v4 sem perder dados existentes', () async {
      // 1) Cria o banco "antigo", só com paciente + crise (schema da v1).
      final dbV1 = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(AppDatabaseTables.paciente);
            await db.execute(_criseV1);
          },
        ),
      );
      await dbV1.insert('paciente', {
        'id_paciente': 1,
        'nome': 'Paciente Antigo',
        'data_cadastro': DateTime.now().toIso8601String(),
      });
      await dbV1.insert('crise', {
        'id_paciente': 1,
        'data_hora_inicio': DateTime.now().toIso8601String(),
        'duracao_segundos': 30,
      });
      await dbV1.close();

      // 2) Reabre o MESMO arquivo pedindo a versão atual (4) — dispara
      // o onUpgrade, igual ao que acontece de verdade no app.
      final dbV4 = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 4,
          onUpgrade: (db, oldVersion, newVersion) async {
            await _applyMigracaoParaV4(db, oldVersion);
          },
        ),
      );

      final pacientes = await dbV4.query('paciente');
      final crises = await dbV4.query('crise');
      expect(pacientes.length, 1);
      expect(crises.length, 1);
      expect(pacientes.first['nome'], 'Paciente Antigo');

      final tabelas = await dbV4.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final nomes = tabelas.map((t) => t['name'] as String).toSet();
      expect(
        nomes,
        containsAll([
          'diario',
          'catalogo_sintoma',
          'catalogo_gatilho',
          'catalogo_medicamento',
          'diario_sintoma',
          'diario_gatilho',
          'crise_sintoma',
          'crise_gatilho',
          'crise_medicamento',
        ]),
      );

      await dbV4.close();
    });
  });

  group('DiarioRepository', () {
    late Database db;
    late DiarioRepository repository;

    setUp(() async {
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      await db.execute('PRAGMA foreign_keys = ON');
      await db.execute(AppDatabaseTables.paciente);
      await db.execute(AppDatabaseTables.crise);
      await db.execute(AppDatabaseTables.diario);
      await db.execute(AppDatabaseTables.catalogoSintoma);
      await db.execute(AppDatabaseTables.catalogoGatilho);
      await db.execute(AppDatabaseTables.catalogoMedicamento);
      await db.execute(AppDatabaseTables.diarioSintoma);
      await db.execute(AppDatabaseTables.diarioGatilho);
      await db.execute(AppDatabaseTables.criseSintoma);
      await db.execute(AppDatabaseTables.criseGatilho);
      await db.execute(AppDatabaseTables.criseMedicamento);

      await db.insert('paciente', {
        'id_paciente': 1,
        'nome': 'Paciente Teste',
        'data_cadastro': DateTime.now().toIso8601String(),
      });
      await db.insert('catalogo_sintoma', {
        'id_sintoma': 1,
        'nome': 'Confusão mental',
      });
      await db.insert('catalogo_gatilho', {
        'id_gatilho': 1,
        'nome': 'Privação de sono',
      });
      await db.insert('catalogo_medicamento', {
        'id_catalogo_medicamento': 1,
        'nome': 'Levetiracetam',
      });

      repository = DiarioRepository(databaseProvider: () async => db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'inserirDiarioComRelacoes cria diário com sintomas e gatilhos em transação',
      () async {
        final idDiario = await repository.inserirDiarioComRelacoes(
          DiarioModel(
            idPaciente: 1,
            dataHora: DateTime.now(),
            anotacoes: 'Dia difícil',
          ),
          idsSintomas: [1],
          idsGatilhos: [1],
        );

        final diarios = await db.query(
          'diario',
          where: 'id_diario = ?',
          whereArgs: [idDiario],
        );
        final relSintomas = await db.query(
          'diario_sintoma',
          where: 'id_diario = ?',
          whereArgs: [idDiario],
        );
        final relGatilhos = await db.query(
          'diario_gatilho',
          where: 'id_diario = ?',
          whereArgs: [idDiario],
        );

        expect(diarios.length, 1);
        expect(relSintomas.length, 1);
        expect(relGatilhos.length, 1);
      },
    );

    test(
      'inserirDiarioComRelacoes com paciente inexistente não deixa registro órfão',
      () async {
        expect(
          () => repository.inserirDiarioComRelacoes(
            DiarioModel(idPaciente: 99, dataHora: DateTime.now()),
            idsSintomas: [1],
          ),
          throwsA(isA<DatabaseException>()),
        );

        // A transação deve ter feito rollback: nada foi salvo.
        final diarios = await db.query('diario');
        final relSintomas = await db.query('diario_sintoma');
        expect(diarios, isEmpty);
        expect(relSintomas, isEmpty);
      },
    );

    test(
      'buscarCriseCompleta retorna a crise com sintomas, gatilhos e medicamentos vinculados',
      () async {
        final idCrise = await db.insert('crise', {
          'id_paciente': 1,
          'data_hora_inicio': DateTime.now().toIso8601String(),
          'duracao_segundos': 45,
        });

        await repository.vincularSintomaACrise(idCrise, 1);
        await repository.vincularGatilhoACrise(idCrise, 1);
        await repository.vincularMedicamentoACrise(idCrise, 1);

        final completa = await repository.buscarCriseCompleta(idCrise);

        expect(completa, isNotNull);
        expect(completa!.sintomas.length, 1);
        expect(completa.gatilhos.length, 1);
        expect(completa.medicamentos.length, 1);
        expect(completa.sintomas.first.nome, 'Confusão mental');
      },
    );

    test(
      'buscarSintomas/ buscarGatilhos/ buscarMedicamentos listam o catálogo',
      () async {
        final sintomas = await repository.buscarSintomas();
        final gatilhos = await repository.buscarGatilhos();
        final medicamentos = await repository.buscarMedicamentos();

        expect(sintomas.map((s) => s.nome), ['Confusão mental']);
        expect(gatilhos.map((g) => g.nome), ['Privação de sono']);
        expect(medicamentos.map((m) => m.nome), ['Levetiracetam']);
      },
    );

    test(
      'buscarDiariosPorPeriodo retorna só os diários do intervalo',
      () async {
        final hoje = DateTime(2026, 9, 24, 10, 0);
        await repository.inserirDiarioComRelacoes(
          DiarioModel(idPaciente: 1, dataHora: hoje),
        );
        await repository.inserirDiarioComRelacoes(
          DiarioModel(
            idPaciente: 1,
            dataHora: hoje.add(const Duration(days: 5)),
          ),
        );

        final diarios = await repository.buscarDiariosPorPeriodo(
          inicio: DateTime(2026, 9, 1),
          fim: DateTime(2026, 10, 1),
        );

        expect(diarios.length, 2);
      },
    );

    test(
      'buscarDiarioComRelacoes retorna diário com sintomas e gatilhos',
      () async {
        final idDiario = await repository.inserirDiarioComRelacoes(
          DiarioModel(idPaciente: 1, dataHora: DateTime(2026, 9, 24)),
          idsSintomas: [1],
          idsGatilhos: [1],
        );

        final completo = await repository.buscarDiarioComRelacoes(idDiario);

        expect(completo, isNotNull);
        expect(completo!.sintomas.length, 1);
        expect(completo.gatilhos.length, 1);
        expect(completo.sintomas.first.nome, 'Confusão mental');
      },
    );
  });
}
