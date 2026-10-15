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

// TODO BACKEND: Implementar os métodos toMap e fromMap para integrar ao SQLite
// (Lembre-se de juntar a lista de horários usando join(',') no toMap e split(',') no fromMap).
}