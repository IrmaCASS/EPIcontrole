class MedicamentoModel {
  final int? idMedicamento;
  final int idPaciente;
  final String nome;
  final String? dosagem;
  final List<String> horarios; // Salvo no banco como String separada por vírgulas e convertemos
  final bool alertasAtivos;

  MedicamentoModel({
    this.idMedicamento,
    this.idPaciente = 1,
    required this.nome,
    this.dosagem,
    required this.horarios,
    this.alertasAtivos = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (idMedicamento != null) 'id_medicamento': idMedicamento,
      'id_paciente': idPaciente,
      'nome': nome,
      'dosagem': dosagem,
      'frequencia_horarios': horarios.join(','),
      'alertas_ativos': alertasAtivos ? 1 : 0,
    };
  }

  factory MedicamentoModel.fromMap(Map<String, dynamic> map) {
    final horariosTexto = (map['frequencia_horarios'] as String?) ?? '';
    return MedicamentoModel(
      idMedicamento: map['id_medicamento'] as int?,
      idPaciente: map['id_paciente'] as int,
      nome: map['nome'] as String,
      dosagem: map['dosagem'] as String?,
      horarios: horariosTexto.isEmpty
          ? []
          : horariosTexto.split(',').map((h) => h.trim()).toList(),
      alertasAtivos: (map['alertas_ativos'] as int? ?? 1) == 1,
    );
  }
}