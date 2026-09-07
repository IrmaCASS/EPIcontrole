import 'package:flutter/material.dart';

/// Widget separado para o Menu Lateral (Drawer)
/// Futuro: Para adicionar navegação para telas de Configurações, Perfil, logout, etc.
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
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
            leading: const Icon(Icons.person),
            //Exemplo:
            title: const Text('Meu Perfil'),
            onTap: () {
              //Navigator.pop(context) e push para ir para PerfilScreen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              //
            },
          ),
        ],
      ),
    );
  }
}