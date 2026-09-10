import 'package:flutter/material.dart';
import 'package:app/screens/mock_screen.dart';

/// Widget separado para o Menu Lateral (Drawer)
/// Contém as opções das telas principais; todas levam para páginas de mock
/// (em branco) até que a lógica de negócio seja implementada.
class MainDrawer extends StatelessWidget {
  // Callback acionado pela opção "Início", para navegar à aba do Botão de
  // Crise da mesma forma que o NavBar.
  final VoidCallback? onSelectInicio;

  const MainDrawer({super.key, this.onSelectInicio});

  // Fecha o drawer e navega para a página de mock correspondente.
  void _navigateToMock(BuildContext context, String title) {
    Navigator.pop(context); // Fecha o drawer
    Navigator.of(context).push(MockScreen.route(title));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.health_and_safety, color: Colors.white, size: 48),
                SizedBox(height: 10),
                Text(
                  'Menu Principal',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              onSelectInicio?.call(); // Vai para a aba do Botão de Crise
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Diário de Crises'),
            onTap: () => _navigateToMock(context, 'Diário de Crises'),
          ),
          ListTile(
            leading: const Icon(Icons.medical_services_outlined),
            title: const Text('Medicamentos'),
            onTap: () => _navigateToMock(context, 'Medicamentos'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Relatórios'),
            onTap: () => _navigateToMock(context, 'Relatórios'),
          ),
          ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Registrar Nova Crise'),
            onTap: () => _navigateToMock(context, 'Registrar Nova Crise'),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Meu Perfil'),
            onTap: () => _navigateToMock(context, 'Meu Perfil'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            onTap: () => _navigateToMock(context, 'Configurações'),
          ),
        ],
      ),
    );
  }
}
