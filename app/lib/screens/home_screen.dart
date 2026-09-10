import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/widgets/botao_de_crise.dart';
import 'package:app/widgets/menu_card.dart';
import 'package:app/screens/mock_screen.dart';
import 'package:app/providers/botao_crise_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resgata o tema de textos configurado globalmente no AppTheme
    final textTheme = Theme.of(context).textTheme;
    // Acompanha se a crise está ativa para liberar espaço ao Menu Principal.
    final isCrisisActive = ref.watch(criseProvider).isActive;

    // Retorna um SingleChildScrollView para permitir a rolagem fluida da página inicial,
    // já que o layout principal é renderizado dentro do TabsScreen (que possui a AppBar e Navbar).
    return SingleChildScrollView(
      // Padding inferior maior para a última linha de cards nunca ficar
      // encoberta pela barra de navegação inferior.
      padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 120.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinha os elementos internos à esquerda
        children: [
          const SizedBox(height: 40),
          // CENTRO: Botão de Crise
          // Envolvido por um Center para posicionar o botão exatamente no meio horizontal da tela.
          const Center(child: BotaoDeCrise()),
          // Com a crise ativa o botão cresce e pulsa; o espaço aumenta para que
          // as opções do Menu Principal não sejam encobertas.
          SizedBox(height: isCrisisActive ? 150 : 100),
          // SEÇÃO: Título do Menu Principal
          Text('MENU PRINCIPAL', style: textTheme.labelSmall),
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
            childAspectRatio:
                1.5, // Proporção de tamanho entre largura e altura dos cards
            children: [
              MenuCard(
                title: 'Relatórios',
                icon: Icons.bar_chart,
                iconColor: const Color(
                  0xFF27AE60,
                ), // Cor verde customizada de destaque
                iconBackgroundColor: const Color(
                  0xFF27AE60,
                ).withValues(alpha: 0.1),
                onTap: () {
                  Navigator.of(context).push(MockScreen.route('Relatórios'));
                },
              ),
              MenuCard(
                title: 'Registrar Nova Crise',
                icon: Icons.app_registration,
                iconColor: const Color(
                  0xFF4F4F4F,
                ), // Cor cinza customizada para ajustes
                iconBackgroundColor: const Color(
                  0xFFF4C033,
                ).withValues(alpha: 0.3),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MockScreen.route('Registrar Nova Crise'));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
