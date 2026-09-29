class GatilhoModel {
  final int? idGatilho;
  final String nome;

  const GatilhoModel({this.idGatilho, required this.nome});

  Map<String, Object?> toMap() => {'id_gatilho': idGatilho, 'nome': nome};

  factory GatilhoModel.fromMap(Map<String, Object?> map) => GatilhoModel(
        idGatilho: map['id_gatilho'] as int?,
        nome: map['nome'] as String,
      );
}