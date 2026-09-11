// Testes do PacienteRepository — não existia nenhum teste disso ainda
// (a branch original nem tinha CRUD de paciente implementado).

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:sqflite/sqflite.dart';

import '../lib/database/tables.dart';
import '../lib/models/paciente_model.dart';
import '../lib/repositories/paciente_repository.dart';

void main() {
  late Database db;
  late PacienteRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute(AppDatabaseTables.paciente);
    await db.execute(AppDatabaseTables.crise);
    // Simula o que o DatabaseHelper._createDB faz na primeira abertura real.
    await db.insert('paciente', {
      'id_paciente': 1,
      'nome': 'Usuário Local',
      'data_cadastro': DateTime.now().toIso8601String(),
    });

    repository = PacienteRepository(databaseProvider: () async => db);
  });

  tearDown(() async {
    await db.close();
  });

  test('buscarPacienteLocal retorna o paciente único (RNF06)', () async {
    final paciente = await repository.buscarPacienteLocal();

    expect(paciente.idPaciente, 1);
    expect(paciente.nome, 'Usuário Local');
    // Sem conta configurada ainda: e-mail e senha devem estar vazios,
    // confirmando que o app funciona sem exigir login (RNF06).
    expect(paciente.email, isNull);
    expect(paciente.senhaHash, isNull);
  });

  test('atualizarPaciente muda o nome sem exigir conta', () async {
    final atual = await repository.buscarPacienteLocal();
    await repository.atualizarPaciente(
      PacienteModel(
        idPaciente: atual.idPaciente,
        nome: 'Brenda',
        dataCadastro: atual.dataCadastro,
      ),
    );

    final atualizado = await repository.buscarPacienteLocal();
    expect(atualizado.nome, 'Brenda');
  });

  test('criarContaBackup (RF20) salva e-mail e um hash, nunca a senha em texto puro', () async {
    await repository.criarContaBackup(email: 'brenda@exemplo.com', senha: 'minhaSenha123');

    final paciente = await repository.buscarPacienteLocal();

    expect(paciente.email, 'brenda@exemplo.com');
    expect(paciente.senhaHash, isNotNull);
    expect(paciente.senhaHash, isNot('minhaSenha123')); // nunca em texto puro
  });

  test('autenticar retorna true com e-mail/senha corretos', () async {
    await repository.criarContaBackup(email: 'brenda@exemplo.com', senha: 'minhaSenha123');

    final ok = await repository.autenticar(
      email: 'brenda@exemplo.com',
      senha: 'minhaSenha123',
    );

    expect(ok, isTrue);
  });

  test('autenticar retorna false com senha errada', () async {
    await repository.criarContaBackup(email: 'brenda@exemplo.com', senha: 'minhaSenha123');

    final ok = await repository.autenticar(
      email: 'brenda@exemplo.com',
      senha: 'senhaErrada',
    );

    expect(ok, isFalse);
  });

  test('autenticar retorna false quando nunca criou conta (uso 100% local)', () async {
    final ok = await repository.autenticar(
      email: 'qualquer@coisa.com',
      senha: 'qualquer',
    );

    expect(ok, isFalse);
  });
}
