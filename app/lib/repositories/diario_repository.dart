import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/crise_completa.dart';
import '../models/crise_model.dart';
import '../models/diario_model.dart';
import '../models/sintoma_model.dart';
import '../models/gatilho_model.dart';
import '../models/catalogo_medicamento_model.dart';
import '../models/diario_completo.dart';

/// Camada de acesso a dados do Diário de Crises: catálogos de sintomas,
/// gatilhos e medicamentos, e as relações N:N com "diario" e "crise".
class DiarioRepository {
  final Future<Database> Function() _databaseProvider;

  DiarioRepository({Future<Database> Function()? databaseProvider})
    : _databaseProvider =
          databaseProvider ?? (() => DatabaseHelper.instance.database);

  /// Cria um diário e vincula sintomas/gatilhos numa única transação:
  /// ou tudo é salvo, ou nada é (evita registros órfãos em caso de erro,
  /// ex.: paciente inexistente violando a foreign key).
  Future<int> inserirDiarioComRelacoes(
    DiarioModel diario, {
    List<int> idsSintomas = const [],
    List<int> idsGatilhos = const [],
  }) async {
    final db = await _databaseProvider();
    return db.transaction<int>((txn) async {
      final idDiario = await txn.insert('diario', diario.toMap());

      for (final idSintoma in idsSintomas) {
        await txn.insert('diario_sintoma', {
          'id_diario': idDiario,
          'id_sintoma': idSintoma,
        });
      }
      for (final idGatilho in idsGatilhos) {
        await txn.insert('diario_gatilho', {
          'id_diario': idDiario,
          'id_gatilho': idGatilho,
        });
      }
      return idDiario;
    });
  }

