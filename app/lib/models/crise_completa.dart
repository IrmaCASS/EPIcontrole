import 'crise_model.dart';
import 'sintoma_model.dart';
import 'gatilho_model.dart';
import 'catalogo_medicamento_model.dart';

/// Uma crise junto com os sintomas, gatilhos e medicamentos vinculados a
/// ela (resultado de DiarioRepository.buscarCriseCompleta).
class CriseCompleta {
  final CriseModel crise;
  final List<SintomaModel> sintomas;
  final List<GatilhoModel> gatilhos;
  final List<CatalogoMedicamentoModel> medicamentos;

  const CriseCompleta({
    required this.crise,
    required this.sintomas,
    required this.gatilhos,
    required this.medicamentos,
  });
}