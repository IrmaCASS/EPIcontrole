import '../database/database_helper.dart';
import '../models/contato_emergencia_model.dart';

class ContatoEmergenciaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Cria o contato se o paciente ainda não tiver um cadastrado,
  // ou atualiza o existente (nome + telefone) caso já exista.
  // É o método que a tela de perfil deve chamar ao salvar o formulário.
  Future<void> salvarContatoPrincipal(ContatoEmergencia contato) async {
    final db = await _dbHelper.database;

    final existentes = await db.query(
      'contato_emergencia',
      where: 'id_paciente = ?',
      whereArgs: [contato.idPaciente],
      limit: 1,
    );

    if (existentes.isEmpty) {
      await db.insert('contato_emergencia', contato.toMap());
    } else {
      final idExistente = existentes.first['id_contato'] as int;
      await db.update(
        'contato_emergencia',
        contato.copyWith(idContato: idExistente).toMap(),
        where: 'id_contato = ?',
        whereArgs: [idExistente],
      );
    }
  }

  // Atalho usado pelo Botão de Crise: retorna só o telefone do contato
  // principal, ou null se o paciente ainda não cadastrou nenhum contato.
  Future<String?> buscarTelefonePrincipal({int idPaciente = 1}) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'contato_emergencia',
      where: 'id_paciente = ?',
      whereArgs: [idPaciente],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first['telefone'] as String?;
  }
}
