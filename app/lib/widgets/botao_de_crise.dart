import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/providers/botao_crise_provider.dart';
import 'package:app/theme/app_theme.dart';

// ConsumerWidget possui a capacidade de "escutar" os Providers do Riverpod e se reconstruir automaticamente
class BotaoDeCrise extends ConsumerWidget {
  const BotaoDeCrise({super.key});

  // Função auxiliar mantida dentro da UI apenas para formatar os segundos inteiros no formato de relógio (HH:MM:SS).
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    // String completa que será exibida no meio do botão.
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // O metodo build do ConsumerWidget recebe um segundo parâmetro: o 'WidgetRef ref'.
  // Esse 'ref' é a ponte de comunicação entre a tela visual e a lógica que está no Provider.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sempre que o tempo passar lá no Provider (a cada 1 segundo), esta variável avisa a tela para se desenhar de novo.
    final criseState = ref.watch(criseProvider);
    final isCrisisActive = criseState.isActive;
    final secondsElapsed = criseState.secondsElapsed;

    // Definição das cores baseadas no estado atual do botão:
    // Fica vermelho (Color(0xFFC62828)) se a crise estiver ativa, ou roxo se estiver inativa.
    final Color primaryColor = isCrisisActive ? const Color(0xFFC62828) : AppTheme.primaryPurple;
    final Color glowColor = primaryColor.withValues(alpha: 0.3); // Define a cor da sombra externa criando uma versão mais transparente da cor principal (usando alpha para opacidade).
    // Cor roxa clara padronizada para o texto do título superior.
    final Color textColor = const Color(0xFF8B6B9E);

    return Column(
      // mainAxisSize.min instrui a coluna a ocupar apenas a altura estritamente necessária por seus componentes internos.
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título superior que altera seu texto de acordo com o estado do app.
        Text(
          isCrisisActive ? 'CRISE EM ANDAMENTO' : 'BOTÃO DE CRISE',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 30),  // Espaçamento vertical fixo de 30 pixels.

        // Botão
        // O GestureDetector serve para capturar a ação de clique do usuário em qualquer coisa dentro dele.
        GestureDetector(
          // O onTap é a ação do clique. Ele lê o provider e aciona a função de inverter o estado (toggle).
          onTap: () => ref.read(criseProvider.notifier).toggleCrise(),
          // AnimatedContainer troca da cor roxa para a vermelha de forma suave
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 250, // Largura total do círculo principal.
            height: 250, // Altura total do círculo principal.
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor, // Aplica a cor variável baseada no estado.
              border: Border.all(color: Colors.white.withValues(alpha: 0.1),width: 2,),
              // Lista de sombras que criam o aspecto de brilho ao redor do botão.
              boxShadow: [
                // Sombra grande e muito espalhada.
                BoxShadow(color: glowColor, blurRadius: 40, spreadRadius: 15),
                // Sombra menor e mais concentrada perto da borda do botão.
                BoxShadow(color: primaryColor.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5),
              ],
            ),
            // Conteúdo interno do botão (Textos e Ícones)
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone de raio no estado inativo: Se a crise NÃO (!) estiver ativa, ele renderiza
                if (!isCrisisActive) ...[
                  Container(
                    padding: const EdgeInsets.all(12), // Espaçamento entre o ícone e sua própria borda.
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2), // Círculo de fundo translúcido para o raio
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12), // Espaçamento entre o raio e o texto
                ],
                // Texto Principal (Botão ou Cronômetro) centralizado:
                // Exibe a formatação HH:MM:SS quando ativado, ou a palavra 'BOTÃO DE CRISE' quando em repouso
                Text(
                  isCrisisActive ? _formatDuration(secondsElapsed) : 'BOTÃO DE CRISE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCrisisActive ? 42 : 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: isCrisisActive ? 2.0 : 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtítulo de ação
                // Palavra "PARAR" renderizada unicamente se a crise estiver rodando
                if (isCrisisActive)
                  const Text(
                      'PARAR',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                // Subtítulo inferior em texto menor com opacidade ajustada, fornecendo a instrução contextual de clique
                Text(
                  isCrisisActive ? 'Toque para encerrar' : 'Toque para iniciar registro',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30), // Espaçamento abaixo do componente animado inteiro.
        // Rodapé informativo no estado ativo
        if (isCrisisActive)
          const Text(
            'Cronômetro ativo — ao encerrar, os dados serão salvos no Diário de Crises',
            textAlign: TextAlign.center, // Centraliza o texto caso ele quebre em duas linhas.
            style: TextStyle(color: Color(0xFFC62828), fontSize: 14),
          ),
      ],
    );
  }
}