class Paciente {
  final int? idPaciente;
  final String? nome;
  final String? email;
  final String? senhaHash;
  final DateTime? dataCadastro;

  Paciente({
    this.idPaciente,
    this.nome,
    this.email,
    this.senhaHash,
    this.dataCadastro,
  });

  // Converte o objeto Dart para um Map (formato aceito pelo SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (idPaciente != null) 'id_paciente': idPaciente,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'data_cadastro': dataCadastro?.toIso8601String(),
    };
  }

  // Cria um objeto Dart a partir de um Map vindo do banco de dados
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
}
