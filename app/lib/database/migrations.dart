import 'package:sqflite/sqflite.dart';

import 'tables.dart';

/// Toda a lógica de migração/versionamento do schema do EPIcontrole,
/// centralizada aqui para ser testável de verdade: o teste de migração
/// chama exatamente este Migrations.apply(), o mesmo código que roda em
/// produção — em vez de duplicar a sequência de DDL numa função separada
/// que pode ficar desatualizada sem ninguém perceber.
class Migrations {
  Migrations._();

  static const List<String> _seedSintomas = [
    'Confusão mental',
    'Perda de consciência',
    'Rigidez muscular',
    'Abalos/convulsões',
    'Salivação excessiva',
    'Mordedura de língua',
    'Fadiga',
    'Dor de cabeça',
  ];

  static const List<String> _seedGatilhos = [
    'Privação de sono',
    'Estresse',
    'Luzes piscantes/fotossensibilidade',
    'Consumo de álcool',
    'Esquecimento de medicação',
    'Febre',
    'Menstruação',
  ];

  static const List<String> _seedMedicamentos = [
    'Ácido Valproico',
    'Carbamazepina',
    'Levetiracetam',
    'Fenitoína',
    'Lamotrigina',
    'Clobazam',
    'Topiramato',
  ];

  /// Aplica as migrações necessárias de acordo com a versão antiga do
  /// banco. Chamado pelo DatabaseHelper._onUpgrade (produção) e também
  /// diretamente pelos testes.
  static Future<void> apply(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
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

      await db.execute(AppDatabaseTables.idxDiarioSintomaSintoma);
      await db.execute(AppDatabaseTables.idxDiarioGatilhoGatilho);
      await db.execute(AppDatabaseTables.idxCriseSintomaSintoma);
      await db.execute(AppDatabaseTables.idxCriseGatilhoGatilho);
      await db.execute(AppDatabaseTables.idxCriseMedicamentoCatalogo);

      await seedCatalogos(db);
    }
    if (oldVersion < 5) {
      // v5 — Medicamentos do paciente + Bloco de Notas.
      // medicamento vem antes de registro_dose (a FK aponta pra ele).
      await db.execute(AppDatabaseTables.medicamento);
      await db.execute(AppDatabaseTables.registroDose);
      await db.execute(AppDatabaseTables.blocoNotas);
    }
  }

  /// Popula os catálogos com valores iniciais comuns em epilepsia.
  /// Usa conflictAlgorithm.ignore (a coluna nome é UNIQUE) para ser
  /// seguro rodar mais de uma vez sem duplicar linhas.
  static Future<void> seedCatalogos(Database db) async {
    final batch = db.batch();
    for (final nome in _seedSintomas) {
      batch.insert('catalogo_sintoma', {'nome': nome},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final nome in _seedGatilhos) {
      batch.insert('catalogo_gatilho', {'nome': nome},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final nome in _seedMedicamentos) {
      batch.insert('catalogo_medicamento', {'nome': nome},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}