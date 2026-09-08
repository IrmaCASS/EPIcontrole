// Arquivo: lib/widgets/menu_card.dart
import 'package:flutter/material.dart';

class MenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.onTap,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  // Escala aplicada ao card durante o toque para produzir o efeito "pop up".
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    // GestureDetector captura o clique no card inteiro
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      // AnimatedScale executa a "value animation" da escala entre o estado
      // apertado e solto, dando o feedback visual de pop up.
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16), // Bordas arredondadas do card
            // Adiciona uma sombra muito suave para destacar o card do fundo
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.3), // ~3% de opacidade
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza tudo verticalmente
            children: [
              // Círculo colorido que envolve o ícone
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 28),
              ),

              const SizedBox(height: 12), // Espaço entre o ícone e o texto

              // Texto descritivo do card (suporta múltiplas linhas por usar \n)
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}