import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('epicontrole.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE paciente (
        id_paciente INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        email TEXT,
        senha_hash TEXT,
        data_cadastro TEXT
      )
    ''');

    await db.execute('''
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
        atividade_antes_crise TEXT,
        anotacoes TEXT,
        FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
      )
    ''');

    await db.rawInsert('''
      INSERT INTO paciente (id_paciente, nome, data_cadastro)
      VALUES (1, 'Usuário Teste', datetime('now'))
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}