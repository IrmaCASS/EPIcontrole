class CatalogoMedicamentoModel {
  final int? idCatalogoMedicamento;
  final String nome;

  const CatalogoMedicamentoModel({
    this.idCatalogoMedicamento,
    required this.nome,
  });

  Map<String, Object?> toMap() => {
        'id_catalogo_medicamento': idCatalogoMedicamento,
        'nome': nome,
      };

  factory CatalogoMedicamentoModel.fromMap(Map<String, Object?> map) =>
      CatalogoMedicamentoModel(
        idCatalogoMedicamento: map['id_catalogo_medicamento'] as int?,
        nome: map['nome'] as String,
      );
}