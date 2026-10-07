class ContatoEmergencia {
  final int? idContato;
  final int idPaciente;
  final String? nome;
  final String telefone;

  ContatoEmergencia({
    this.idContato,
    // MVP é single-paciente: segue o mesmo padrão do "Usuário Teste" (id 1)
    // já inserido em DatabaseHelper._createDB(). Quando o app passar a
    // suportar múltiplos pacientes, troque esse default por um valor real.
    this.idPaciente = 1,
    this.nome,
    required this.telefone,
  });

  Map<String, dynamic> toMap() {
    return {
      if (idContato != null) 'id_contato': idContato,
      'id_paciente': idPaciente,
      'nome': nome,
      'telefone': telefone,
    };
  }

  factory ContatoEmergencia.fromMap(Map<String, dynamic> map) {
    return ContatoEmergencia(
      idContato: map['id_contato'] as int?,
      idPaciente: map['id_paciente'] as int,
      nome: map['nome'] as String?,
      telefone: map['telefone'] as String,
    );
  }

  ContatoEmergencia copyWith({
    int? idContato,
    int? idPaciente,
    String? nome,
    String? telefone,
  }) {
    return ContatoEmergencia(
      idContato: idContato ?? this.idContato,
      idPaciente: idPaciente ?? this.idPaciente,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
    );
  }
}
