import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/diario_screen.dart';
import 'package:app/screens/medicamento_screen.dart';

import 'package:app/widgets/custom_bottom_nav_bar.dart';
import 'package:app/widgets/main_drawer.dart';

// ---- Provider para o índice
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return 1; // Valor inicial (Home)
  }

  void mudarAba(int novoIndice) {
    state = novoIndice;
  }
}
final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(() {
  return TabIndexNotifier();
});

class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta a mudança de abas através do Riverpod (substitui o setState local)
    final selectedIndex = ref.watch(tabIndexProvider);

    // -Definição da ordem das telas
    // Índices: 0 = (Diário), 1 = (Home), 2 = (Medicamentos)
    final List<Widget> screens = const [
      DiarioScreen(),      // Índice 0:
      HomeScreen(),        // Índice 1: (Tela inicial)
      MedicamentoScreen(), // Índice 2:
    ];

    // -Títulos dinâmicos que acompanham a mudança de abas
    final List<String> titles = [
      'Diário de Crises',
      'EpiControle',
      'Medicamentos',
    ];

    return Scaffold(
      // AppBar, caso no futuro queira-se uma barra mais personalizavel talvez seja
      // interessante fazer um widget separado
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.jpeg'),
              radius: 16,
            ),
            const SizedBox(width: 12), // Espaço entre a logo e o texto
            Text(titles[selectedIndex]),
          ],
        ),
        actions: [
          // Futuro: Adicionar ícone de notificações ou atalhos rápidos aqui
          //exemplo
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),

      // Drawer ( menu lateral )
      drawer: const MainDrawer(),

      // Corpo usando IndexedStack
      // Isso garante que o estado das abas não mude caso mude para outra e volte.
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onSelect: (index) {
          // Atualiza o índice globalmente via Riverpod
          ref.read(tabIndexProvider.notifier).mudarAba(index);        },
      ),
    );
  }
}

