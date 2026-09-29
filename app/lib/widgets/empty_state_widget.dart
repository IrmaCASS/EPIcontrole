import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';

/// Widget reutilizável para exibir um estado vazio estilizado (Ex: Nenhum registro encontrado).
class EmptyStateWidget extends StatelessWidget {
  final String mensagem;
  final IconData icone;

  const EmptyStateWidget({
    super.key,
    this.mensagem = 'Nenhum registro para o dia.',
    this.icone = Icons.history_edu_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 75),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.accentLilac.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  icone,
                  size: 80,
                  color: AppTheme.primaryPurple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              mensagem,
              style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryPurple.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }
}