import 'package:flutter/material.dart';
import 'package:app/screens/tela_login.dart';
import 'package:app/screens/tela_cadastro.dart';

/// ============================================================================
/// TELA DE BOAS-VINDAS (WELCOME SCREEN)
/// ============================================================================
class TelaBoasVindas extends StatelessWidget {
  const TelaBoasVindas({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 32.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logotipo de Boas-Vindas com a imagem logo.jpeg
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.auto_awesome,
                            size: 44,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título principal
                  Text(
                    'Seu diário de crises,',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'sempre com você.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Botão 1: Fazer Login
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TelaLogin(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'Fazer Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Botão 2: Criar Nova Conta
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TelaCadastro(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text(
                        'Criar Nova Conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),

                  // Frase de apoio (uma linha só, discreta, centralizada)
                  Text(
                    'Acompanhe crises e medicamentos com facilidade.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
