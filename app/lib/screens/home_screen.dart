import 'package:flutter/material.dart';
import 'package:app/widgets/botao_de_crise.dart';
import 'package:app/widgets/menu_card.dart';
import 'package:app/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Resgata o tema de textos configurado globalmente no AppTheme
    final textTheme = Theme.of(context).textTheme;

    // Retorna um SingleChildScrollView para permitir a rolagem fluida da página inicial,
    // já que o layout principal é renderizado dentro do TabsScreen (que possui a AppBar e Navbar).
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha os elementos internos à esquerda
        children: [
          const SizedBox(height: 40),
          // CENTRO: Botão de Crise
          // Envolvido por um Center para posicionar o botão exatamente no meio horizontal da tela.
          const Center(
            child: BotaoDeCrise(),
          ),
          const SizedBox(height: 100),
          // SEÇÃO: Título do Menu Principal
          Text(
            'MENU PRINCIPAL',
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          // GRADE DE CARDS (Menu Principal)
          GridView.count(
            // shrinkWrap permite que o GridView ajuste sua altura com base nos elementos filhos,
            // para evitar conflitos de layout dentro de um SingleChildScrollView.
            shrinkWrap: true,
            // Desativa a rolagem própria do Grid, delegando a rolagem inteiramente para a tela principal.
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // 2 colunas de cards por linha
            crossAxisSpacing: 16, // Espaçamento horizontal entre os cards
            mainAxisSpacing: 16, // Espaçamento vertical entre os cards
            childAspectRatio: 1.5, // Proporção de tamanho entre largura e altura dos cards
            children: [
              // MenuCard(
              //   title: 'Diário de\nCrises',
              //   icon: Icons.menu_book,
              //   iconColor: AppTheme.primaryPurple, // Cor principal do tema para o ícone
              //   iconBackgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.1), // Fundo translúcido com opacidade
              //   onTap: () {
              //     // TODO: Implementar navegação para a tela do Diário de Crises
              //   },
              // ),
              // MenuCard(
              //   title: 'Diário de\nMedicamentos',
              //   icon: Icons.medication_outlined,
              //   iconColor: const Color(0xFF2D9CDB), // Cor azul customizada de destaque
              //   iconBackgroundColor: const Color(0xFF2D9CDB).withValues(alpha: 0.1),
              //   onTap: () {
              //     // TODO: Implementar navegação para a tela de Medicamentos
              //   },
              // ),
              MenuCard(
                title: 'Relatórios',
                icon: Icons.bar_chart,
                iconColor: const Color(0xFF27AE60), // Cor verde customizada de destaque
                iconBackgroundColor: const Color(0xFF27AE60).withValues(alpha: 0.1),
                onTap: () {
                  // TODO: Implementar navegação para a tela de Relatórios
                },
              ),
              MenuCard(
                title: 'Registrar Nova Crise',
                icon: Icons.app_registration,
                iconColor: const Color(0xFF4F4F4F), // Cor cinza customizada para ajustes
                iconBackgroundColor: const Color(0xFFF4C033).withValues(alpha: 0.3),
                onTap: () {
                  // TODO: Implementar navegação para a tela de Configurações/Perfil
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}