  Future<void> vincularSintomaACrise(int idCrise, int idSintoma) async {
    final db = await _databaseProvider();
    await db.insert('crise_sintoma', {
      'id_crise': idCrise,
      'id_sintoma': idSintoma,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> vincularGatilhoACrise(int idCrise, int idGatilho) async {
    final db = await _databaseProvider();
    await db.insert('crise_gatilho', {
      'id_crise': idCrise,
      'id_gatilho': idGatilho,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> vincularMedicamentoACrise(
    int idCrise,
    int idCatalogoMedicamento,
  ) async {
    final db = await _databaseProvider();
    await db.insert('crise_medicamento', {
      'id_crise': idCrise,
      'id_catalogo_medicamento': idCatalogoMedicamento,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> limparVinculosDaCrise(int idCrise) async {
    final db = await _databaseProvider();
    final batch = db.batch();
    batch.delete('crise_sintoma', where: 'id_crise = ?', whereArgs: [idCrise]);
    batch.delete('crise_gatilho', where: 'id_crise = ?', whereArgs: [idCrise]);
    batch.delete('crise_medicamento', where: 'id_crise = ?', whereArgs: [idCrise]);
    await batch.commit(noResult: true);
  }

  /// Converte uma CriseModel em DiarioModel para exibição unificada
  /// na tela do Diário de Crises.
  DiarioModel _criseParaDiario(CriseModel crise) {
    final partes = <String>[];
    if (crise.tipoCrise != null && crise.tipoCrise!.isNotEmpty) {
      partes.add('Tipo: ${crise.tipoCrise}');
    }
    if (crise.duracao != null && crise.duracao!.inSeconds > 0) {
      partes.add('Duração: ${crise.duracao!.inSeconds}s');
    }
    if (crise.atividadeAntesCrise != null &&
        crise.atividadeAntesCrise!.isNotEmpty) {
      partes.add('Você estava: ${crise.atividadeAntesCrise}');
    }
    if (crise.anotacoes != null && crise.anotacoes!.isNotEmpty) {
      partes.add(crise.anotacoes!);
    }

    return DiarioModel(
      idDiario: null,
      idPaciente: crise.idPaciente,
      dataHora: crise.dataHoraInicio,
      anotacoes: partes.isEmpty ? 'Crise registrada' : partes.join(' • '),
    );
  }

  /// Busca diários E crises recentes (unificados para a tela do Diário).
  Future<List<DiarioModel>> buscarDiariosRecentes({int limite = 10}) async {
    final db = await _databaseProvider();

    final diariosResult = await db.query(
      'diario',
      orderBy: 'data_hora DESC',
      limit: limite,
    );
    final diarios = diariosResult.map((m) => DiarioModel.fromMap(m)).toList();

    final crisesResult = await db.query(
      'crise',
      orderBy: 'data_hora_inicio DESC',
      limit: limite,
    );
    final crises = crisesResult
        .map((m) => _criseParaDiario(CriseModel.fromMap(m)))
        .toList();

    final todos = [...diarios, ...crises];
    todos.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return todos.take(limite).toList();
  }

  /// Busca diários E crises de um dia específico (ignora a hora).
  Future<List<DiarioModel>> buscarDiarioPorData(DateTime data) async {
    final db = await _databaseProvider();
    final inicioDoDia = DateTime(data.year, data.month, data.day);
    final fimDoDia = inicioDoDia.add(const Duration(days: 1));
    final inicioStr = inicioDoDia.toIso8601String();
    final fimStr = fimDoDia.toIso8601String();

    final diariosResult = await db.query(
      'diario',
      where: 'data_hora >= ? AND data_hora < ?',
      whereArgs: [inicioStr, fimStr],
    );
    final diarios = diariosResult.map((m) => DiarioModel.fromMap(m)).toList();

    final crisesResult = await db.query(
      'crise',
      where: 'data_hora_inicio >= ? AND data_hora_inicio < ?',
      whereArgs: [inicioStr, fimStr],
    );
    final crises = crisesResult
        .map((m) => _criseParaDiario(CriseModel.fromMap(m)))
        .toList();

    final todos = [...diarios, ...crises];
    todos.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return todos;
  }

  /// Retorna a crise com as listas de sintomas, gatilhos e medicamentos
  /// vinculados a ela (join pelas tabelas de relação N:N).
  Future<CriseCompleta?> buscarCriseCompleta(int idCrise) async {
    final db = await _databaseProvider();

    final criseRows = await db.query(
      'crise',
      where: 'id_crise = ?',
      whereArgs: [idCrise],
      limit: 1,
    );
    if (criseRows.isEmpty) return null;

    final sintomas = await db.rawQuery(
      '''
      SELECT cs.id_sintoma, cs.nome
      FROM catalogo_sintoma cs
      INNER JOIN crise_sintoma rel ON rel.id_sintoma = cs.id_sintoma
      WHERE rel.id_crise = ?
    ''',
      [idCrise],
    );

    final gatilhos = await db.rawQuery(
      '''
      SELECT cg.id_gatilho, cg.nome
      FROM catalogo_gatilho cg
      INNER JOIN crise_gatilho rel ON rel.id_gatilho = cg.id_gatilho
      WHERE rel.id_crise = ?
    ''',
      [idCrise],
    );

    final medicamentos = await db.rawQuery(
      '''
      SELECT cm.id_catalogo_medicamento, cm.nome
      FROM catalogo_medicamento cm
      INNER JOIN crise_medicamento rel
        ON rel.id_catalogo_medicamento = cm.id_catalogo_medicamento
      WHERE rel.id_crise = ?
    ''',
      [idCrise],
    );

    return CriseCompleta(
      crise: CriseModel.fromMap(criseRows.first),
      sintomas: sintomas.map((m) => SintomaModel.fromMap(m)).toList(),
      gatilhos: gatilhos.map((m) => GatilhoModel.fromMap(m)).toList(),
      medicamentos: medicamentos
          .map((m) => CatalogoMedicamentoModel.fromMap(m))
          .toList(),
    );
  }

  /// Lista o catálogo de sintomas (ordenado por nome).
  Future<List<SintomaModel>> buscarSintomas() async {
    final db = await _databaseProvider();
    final result = await db.query('catalogo_sintoma', orderBy: 'nome ASC');
    return result.map((map) => SintomaModel.fromMap(map)).toList();
  }

  /// Lista o catálogo de gatilhos (ordenado por nome).
  Future<List<GatilhoModel>> buscarGatilhos() async {
    final db = await _databaseProvider();
    final result = await db.query('catalogo_gatilho', orderBy: 'nome ASC');
    return result.map((map) => GatilhoModel.fromMap(map)).toList();
  }

  /// Lista o catálogo de medicamentos (ordenado por nome).
  Future<List<CatalogoMedicamentoModel>> buscarMedicamentos() async {
    final db = await _databaseProvider();
    final result = await db.query('catalogo_medicamento', orderBy: 'nome ASC');
    return result.map((map) => CatalogoMedicamentoModel.fromMap(map)).toList();
  }

  /// Busca diários E crises de um período (usado no calendário, por mês).
  Future<List<DiarioModel>> buscarDiariosPorPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _databaseProvider();
    final inicioStr = inicio.toIso8601String();
    final fimStr = fim.toIso8601String();

    final diariosResult = await db.query(
      'diario',
      where: 'data_hora >= ? AND data_hora < ?',
      whereArgs: [inicioStr, fimStr],
    );
    final diarios = diariosResult.map((m) => DiarioModel.fromMap(m)).toList();

    final crisesResult = await db.query(
      'crise',
      where: 'data_hora_inicio >= ? AND data_hora_inicio < ?',
      whereArgs: [inicioStr, fimStr],
    );
    final crises = crisesResult
        .map((m) => _criseParaDiario(CriseModel.fromMap(m)))
        .toList();

    final todos = [...diarios, ...crises];
    todos.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return todos;
  }

  /// Retorna o diário com os sintomas e gatilhos vinculados
  /// (join pelas tabelas de relação N:N), análogo ao buscarCriseCompleta.
  Future<DiarioCompleto?> buscarDiarioComRelacoes(int idDiario) async {
    final db = await _databaseProvider();

    final diarioRows = await db.query(
      'diario',
      where: 'id_diario = ?',
      whereArgs: [idDiario],
      limit: 1,
    );
    if (diarioRows.isEmpty) return null;

    final sintomas = await db.rawQuery(
      '''
      SELECT cs.id_sintoma, cs.nome
      FROM catalogo_sintoma cs
      INNER JOIN diario_sintoma rel ON rel.id_sintoma = cs.id_sintoma
      WHERE rel.id_diario = ?
    ''',
      [idDiario],
    );

    final gatilhos = await db.rawQuery(
      '''
      SELECT cg.id_gatilho, cg.nome
      FROM catalogo_gatilho cg
      INNER JOIN diario_gatilho rel ON rel.id_gatilho = cg.id_gatilho
      WHERE rel.id_diario = ?
    ''',
      [idDiario],
    );

    return DiarioCompleto(
      diario: DiarioModel.fromMap(diarioRows.first),
      sintomas: sintomas.map((m) => SintomaModel.fromMap(m)).toList(),
      gatilhos: gatilhos.map((m) => GatilhoModel.fromMap(m)).toList(),
    );
  }
}
