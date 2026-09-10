import 'package:flutter/material.dart';

class AppTheme {
  // --- Cores principais da Paleta EPIcontrole ---
  static const Color primaryPurple = Color(0xFF5B3089); // Roxo Profundo
  static const Color accentLilac = Color(0xFFA389D3); // Lilás (Lavanda)
  static const Color backgroundLight = Color(0xFFF2F2F2); // Cinza Claro (Branco Gelo)

  // --- Paleta do Botão de Crise ---
  static const Color kLavanda = Color(0xFFA389D3); // Lavanda (botão em repouso)
  static const Color kRoxoEscuro = Color(0xFF5B3089); // Roxo Escuro (crise ativa)
  static const Color kBrancoAcizentado = Color(0xFFF2F2F2); // Branco Acinzentado (fade out)

  // Cor mantida para bordas inativas muito suaves (opcional)
  static const Color cardBorderLight = Color(0xFFEBE4F2);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryPurple,
      scaffoldBackgroundColor: backgroundLight, // Aplicando o Cinza Claro/Branco Gelo

      // Configuração da AppBar (títulos à esquerda, sem fundo)
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primaryPurple),
        titleTextStyle: TextStyle(
          color: primaryPurple,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),

      // Tipografia global
      textTheme: const TextTheme(
        // Títulos de seção como "MENU PRINCIPAL"
        labelSmall: TextStyle(
          color: accentLilac, // Aplicando o Lilás para textos secundários/subtítulos
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
        bodyLarge: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: primaryPurple, fontWeight: FontWeight.w600),
      ),

      // Botões preenchidos(selecionados)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Botões contornados(não selecionados)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentLilac, // Aplicando o Lilás nos botões não selecionados
          side: const BorderSide(color: cardBorderLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Tema da barra de navegação
      navigationBarTheme: NavigationBarThemeData(
        // Cor da pílula de seleção (roxo principal com opacidade)
        indicatorColor: primaryPurple.withValues(alpha: 0.15),

        // Estilo dos Ícones dinâmico
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryPurple, size: 28);
          }
          return const IconThemeData(color: accentLilac, size: 28); // Ícones inativos em Lilás
        }),

        // Estilo dos Textos dinâmico
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            );
          }
          return const TextStyle(
            color: accentLilac, // Textos inativos em Lilás
            fontWeight: FontWeight.normal,
            fontSize: 12,
          );
        }),
      ),
    );
  }
}