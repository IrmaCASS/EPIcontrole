class SintomaModel {
  final int? idSintoma;
  final String nome;

  const SintomaModel({this.idSintoma, required this.nome});

  Map<String, Object?> toMap() => {'id_sintoma': idSintoma, 'nome': nome};

  factory SintomaModel.fromMap(Map<String, Object?> map) => SintomaModel(
        idSintoma: map['id_sintoma'] as int?,
        nome: map['nome'] as String,
      );
}