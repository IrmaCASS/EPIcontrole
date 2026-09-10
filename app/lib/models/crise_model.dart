class CriseModel {
  final int? idCrise;
  final int idPaciente;
  final DateTime dataHoraInicio;
  final Duration? duracao;
  final String? tipoCrise;
  final String? turno;
  final String? sintomas;
  final String? prodromosAuras;
  final String? desencadeantes;
  final String? estadoPosIctal;
  final String? atividadeAntesCrise;
  final String? anotacoes;

  CriseModel({
    this.idCrise,
    this.idPaciente = 1,
    required this.dataHoraInicio,
    this.duracao,
    this.tipoCrise,
    this.turno,
    this.sintomas,
    this.prodromosAuras,
    this.desencadeantes,
    this.estadoPosIctal,
    this.atividadeAntesCrise,
    this.anotacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_crise': idCrise,
      'id_paciente': idPaciente,
      'data_hora_inicio': dataHoraInicio.toIso8601String(),
      'duracao_segundos': duracao?.inSeconds ?? 0,
      'tipo_crise': tipoCrise,
      'turno': turno,
      'sintomas': sintomas,
      'prodromos_auras': prodromosAuras,
      'desencadeantes': desencadeantes,
      'estado_pos_ictal': estadoPosIctal,
      'atividade_antes_crise': atividadeAntesCrise,
      'anotacoes': anotacoes,
    };
  }

  factory CriseModel.fromMap(Map<String, dynamic> map) {
    return CriseModel(
      idCrise: map['id_crise'] as int?,
      idPaciente: map['id_paciente'] as int,
      dataHoraInicio: DateTime.parse(map['data_hora_inicio'] as String),
      duracao: Duration(seconds: map['duracao_segundos'] as int? ?? 0),
      tipoCrise: map['tipo_crise'] as String?,
      turno: map['turno'] as String?,
      sintomas: map['sintomas'] as String?,
      prodromosAuras: map['prodromos_auras'] as String?,
      desencadeantes: map['desencadeantes'] as String?,
      estadoPosIctal: map['estado_pos_ictal'] as String?,
      atividadeAntesCrise: map['atividade_antes_crise'] as String?,
      anotacoes: map['anotacoes'] as String?,
    );
  }

  /// Facilita gerar cópias com detalhamento complementar (RF2),
  /// já que o registro rápido (RF1) cria a crise só com data/hora.
  CriseModel copyWith({
    String? tipoCrise,
    String? turno,
    String? sintomas,
    String? prodromosAuras,
    String? desencadeantes,
    String? estadoPosIctal,
    String? atividadeAntesCrise,
    String? anotacoes,
    Duration? duracao,
  }) {
    return CriseModel(
      idCrise: idCrise,
      idPaciente: idPaciente,
      dataHoraInicio: dataHoraInicio,
      duracao: duracao ?? this.duracao,
      tipoCrise: tipoCrise ?? this.tipoCrise,
      turno: turno ?? this.turno,
      sintomas: sintomas ?? this.sintomas,
      prodromosAuras: prodromosAuras ?? this.prodromosAuras,
      desencadeantes: desencadeantes ?? this.desencadeantes,
      estadoPosIctal: estadoPosIctal ?? this.estadoPosIctal,
      atividadeAntesCrise: atividadeAntesCrise ?? this.atividadeAntesCrise,
      anotacoes: anotacoes ?? this.anotacoes,
    );
  }
}