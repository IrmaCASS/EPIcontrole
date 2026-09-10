import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/providers/botao_crise_provider.dart';
import 'package:app/screens/mock_screen.dart';
import 'package:app/theme/app_theme.dart';

// ConsumerWidget possui a capacidade de "escutar" os Providers do Riverpod e se reconstruir automaticamente
class BotaoDeCrise extends ConsumerStatefulWidget {
  const BotaoDeCrise({super.key});

  @override
  ConsumerState<BotaoDeCrise> createState() => _BotaoDeCriseState();
}

class _BotaoDeCriseState extends ConsumerState<BotaoDeCrise>
    with SingleTickerProviderStateMixin {
  // Controlador da animação de pulsação do botão e dos anéis ao seu redor.
  late final AnimationController _pulseController;

  // Controla o "flash" em Branco Acinzentado (fade out) aplicado ao apertar o botão.
  bool _flashWhite = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Função auxiliar mantida dentro da UI apenas para formatar os segundos inteiros
  // no formato de cronômetro curto (MM:SS).
  String _formatDuration(int totalSeconds) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(totalSeconds ~/ 60);
    final seconds = twoDigits(totalSeconds % 60);
    return "$minutes:$seconds";
  }

  // Ação de clique: aplica o fade out (flash branco), inverte o estado do provider
  // e devolve o botão à opacidade normal.
  Future<void> _handleTap() async {
    setState(() => _flashWhite = true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    ref.read(criseProvider.notifier).toggleCrise();
    setState(() => _flashWhite = false);
  }

  // Anel expansivo da animação: cresce a partir da borda do botão, usando a
  // cor recebida da paleta do projeto, enquanto perde opacidade.
  Widget _buildExpandingRing(
    double value,
    double baseSize,
    Color color,
    int index,
  ) {
    // Cada anel é defasado em relação aos demais para criar um efeito sequencial.
    final progress = (value + index * 0.34) % 1.0;
    final size = baseSize + baseSize * 0.4 * progress;
    return Positioned.fill(
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: (1.0 - progress) * 0.8),
              width: 3,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sempre que o tempo passar lá no Provider (a cada 1 segundo), esta variável
    // avisa a tela para se desenhar de novo.
    final criseState = ref.watch(criseProvider);
    final isCrisisActive = criseState.isActive;
    final secondsElapsed = criseState.secondsElapsed;

    // Ao encerrar a crise (manual ou pelo limite de 5 minutos), navega direto
    // para o Diário de Crises (mock).
    ref.listen(criseProvider, (previous, next) {
      if (previous != null && previous.isActive && !next.isActive) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(MockScreen.route('Diário de Crise'));
        });
      }
    });

    // Inicia a pulsação quando a crise é iniciada e interrompe ao encerrar.
    if (isCrisisActive && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!isCrisisActive && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }

    // Tamanho do botão: 60% da tela em repouso e até 75% (70~80%) com crise ativa.
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonSize = isCrisisActive
        ? screenWidth * 0.75
        : screenWidth * 0.60;

    // Cores definidas pela paleta do Botão de Crise:
    // Lavanda em repouso; Roxo Escuro quando a crise está ativa.
    final Color primaryColor = isCrisisActive
        ? AppTheme.kRoxoEscuro
        : AppTheme.kLavanda;
    final Color glowColor = primaryColor.withValues(alpha: 0.3);
    final Color textColor = const Color(0xFF8B6B9E);

    return Column(
      // mainAxisSize.min instrui a coluna a ocupar apenas a altura estritamente
      // necessária por seus componentes internos.
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
        const SizedBox(height: 30), // Espaçamento vertical fixo de 30 pixels.
        // Botão
        // O GestureDetector serve para capturar a ação de clique do usuário
        // em qualquer coisa dentro dele.
        GestureDetector(
          onTap: _handleTap,
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final value = _pulseController.value;
                // Pulsação: a escala oscila suavemente entre 1.0 e ~1.05.
                final pulseScale =
                    1.0 + 0.05 * (0.5 - 0.5 * math.cos(2 * math.pi * value));
                return Stack(
                  // Clip.none permite que os anéis cresçam para fora do botão
                  // sem alterar o espaço ocupado no layout.
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Anéis expansivos na paleta do projeto (só com crise ativa).
                    if (isCrisisActive) ...[
                      _buildExpandingRing(
                        value,
                        buttonSize,
                        AppTheme.kLavanda,
                        0,
                      ),
                      _buildExpandingRing(
                        value,
                        buttonSize,
                        AppTheme.kRoxoEscuro,
                        1,
                      ),
                      _buildExpandingRing(
                        value,
                        buttonSize,
                        AppTheme.kBrancoAcizentado,
                        2,
                      ),
                    ],
                    Transform.scale(
                      alignment: Alignment.center,
                      scale: pulseScale,
                      child: child,
                    ),
                  ],
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: buttonSize, // Largura total do círculo principal.
                height: buttonSize, // Altura total do círculo principal.
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      primaryColor, // Aplica a cor variável baseada no estado.
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 2,
                  ),
                  // Lista de sombras que criam o aspecto de brilho ao redor do botão.
                  boxShadow: [
                    // Sombra grande e muito espalhada.
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 40,
                      spreadRadius: 15,
                    ),
                    // Sombra menor e mais concentrada perto da borda do botão.
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Conteúdo interno do botão (Raio, Cronômetro e Textos)
                    // AnimatedSwitcher faz o "fade out" do raio quando o cronômetro
                    // aparece, e vice-versa.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isCrisisActive
                          ? Column(
                              // Estado ativo: raio reduzido + cronômetro em MM:SS.
                              key: const ValueKey('crise'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.bolt,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDuration(secondsElapsed),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'PARAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Toque para encerrar',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              // Estado em repouso: raio grande centralizado.
                              key: const ValueKey('repouso'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.bolt,
                                  color: Colors.white,
                                  size: 72,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'BOTÃO DE CRISE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Toque para iniciar registro',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    // Camada superior do efeito de fade out: um círculo em
                    // Branco Acinzentado (kBrancoAcizentado) que surge ao apertar
                    // o botão e some em seguida.
                    IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _flashWhite ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.kBrancoAcizentado.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ), // Espaçamento abaixo do componente animado inteiro.
        // Rodapé informativo no estado ativo
        if (isCrisisActive)
          const Text(
            'Cronômetro ativo — ao encerrar, os dados serão salvos no Diário de Crises',
            textAlign: TextAlign
                .center, // Centraliza o texto caso ele quebre em duas linhas.
            style: TextStyle(color: AppTheme.kRoxoEscuro, fontSize: 14),
          ),
      ],
    );
  }
}
