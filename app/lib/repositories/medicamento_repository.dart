import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/medicamento_model.dart';

/// Camada de acesso a dados dos medicamentos de uso contínuo do paciente
/// (tabela `medicamento`, v5). Não confundir com `catalogo_medicamento`,
/// que é a lista de referência usada no registro de crise.
class MedicamentoRepository {
  final Future<Database> Function() _databaseProvider;

  MedicamentoRepository({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => DatabaseHelper.instance.database);

  Future<int> inserirMedicamento(MedicamentoModel medicamento) async {
    final db = await _databaseProvider();
    return await db.insert('medicamento', medicamento.toMap());
  }

  Future<int> atualizarMedicamento(MedicamentoModel medicamento) async {
    if (medicamento.idMedicamento == null) {
      throw ArgumentError(
        'atualizarMedicamento precisa de um idMedicamento; '
        'use inserirMedicamento para criar.',
      );
    }
    final db = await _databaseProvider();
    return await db.update(
      'medicamento',
      medicamento.toMap(),
      where: 'id_medicamento = ?',
      whereArgs: [medicamento.idMedicamento],
    );
  }

  /// Apaga também os `registro_dose` do medicamento (ON DELETE CASCADE).
  Future<int> excluirMedicamento(int idMedicamento) async {
    final db = await _databaseProvider();
    return await db.delete(
      'medicamento',
      where: 'id_medicamento = ?',
      whereArgs: [idMedicamento],
    );
  }

  Future<MedicamentoModel?> buscarMedicamentoPorId(int idMedicamento) async {
    final db = await _databaseProvider();
    final result = await db.query(
      'medicamento',
      where: 'id_medicamento = ?',
      whereArgs: [idMedicamento],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return MedicamentoModel.fromMap(result.first);
  }

  Future<List<MedicamentoModel>> listarMedicamentos({int idPaciente = 1}) async {
    final db = await _databaseProvider();
    final result = await db.query(
      'medicamento',
      where: 'id_paciente = ?',
      whereArgs: [idPaciente],
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    return result.map((map) => MedicamentoModel.fromMap(map)).toList();
  }
}