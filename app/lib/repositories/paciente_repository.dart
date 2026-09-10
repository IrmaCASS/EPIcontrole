import '../database/database_helper.dart';
import '../models/paciente_model.dart';

class PacienteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> inserirPaciente(Paciente paciente) async {
    final db = await _dbHelper.database;
    return db.insert('paciente', paciente.toMap());
  }

  Future<Paciente?> buscarPacientePorId(int idPaciente) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'paciente',
      where: 'id_paciente = ?',
      whereArgs: [idPaciente],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Paciente.fromMap(result.first);
  }

  Future<Paciente?> buscarPacientePorEmail(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'paciente',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Paciente.fromMap(result.first);
  }

  Future<List<Paciente>> buscarTodos() async {
    final db = await _dbHelper.database;
    final result = await db.query('paciente', orderBy: 'nome');
    return result.map(Paciente.fromMap).toList();
  }

  Future<int> atualizarPaciente(Paciente paciente) async {
    final id = paciente.idPaciente;
    if (id == null) return 0;
    final db = await _dbHelper.database;
    final mapa = paciente.toMap()..remove('id_paciente');
    return db.update(
      'paciente',
      mapa,
      where: 'id_paciente = ?',
      whereArgs: [id],
    );
  }

  Future<int> excluirPaciente(int idPaciente) async {
    final db = await _dbHelper.database;
    return db.delete('paciente', where: 'id_paciente = ?', whereArgs: [idPaciente]);
  }
}