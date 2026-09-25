// ============================================================================
// INTEGRAÇÃO DO DISCADOR DE EMERGÊNCIA — botao_crise_provider.dart
// ============================================================================
//
// Este arquivo não é standalone: é o trecho pronto para colar dentro do
// seu botao_crise_provider.dart, já que esse arquivo não foi enviado.
//
// Passos:
// 1) Copie os imports abaixo para o topo do botao_crise_provider.dart
// 2) Copie o campo _contatoRepository e o método _abrirDiscadorEmergencia()
//    para dentro da classe do provider
// 3) Dentro de _stopCrisis(), chame await _abrirDiscadorEmergencia() na
//    posição indicada (depois do try/catch de inserirCrise, antes de
//    setar isActive: false)
// ============================================================================

// --- 1) IMPORTS (adicionar no topo do arquivo) -----------------------------
import 'package:url_launcher/url_launcher.dart';
import '../repositories/contato_emergencia_repository.dart';

// --- 2) CAMPO + MÉTODO (adicionar dentro da classe do provider) ------------
class BotaoCriseProviderDiscadorMixin {
  final ContatoEmergenciaRepository _contatoRepository =
      ContatoEmergenciaRepository();

  // Abre o discador nativo com o telefone do contato de emergência
  // principal. NÃO liga automaticamente — apenas preenche o número e
  // deixa o usuário tocar em "ligar".
  Future<void> _abrirDiscadorEmergencia() async {
    final telefone = await _contatoRepository.buscarTelefonePrincipal();

    if (telefone == null || telefone.isEmpty) {
      // Nenhum contato cadastrado ainda — não faz nada.
      // (Opcional: expor um callback/estado aqui para a UI avisar o
      // usuário que ele ainda não cadastrou um contato de emergência.)
      return;
    }

    final Uri telUri = Uri(scheme: 'tel', path: telefone);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      // Dispositivo não conseguiu abrir o discador (raro, mas possível).
      // Logar ou expor erro para a UI, se necessário.
    }
  }

  // --- 3) EXEMPLO DE USO DENTRO DE _stopCrisis() ----------------------------
  Future<void> exemploStopCrisis() async {
    // try {
    //   await _criseRepository.inserirCrise(crise);
    // } catch (e) {
    //   // tratamento de erro existente
    // }

    await _abrirDiscadorEmergencia(); // <-- chamada na posição combinada

    // ... aqui continua o código que seta isActive: false, etc.
  }
}
