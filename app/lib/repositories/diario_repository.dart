import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/crise_completa.dart';
import '../models/crise_model.dart';
import '../models/diario_model.dart';
import '../models/sintoma_model.dart';
import '../models/gatilho_model.dart';
import '../models/catalogo_medicamento_model.dart';

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
    await db.insert(
      'crise_sintoma',
      {'id_crise': idCrise, 'id_sintoma': idSintoma},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> vincularGatilhoACrise(int idCrise, int idGatilho) async {
    final db = await _databaseProvider();
    await db.insert(
      'crise_gatilho',
      {'id_crise': idCrise, 'id_gatilho': idGatilho},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> vincularMedicamentoACrise(
    int idCrise,
    int idCatalogoMedicamento,
  ) async {
    final db = await _databaseProvider();
    await db.insert(
      'crise_medicamento',
      {
        'id_crise': idCrise,
        'id_catalogo_medicamento': idCatalogoMedicamento,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<DiarioModel>> buscarDiariosRecentes({int limite = 10}) async {
    final db = await _databaseProvider();
    final result = await db.query(
      'diario',
      orderBy: 'data_hora DESC',
      limit: limite,
    );
    return result.map((map) => DiarioModel.fromMap(map)).toList();
  }

  /// Busca diários de um dia específico (ignora a hora).
  Future<List<DiarioModel>> buscarDiarioPorData(DateTime data) async {
    final db = await _databaseProvider();
    final inicioDoDia = DateTime(data.year, data.month, data.day);
    final fimDoDia = inicioDoDia.add(const Duration(days: 1));
    final result = await db.query(
      'diario',
      where: 'data_hora >= ? AND data_hora < ?',
      whereArgs: [
        inicioDoDia.toIso8601String(),
        fimDoDia.toIso8601String(),
      ],
      orderBy: 'data_hora ASC',
    );
    return result.map((map) => DiarioModel.fromMap(map)).toList();
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

    final sintomas = await db.rawQuery('''
      SELECT cs.id_sintoma, cs.nome
      FROM catalogo_sintoma cs
      INNER JOIN crise_sintoma rel ON rel.id_sintoma = cs.id_sintoma
      WHERE rel.id_crise = ?
    ''', [idCrise]);

    final gatilhos = await db.rawQuery('''
      SELECT cg.id_gatilho, cg.nome
      FROM catalogo_gatilho cg
      INNER JOIN crise_gatilho rel ON rel.id_gatilho = cg.id_gatilho
      WHERE rel.id_crise = ?
    ''', [idCrise]);

    final medicamentos = await db.rawQuery('''
      SELECT cm.id_catalogo_medicamento, cm.nome
      FROM catalogo_medicamento cm
      INNER JOIN crise_medicamento rel
        ON rel.id_catalogo_medicamento = cm.id_catalogo_medicamento
      WHERE rel.id_crise = ?
    ''', [idCrise]);

    return CriseCompleta(
      crise: CriseModel.fromMap(criseRows.first),
      sintomas: sintomas.map((m) => SintomaModel.fromMap(m)).toList(),
      gatilhos: gatilhos.map((m) => GatilhoModel.fromMap(m)).toList(),
      medicamentos: medicamentos
          .map((m) => CatalogoMedicamentoModel.fromMap(m))
          .toList(),
    );
  }
}