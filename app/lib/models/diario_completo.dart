import 'diario_model.dart';
import 'sintoma_model.dart';
import 'gatilho_model.dart';

/// Um diário junto com os sintomas e gatilhos vinculados a ele
/// (resultado de DiarioRepository.buscarDiarioComRelacoes).
class DiarioCompleto {
  final DiarioModel diario;
  final List<SintomaModel> sintomas;
  final List<GatilhoModel> gatilhos;

  const DiarioCompleto({
    required this.diario,
    required this.sintomas,
    required this.gatilhos,
  });
}
