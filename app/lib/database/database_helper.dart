import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'tables.dart';

/// Camada de persistência local (offline-first) do EPIcontrole.
///
/// Responsabilidade única: abrir/criar/migrar o banco SQLite e entregar
/// a conexão (`Database`) para quem precisar. Consultas de negócio
/// (CRUD de paciente, crise, etc.) ficam nos repositórios, em
/// lib/repositories/ — não aqui.
///
/// Padrão Singleton: existe uma única instância/conexão de banco durante
/// toda a vida do app (RNF07 — arquitetura offline-first, RNF10 —
/// armazenamento local).
class DatabaseHelper {
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  // v1 = Sprint 1 (Botão de Crise: paciente + crise sem atividade_antes_crise)
  // v2 = Sprint 2 (Diário de Crises: + coluna atividade_antes_crise)
  // v3 = Sprint 3 (Contatos de Emergência: + tabela contato_emergencia)
  // v4 = Diário de Crises (entidade própria): catálogos de sintomas,
  //      gatilhos e medicamentos + relações N:N com diario e crise.
  static const int _dbVersion = 4;
  static const String _dbFileName = 'epicontrole.db';

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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbFileName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Necessário para o FOREIGN KEY ... ON DELETE CASCADE funcionar de fato.
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Executado apenas na primeira instalação (banco ainda não existe).
  Future<void> _createDB(Database db, int version) async {
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

    await db.execute(AppDatabaseTables.idxDiarioSintomaSintoma);
    await db.execute(AppDatabaseTables.idxDiarioGatilhoGatilho);
    await db.execute(AppDatabaseTables.idxCriseSintomaSintoma);
    await db.execute(AppDatabaseTables.idxCriseGatilhoGatilho);
    await db.execute(AppDatabaseTables.idxCriseMedicamentoCatalogo);

    // Paciente local único (v1 = app sem login/nuvem, RNF06).
    // Importante: usa o datetime() do próprio SQLite.
    await db.rawInsert(
      "INSERT INTO paciente (id_paciente, nome, data_cadastro) "
      "VALUES (1, 'Usuário Local', datetime('now'))",
    );

    await _seedCatalogos(db);
  }

  /// Executado quando o app já tem um banco instalado numa versão antiga.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Sprint 2 — tela "Diário de Crises": campo "Você estava?"
      await db.execute(AppDatabaseTables.addColunaAtividadeAntesCrise);
    }
    if (oldVersion < 3) {
      // Sprint 3 — tela "Contatos de Emergência": tabela nova
      await db.execute(AppDatabaseTables.contatoEmergencia);
    }
    if (oldVersion < 4) {
      // Diário de Crises como entidade própria + catálogos + relações N:N
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

      await _seedCatalogos(db);
    }
  }

  /// Popula os catálogos com valores iniciais comuns em epilepsia.
  /// Usa conflictAlgorithm.ignore (a coluna nome é UNIQUE) para ser
  /// seguro rodar mais de uma vez sem duplicar linhas.
  Future<void> _seedCatalogos(Database db) async {
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

  /// Fecha a conexão sem reabrir o banco à toa.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}