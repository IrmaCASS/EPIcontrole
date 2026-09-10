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
  static const int _dbVersion = 2;
  static const String _dbFileName = 'epicontrole.db';

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

    // Paciente local único (v1 = app sem login/nuvem, RNF06).
    // Importante: usa o datetime() do próprio SQLite.
    await db.rawInsert(
      "INSERT INTO paciente (id_paciente, nome, data_cadastro) "
      "VALUES (1, 'Usuário Local', datetime('now'))",
    );
  }

  /// Executado quando o app já tem um banco instalado numa versão antiga.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Sprint 2 — tela "Diário de Crises": campo "Você estava?"
      await db.execute(AppDatabaseTables.addColunaAtividadeAntesCrise);
    }
  }

  /// Fecha a conexão sem reabrir o banco à toa.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}