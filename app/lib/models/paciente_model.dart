class Paciente {
  final int? idPaciente;
  final String? nome;
  final String? email;
  final String? senhaHash;
  final DateTime? dataCadastro;

  const Paciente({
    this.idPaciente,
    this.nome,
    this.email,
    this.senhaHash,
    this.dataCadastro,
  });

  Map<String, dynamic> toMap() {
    return {
      if (idPaciente != null) 'id_paciente': idPaciente,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'data_cadastro': dataCadastro?.toIso8601String(),
    };
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      idPaciente: map['id_paciente'] as int?,
      nome: map['nome'] as String?,
      email: map['email'] as String?,
      senhaHash: map['senha_hash'] as String?,
      dataCadastro: map['data_cadastro'] != null
          ? DateTime.parse(map['data_cadastro'] as String)
          : null,
    );
  }

  Paciente copyWith({
    int? idPaciente,
    String? nome,
    String? email,
    String? senhaHash,
    DateTime? dataCadastro,
  }) {
    return Paciente(
      idPaciente: idPaciente ?? this.idPaciente,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senhaHash: senhaHash ?? this.senhaHash,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }
}