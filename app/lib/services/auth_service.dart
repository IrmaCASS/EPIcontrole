import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../database/database_helper.dart';

class ResultadoAuth {
  final bool sucesso;
  final String mensagem;

  ResultadoAuth({required this.sucesso, required this.mensagem});
}

class AuthService {
  /// Cadastra um novo paciente no banco local.
  static Future<ResultadoAuth> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Verifica se o email já está cadastrado
    final existente = await db.query(
      'paciente',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (existente.isNotEmpty) {
      return ResultadoAuth(
        sucesso: false,
        mensagem: 'Este email já está cadastrado.',
      );
    }

    // Hasheia a senha antes de salvar
    final senhaHash = sha256.convert(utf8.encode(senha)).toString();

    await db.insert('paciente', {
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'data_cadastro': DateTime.now().toIso8601String(),
    });

    return ResultadoAuth(sucesso: true, mensagem: 'Conta criada com sucesso!');
  }

  /// Faz login verificando email e senha no banco local.
  static Future<ResultadoAuth> login({
    required String email,
    required String senha,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final senhaHash = sha256.convert(utf8.encode(senha)).toString();

    print('DEBUG LOGIN: email=$email');
    print('DEBUG LOGIN: senhaHash=$senhaHash');

    final result = await db.query(
      'paciente',
      where: 'email = ? AND senha_hash = ?',
      whereArgs: [email, senhaHash],
      limit: 1,
    );

    print('DEBUG LOGIN: resultado=$result');

    if (result.isEmpty) {
      return ResultadoAuth(
        sucesso: false,
        mensagem: 'Email ou senha incorretos.',
      );
    }

    return ResultadoAuth(
      sucesso: true,
      mensagem: 'Login efetuado com sucesso!',
    );
  }
}
