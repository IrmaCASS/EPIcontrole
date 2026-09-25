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

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: _onConfigure,
    );
  }

  // Quem já tinha o app instalado na v1 (sem contato_emergencia) passa por
  // aqui em vez de _createDB, que só roda numa base zerada.
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE contato_emergencia (
          id_contato INTEGER PRIMARY KEY AUTOINCREMENT,
          id_paciente INTEGER NOT NULL,
          nome TEXT,
          telefone TEXT NOT NULL,
          FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
        )
      ''');
    }
  }

  // Ativa chave estrangeira (equivalente ao PRAGMA do script epicontrole.sql)
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // Tabela Paciente (igual ao epicontrole.sql)
    await db.execute('''
      CREATE TABLE paciente (
        id_paciente INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        email TEXT,
        senha_hash TEXT,
        data_cadastro TEXT
      )
    ''');

    // Tabela Crise (igual ao epicontrole.sql)
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

    // Tabela Contato de Emergência (contato principal do paciente,
    // usado pelo Botão de Crise para abrir o discador ao encerrar a crise)
    await db.execute('''
      CREATE TABLE contato_emergencia (
        id_contato INTEGER PRIMARY KEY AUTOINCREMENT,
        id_paciente INTEGER NOT NULL,
        nome TEXT,
        telefone TEXT NOT NULL,
        FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
      )
    ''');

    // Insere o Usuário Teste ID 1 padrão.
    // Usamos '?' (parâmetros) em vez de concatenar valores na string SQL,
    // e geramos a data no próprio Dart em ISO8601 — o mesmo formato que
    // Paciente.fromMap() espera ao fazer DateTime.parse().
    await db.rawInsert(
      'INSERT INTO paciente (id_paciente, nome, data_cadastro) VALUES (?, ?, ?)',
      [1, 'Usuário Teste', DateTime.now().toIso8601String()],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
