import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../database/database_helper.dart';
import '../models/paciente_model.dart';

/// Camada de acesso a dados do paciente.
///
/// - RNF06 (Cadastro simplificado): a etapa de "1º uso" NÃO exige
///   e-mail/senha. O paciente local (id_paciente = 1) já existe
///   assim que o banco é criado — ver DatabaseHelper._createDB.
/// - RF20 (Backup em nuvem): criar conta com e-mail/senha é OPCIONAL.
class PacienteRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<PacienteModel> buscarPacienteLocal() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'paciente',
      where: 'id_paciente = ?',
      whereArgs: [1],
      limit: 1,
    );
    return PacienteModel.fromMap(result.first);
  }

  Future<int> atualizarPaciente(PacienteModel paciente) async {
    final db = await _dbHelper.database;
    return await db.update(
      'paciente',
      paciente.toMap(),
      where: 'id_paciente = ?',
      whereArgs: [paciente.idPaciente ?? 1],
    );
  }

  /// RF20 — criação de conta opcional para backup em nuvem.
  /// A senha nunca é salva em texto puro: só o hash (SHA-256).
  Future<int> criarContaBackup({
    required String email,
    required String senha,
  }) async {
    final db = await _dbHelper.database;
    return await db.update(
      'paciente',
      {
        'email': email,
        'senha_hash': _hashSenha(senha),
      },
      where: 'id_paciente = ?',
      whereArgs: [1],
    );
  }

  /// Confere se a senha informada bate com o hash salvo.
  Future<bool> autenticar({
    required String email,
    required String senha,
  }) async {
    final paciente = await buscarPacienteLocal();
    if (paciente.email == null || paciente.senhaHash == null) return false;
    return paciente.email == email &&
        paciente.senhaHash == _hashSenha(senha);
  }

  String _hashSenha(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }
}