class DiarioModel {
  final int? idDiario;
  final int idPaciente;
  final DateTime dataHora;
  final String? anotacoes;

  const DiarioModel({
    this.idDiario,
    required this.idPaciente,
    required this.dataHora,
    this.anotacoes,
  });

  Map<String, Object?> toMap() {
    return {
      'id_diario': idDiario,
      'id_paciente': idPaciente,
      'data_hora': dataHora.toIso8601String(),
      'anotacoes': anotacoes,
    };
  }

  factory DiarioModel.fromMap(Map<String, Object?> map) {
    return DiarioModel(
      idDiario: map['id_diario'] as int?,
      idPaciente: map['id_paciente'] as int,
      dataHora: DateTime.parse(map['data_hora'] as String),
      anotacoes: map['anotacoes'] as String?,
    );
  }

  DiarioModel copyWith({
    int? idDiario,
    int? idPaciente,
    DateTime? dataHora,
    String? anotacoes,
  }) {
    return DiarioModel(
      idDiario: idDiario ?? this.idDiario,
      idPaciente: idPaciente ?? this.idPaciente,
      dataHora: dataHora ?? this.dataHora,
      anotacoes: anotacoes ?? this.anotacoes,
    );
  }
}