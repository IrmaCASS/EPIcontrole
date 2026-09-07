import 'package:flutter/material.dart';

/// Widget separado para a Barra de Navegação Inferior
/// Futuro: Facilita a substituição por pacotes como 'curved_navigation_bar',
/// botões flutuantes centrais ou animações complexas sem afetar a TabsScreen.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onSelect;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        // Cria o efeito flutuante desgrudando das laterais e do fundo
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          // Opcional: Adiciona um feedback visual e esconde labels não selecionadas
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onSelect,
            height: 75,
            elevation: 0,
            backgroundColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book),
                label: 'Diário',
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services),
                label: 'Remédios',
              ),
            ],
          ),
        ),
      ),
    );
  }
}