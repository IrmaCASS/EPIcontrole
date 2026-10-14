import 'package:flutter/material.dart';
import 'package:app/screens/tela_boas_vindas.dart';

/// ============================================================================
/// TELA DE SPLASH COM ANIMAÇÃO DA LOGO
/// A logo cresce e esmaece até sumir, revelando a tela de boas-vindas.
/// ============================================================================
class TelaSplash extends StatefulWidget {
  const TelaSplash({super.key});

  @override
  State<TelaSplash> createState() => _TelaSplashState();
}

class _TelaSplashState extends State<TelaSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Cor de fundo do splash (mesmo tom do quadrado da logo)
  static const Color _corFundo = Color(0xFF4A148C);

  @override
  void initState() {
    super.initState();

    // Duração total: 1.5 segundos
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );

    // A logo cresce de 1.0 até 15.0 (ocupa a tela toda)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Visível nos primeiros 20% do tempo, depois esmaece até sumir
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 80,
      ),
    ]).animate(_controller);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const TelaBoasVindas(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corFundo,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: SizedBox(
            height: 140,
            width: 140,
            child: Image.asset(
              'assets/images/logo_transparente.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
