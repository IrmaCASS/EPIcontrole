import '../database/database_helper.dart';
import '../models/crise_model.dart';

class CriseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> inserirCrise(Crise crise) async {
    final db = await _dbHelper.database;
    return db.insert('crise', crise.toMap());
  }

  Future<Crise?> buscarCrisePorId(int idCrise) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'crise',
      where: 'id_crise = ?',
      whereArgs: [idCrise],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Crise.fromMap(result.first);
  }

  Future<List<Crise>> buscarTodasCrises() async {
    final db = await _dbHelper.database;
    final result = await db.query('crise', orderBy: 'data_hora_inicio DESC');
    return result.map(Crise.fromMap).toList();
  }

  Future<List<Crise>> buscarUltimasCrises({int limite = 5}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'crise',
      orderBy: 'data_hora_inicio DESC',
      limit: limite,
    );
    return result.map(Crise.fromMap).toList();
  }

  Future<int> atualizarCrise(Crise crise) async {
    final id = crise.idCrise;
    if (id == null) return 0;
    final db = await _dbHelper.database;
    final mapa = crise.toMap()..remove('id_crise');
    return db.update(
      'crise',
      mapa,
      where: 'id_crise = ?',
      whereArgs: [id],
    );
  }

  Future<int> excluirCrise(int idCrise) async {
    final db = await _dbHelper.database;
    return db.delete('crise', where: 'id_crise = ?', whereArgs: [idCrise]);
  }

  Future<int> contarCrisesUltimos7Dias() async {
    final db = await _dbHelper.database;
    final agora = DateTime.now().toIso8601String();
    final seteDiasAtras = DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM crise '
      'WHERE data_hora_inicio >= ? AND data_hora_inicio <= ?',
      [seteDiasAtras, agora],
    );
    if (result.isEmpty) return 0;
    return result.first['total'] as int? ?? 0;
  }
}