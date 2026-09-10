import '../database/database_helper.dart';
import '../models/crise_model.dart';

/// Camada de acesso a dados das crises (RF1 a RF4, RF6, RF9, base do RF19).
class CriseRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// RF1 — registro rápido: salva só data/hora + duração, sem detalhamento.
  Future<int> inserirCrise(CriseModel crise) async {
    final db = await _dbHelper.database;
    return await db.insert('crise', crise.toMap());
  }

  /// RF2 — detalhamento complementar de uma crise já registrada.
  Future<int> atualizarCrise(CriseModel crise) async {
    if (crise.idCrise == null) {
      throw ArgumentError(
        'atualizarCrise precisa de um idCrise — use inserirCrise para criar.',
      );
    }
    final db = await _dbHelper.database;
    return await db.update(
      'crise',
      crise.toMap(),
      where: 'id_crise = ?',
      whereArgs: [crise.idCrise],
    );
  }

  /// RF4 — exclusão de um registro de crise.
  Future<int> excluirCrise(int idCrise) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'crise',
      where: 'id_crise = ?',
      whereArgs: [idCrise],
    );
  }

  Future<CriseModel?> buscarCrisePorId(int idCrise) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'crise',
      where: 'id_crise = ?',
      whereArgs: [idCrise],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return CriseModel.fromMap(result.first);
  }

  /// Usado na Home para mostrar a lista de crises recentes.
  Future<List<CriseModel>> buscarUltimasCrises({int limite = 5}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'crise',
      orderBy: 'data_hora_inicio DESC',
      limit: limite,
    );
    return result.map((map) => CriseModel.fromMap(map)).toList();
  }

  /// RF3/RF4 — calendário interativo e gestão de registros anteriores.
  Future<List<CriseModel>> buscarCrisesPorPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'crise',
      where: 'data_hora_inicio BETWEEN ? AND ?',
      whereArgs: [inicio.toIso8601String(), fim.toIso8601String()],
      orderBy: 'data_hora_inicio ASC',
    );
    return result.map((map) => CriseModel.fromMap(map)).toList();
  }

  /// RF19 (base do relatório): total de crises num período.
  Future<int> contarCrisesPorPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM crise WHERE data_hora_inicio BETWEEN ? AND ?',
      [inicio.toIso8601String(), fim.toIso8601String()],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Atalho: crises dos últimos 7 dias.
  Future<int> contarCrisesUltimos7Dias() {
    final agora = DateTime.now();
    return contarCrisesPorPeriodo(
      inicio: agora.subtract(const Duration(days: 7)),
      fim: agora,
    );
  }
}