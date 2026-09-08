import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';

/// Página de mock (em branco) usada pelas opções que ainda serão
/// implementadas com lógica de negócio no futuro.
class MockScreen extends StatelessWidget {
  final String title;

  const MockScreen({super.key, required this.title});

  /// Rota com transição "pop up": a página escala de forma suave
  /// enquanto faz fade in, criando o efeito de surgir na tela.
  static Route<void> route(String title) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          MockScreen(title: title),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 72,
              color: AppTheme.accentLilac,
            ),
            SizedBox(height: 16),
            Text(
              'Página em construção',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}