import 'package:app/database/tables.dart';
import 'package:app/models/medicamento_model.dart';
import 'package:app/repositories/medicamento_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late MedicamentoRepository repo;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          await db.execute(AppDatabaseTables.paciente);
          await db.execute(AppDatabaseTables.medicamento);
          await db.execute(AppDatabaseTables.registroDose);
          await db.insert('paciente', {'nome': 'Teste'});
        },
      ),
    );
    repo = MedicamentoRepository(databaseProvider: () async => db);
  });

  tearDown(() async => db.close());

  test('inserir e buscar por id preserva os horários', () async {
    final id = await repo.inserirMedicamento(MedicamentoModel(
      nome: 'Carbamazepina',
      dosagem: '200 mg',
      horarios: ['08:00', '20:00'],
    ));
    final lido = await repo.buscarMedicamentoPorId(id);
    expect(lido, isNotNull);
    expect(lido!.nome, 'Carbamazepina');
    expect(lido.horarios, ['08:00', '20:00']);
    expect(lido.alertasAtivos, isTrue);
  });

  test('medicamento sem horários volta com lista vazia', () async {
    final id = await repo.inserirMedicamento(
      MedicamentoModel(nome: 'Sem horário', horarios: []),
    );
    final lido = await repo.buscarMedicamentoPorId(id);
    expect(lido!.horarios, isEmpty);
  });

  test('listar ordena por nome sem diferenciar maiúsculas', () async {
    await repo.inserirMedicamento(MedicamentoModel(nome: 'zonisamida', horarios: []));
    await repo.inserirMedicamento(MedicamentoModel(nome: 'Valproato', horarios: []));
    final lista = await repo.listarMedicamentos();
    expect(lista.map((m) => m.nome), ['Valproato', 'zonisamida']);
  });

  test('atualizar altera os dados e o alerta', () async {
    final id = await repo.inserirMedicamento(
      MedicamentoModel(nome: 'Lamotrigina', horarios: ['09:00']),
    );
    await repo.atualizarMedicamento(MedicamentoModel(
      idMedicamento: id,
      nome: 'Lamotrigina',
      dosagem: '100 mg',
      horarios: ['09:00', '21:00'],
      alertasAtivos: false,
    ));
    final lido = await repo.buscarMedicamentoPorId(id);
    expect(lido!.dosagem, '100 mg');
    expect(lido.horarios.length, 2);
    expect(lido.alertasAtivos, isFalse);
  });

  test('atualizar sem id lança ArgumentError', () {
    expect(
      () => repo.atualizarMedicamento(
          MedicamentoModel(nome: 'X', horarios: [])),
      throwsArgumentError,
    );
  });

  test('excluir apaga o medicamento e os registro_dose (CASCADE)', () async {
    final id = await repo.inserirMedicamento(
      MedicamentoModel(nome: 'Topiramato', horarios: ['08:00']),
    );
    await db.insert('registro_dose', {
      'id_medicamento': id,
      'data_hora_registro': DateTime.now().toIso8601String(),
      'status_tomada': 'tomada',
    });
    expect(await repo.excluirMedicamento(id), 1);
    expect(await repo.buscarMedicamentoPorId(id), isNull);
    expect(await db.query('registro_dose'), isEmpty);
  });
}