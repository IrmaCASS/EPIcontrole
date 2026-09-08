import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/medicamento_screen.dart';
import 'package:app/screens/configuracoes_screen.dart';

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
    // Índices: 0 = (Remédios), 1 = (Início), 2 = (Configurações)
    final List<Widget> screens = const [
      MedicamentoScreen(), // Índice 0:
      HomeScreen(), // Índice 1: (Tela inicial)
      ConfiguracoesScreen(), // Índice 2:
    ];

    // -Títulos dinâmicos que acompanham a mudança de abas
    final List<String> titles = ['Remédios', 'EpiControle', 'Configurações'];

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
      ),

      // Drawer ( menu lateral )
      // A opção "Início" seleciona a aba do Botão de Crise (Início), como no NavBar.
      drawer: MainDrawer(
        onSelectInicio: () {
          ref.read(tabIndexProvider.notifier).mudarAba(1);
        },
      ),

      // Corpo usando IndexedStack
      // Isso garante que o estado das abas não mude caso mude para outra e volte.
      body: IndexedStack(index: selectedIndex, children: screens),

      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onSelect: (index) {
          // Atualiza o índice globalmente via Riverpod
          ref.read(tabIndexProvider.notifier).mudarAba(index);
        },
      ),
    );
  }
}
