import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/crise_model.dart';
import 'package:app/repositories/crise_repository.dart';

/// Provider que carrega as crises do banco.
/// Cada vez que a tela abre, ele busca as últimas crises registradas.
final crisesProvider = FutureProvider<List<CriseModel>>((ref) async {
  final repo = CriseRepository();
  return await repo.buscarUltimasCrises(limite: 50);
});

class DiarioScreen extends ConsumerWidget {
  const DiarioScreen({super.key});

  /// Rota com transição "pop up": mesma animação do MockScreen,
  /// usada quando o botão de crise encerra.
  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const DiarioScreen(),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final crisesAsync = ref.watch(crisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Crises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(crisesProvider),
          ),
        ],
      ),
      body: crisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erro ao carregar crises: $err'),
        ),
        data: (crises) {
          if (crises.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 80, color: Colors.blueAccent),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma crise registrada',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: crises.length,
            itemBuilder: (context, index) {
              final crise = crises[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.bolt, color: Colors.purple),
                  title: Text(
                    _formatarData(crise.dataHoraInicio),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Duração: ${_formatarDuracao(crise.duracao)}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatarData(DateTime data) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
  }

  String _formatarDuracao(Duration? d) {
    if (d == null) return '--';
    final min = d.inMinutes.toString().padLeft(2, '0');
    final seg = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$seg';
  }
}