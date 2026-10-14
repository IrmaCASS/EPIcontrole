// Testes da migração para a v5 (medicamento, registro_dose, bloco_notas).
//
// Chamam Migrations.apply() diretamente — o mesmo código que o
// DatabaseHelper._onUpgrade usa em produção.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:sqflite/sqflite.dart';

import '../lib/database/migrations.dart';
import '../lib/database/tables.dart';

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

Future<void> _configure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

/// Cria o schema como ele era na v4 (antes das tabelas da v5).
Future<void> _criarSchemaV4(Database db, int version) async {
  await db.execute(AppDatabaseTables.paciente);
  await db.execute(AppDatabaseTables.crise);
  await db.execute(AppDatabaseTables.contatoEmergencia);
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

Future<Set<String>> _nomesDeTabelas(Database db) async {
  final linhas = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table'",
  );
  return linhas.map((t) => t['name'] as String).toSet();
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Migração para a v5', () {
    late String path;

    setUp(() {
      path = p.join(
        Directory.systemTemp.path,
        'epicontrole_v5_test_${DateTime.now().microsecondsSinceEpoch}.db',
      );
    });

    tearDown(() async {
      final file = File(path);
      if (await file.exists()) await file.delete();
    });

    test('migra da v4 para a v5 sem perder dados e cria as tabelas novas',
        () async {
      final dbV4 = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 4,
          onConfigure: _configure,
          onCreate: _criarSchemaV4,
        ),
      );
      await dbV4.insert('paciente', {
        'id_paciente': 1,
        'nome': 'Paciente V4',
        'data_cadastro': DateTime.now().toIso8601String(),
      });
      await dbV4.insert('catalogo_sintoma', {'nome': 'Fadiga'});
      await dbV4.close();

      final dbV5 = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 5,
          onConfigure: _configure,
          onUpgrade: (db, oldVersion, newVersion) async {
            await Migrations.apply(db, oldVersion, newVersion);
          },
        ),
      );

      final pacientes = await dbV5.query('paciente');
      final sintomas = await dbV5.query('catalogo_sintoma');
      expect(pacientes.length, 1);
      expect(pacientes.first['nome'], 'Paciente V4');
      expect(sintomas.length, 1);

      expect(
        await _nomesDeTabelas(dbV5),
        containsAll(['medicamento', 'registro_dose', 'bloco_notas']),
      );

      await dbV5.close();
    });

    test('migra da v1 para a v5 passando por todas as versões', () async {
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

      final dbV5 = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 5,
          onConfigure: _configure,
          onUpgrade: (db, oldVersion, newVersion) async {
            await Migrations.apply(db, oldVersion, newVersion);
          },
        ),
      );

      expect((await dbV5.query('paciente')).length, 1);
      expect((await dbV5.query('crise')).length, 1);
      expect(
        await _nomesDeTabelas(dbV5),
        containsAll([
          'contato_emergencia',
          'diario',
          'catalogo_sintoma',
          'catalogo_gatilho',
          'catalogo_medicamento',
          'diario_sintoma',
          'diario_gatilho',
          'crise_sintoma',
          'crise_gatilho',
          'crise_medicamento',
          'medicamento',
          'registro_dose',
          'bloco_notas',
        ]),
      );

      await dbV5.close();
    });

    test('aplicar a migração duas vezes não quebra (IF NOT EXISTS)', () async {
      final db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 4,
          onConfigure: _configure,
          onCreate: _criarSchemaV4,
        ),
      );

      await Migrations.apply(db, 4, 5);
      await expectLater(Migrations.apply(db, 4, 5), completes);

      await db.close();
    });
  });

  group('Regras das tabelas da v5', () {
    late Database db;

    setUp(() async {
      db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 5,
          onConfigure: _configure,
          onCreate: (db, version) async {
            await _criarSchemaV4(db, version);
            await Migrations.apply(db, 4, 5);
          },
        ),
      );
      await db.insert('paciente', {
        'id_paciente': 1,
        'nome': 'Paciente Teste',
        'data_cadastro': DateTime.now().toIso8601String(),
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('registro_dose é apagado junto com o medicamento (CASCADE)',
        () async {
      final idMedicamento = await db.insert('medicamento', {
        'id_paciente': 1,
        'nome': 'Levetiracetam',
        'dosagem': '500mg',
        'frequencia_horarios': '08:00,20:00',
        'alertas_ativos': 1,
      });
      await db.insert('registro_dose', {
        'id_medicamento': idMedicamento,
        'data_hora_registro': DateTime.now().toIso8601String(),
        'status_tomada': 'tomada',
      });
      expect((await db.query('registro_dose')).length, 1);

      await db.delete(
        'medicamento',
        where: 'id_medicamento = ?',
        whereArgs: [idMedicamento],
      );

      expect(await db.query('registro_dose'), isEmpty);
    });

    test('bloco_notas é apagado junto com o paciente (CASCADE)', () async {
      await db.insert('bloco_notas', {
        'id_paciente': 1,
        'texto': 'Anotação de teste',
        'data_criacao': DateTime.now().toIso8601String(),
      });
      expect((await db.query('bloco_notas')).length, 1);

      await db.delete('paciente', where: 'id_paciente = ?', whereArgs: [1]);

      expect(await db.query('bloco_notas'), isEmpty);
    });
  });
}