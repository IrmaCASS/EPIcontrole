// app/lib/services/discador_emergencia_service.dart
import 'package:url_launcher/url_launcher.dart';

import '../repositories/contato_emergencia_repository.dart';

/// Abre o discador nativo com o telefone do contato de emergência principal.
/// NÃO liga automaticamente: só preenche o número e o usuário toca em "ligar".
class DiscadorEmergenciaService {
  final ContatoEmergenciaRepository _contatoRepository;

  DiscadorEmergenciaService({ContatoEmergenciaRepository? contatoRepository})
      : _contatoRepository = contatoRepository ?? ContatoEmergenciaRepository();

  /// Retorna true se o discador foi aberto; false se não há contato
  /// cadastrado ou se o aparelho não conseguiu abrir o discador.
  Future<bool> abrirDiscador() async {
    final telefone = await _contatoRepository.buscarTelefonePrincipal();

    if (telefone == null || telefone.trim().isEmpty) {
      return false;
    }

    final Uri telUri = Uri(scheme: 'tel', path: telefone.trim());

    if (await canLaunchUrl(telUri)) {
      return launchUrl(telUri);
    }
    return false;
  }
}
