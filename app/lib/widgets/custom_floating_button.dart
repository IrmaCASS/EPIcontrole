// Arquivo: lib/widgets/custom_floating_button.dart
import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {
  final String legenda;
  final IconData icone;
  final Color corTema;
  final VoidCallback onPressed;
  final String heroTag;
  final bool isExpanded; // Controla se a legenda animada lateral aparece

  const CustomFloatingButton({
    super.key,
    required this.legenda,
    required this.icone,
    required this.corTema,
    required this.onPressed,
    required this.heroTag,
    this.isExpanded = false, // Por padrão o texto expandido fica oculto
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // A legenda envolta em animações de opacidade e tamanho
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isExpanded ? 1.0 : 0.0,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: isExpanded
                ? Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  legenda,
                  style: TextStyle(
                    color: corTema,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ),
        // O Botão Flutuante (Sempre visível)
        FloatingActionButton(
          heroTag: heroTag,
          backgroundColor: corTema,
          elevation: 2,
          tooltip: legenda, // Exibe o texto padrão do sistema ao manter pressionado (long press)
          // Nota: O "shape" customizado foi removido para herdar o formato
          // quadrado arredondado (Squircle) padrão do Material 3 do app.
          onPressed: onPressed,
          child: Icon(icone, color: Colors.white),
        ),
      ],
    );
  }
}