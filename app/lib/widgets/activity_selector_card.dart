import 'package:flutter/material.dart';

/// Widget responsável por renderizar o cartão "Você estava?" (Dormindo, Acordado, Acordando).
class ActivitySelectorCard extends StatelessWidget {
  final String? atividadeSelecionada;
  final ValueChanged<String> onSelected;

  const ActivitySelectorCard({
    super.key,
    required this.atividadeSelecionada,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final Color darkText = const Color(0xFF2B1C4C);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Você estava?', style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildOpcaoAtividade(
                    titulo: 'Dormindo',
                    icone: Icons.bed_outlined,
                    corAtiva: const Color(0xFF1E67D6), // Azul
                    fundoInativo: const Color(0xFFF6F2FA),
                    isSelected: atividadeSelecionada == 'Dormindo',
                    onTap: () => onSelected('Dormindo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOpcaoAtividade(
                    titulo: 'Acordado',
                    icone: Icons.show_chart_rounded,
                    corAtiva: const Color(0xFF3F8241), // Verde
                    fundoInativo: const Color(0xFFF6F2FA),
                    isSelected: atividadeSelecionada == 'Acordado',
                    onTap: () => onSelected('Acordado'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOpcaoAtividade(
                    titulo: 'Acordando',
                    icone: Icons.wb_twilight_rounded,
                    corAtiva: const Color(0xFFD65C00), // Laranja
                    fundoInativo: const Color(0xFFF6F2FA),
                    isSelected: atividadeSelecionada == 'Acordando',
                    onTap: () => onSelected('Acordando'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Constrói individualmente as opções do cartão "Você estava?".
  Widget _buildOpcaoAtividade({
    required String titulo,
    required IconData icone,
    required Color corAtiva,
    required Color fundoInativo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? corAtiva.withValues(alpha: 0.1) : fundoInativo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? corAtiva : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? corAtiva : const Color(0xFFEAE4F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icone,
                color: isSelected ? Colors.white : const Color(0xFF7A609E),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color: isSelected ? corAtiva : const Color(0xFF7A609E),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}