class PacienteModel {
  final int? idPaciente;
  final String nome;
  final String? email;
  final String? senhaHash;
  final DateTime dataCadastro;

  PacienteModel({
    this.idPaciente,
    required this.nome,
    this.email,
    this.senhaHash,
    DateTime? dataCadastro,
  }) : dataCadastro = dataCadastro ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id_paciente': idPaciente,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'data_cadastro': dataCadastro.toIso8601String(),
    };
  }

  factory PacienteModel.fromMap(Map<String, dynamic> map) {
    return PacienteModel(
      idPaciente: map['id_paciente'] as int?,
      nome: map['nome'] as String? ?? 'Usuário Local',
      email: map['email'] as String?,
      senhaHash: map['senha_hash'] as String?,
      dataCadastro: DateTime.parse(map['data_cadastro'] as String),
    );
  }
}