import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/contato_emergencia_model.dart';
import 'package:app/repositories/contato_emergencia_repository.dart';
import 'package:app/screens/editar_contato_screen.dart';
import 'package:app/screens/mock_screen.dart';
import 'package:app/theme/app_theme.dart';

/// Tela de Configurações: uma lista de opções do app.
/// O cadastro inicial do contato acontece no onboarding; aqui o usuário
/// apenas ALTERA o contato já existente.
class ConfiguracoesScreen extends ConsumerStatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  ConsumerState<ConfiguracoesScreen> createState() =>
      _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends ConsumerState<ConfiguracoesScreen> {
  final ContatoEmergenciaRepository _repository = ContatoEmergenciaRepository();

  bool _carregando = true;
  ContatoEmergencia? _contato;

  @override
  void initState() {
    super.initState();
    _carregarContato();
  }

  Future<void> _carregarContato() async {
    final db = await _repository.database;
    final result = await db.query(
      'contato_emergencia',
      where: 'id_paciente = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      _contato = ContatoEmergencia.fromMap(result.first);
    }

    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _abrirEdicao() async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const EditarContatoScreen()),
    );

    // Se a tela de edição retornou "true", recarrega o contato.
    if (salvou == true && mounted) {
      setState(() => _carregando = true);
      await _carregarContato();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSectionTitle(theme, 'Segurança'),
                _buildContatoItem(theme),
                const SizedBox(height: 24),
                _buildSectionTitle(theme, 'Preferências'),
                _buildSimpleItem(
                  theme,
                  icon: Icons.notifications_outlined,
                  title: 'Notificações',
                  subtitle: 'Lembretes de medicação e diário',
                  onTap: () => Navigator.of(
                    context,
                  ).push(MockScreen.route('Notificações')),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(theme, 'Sobre'),
                _buildSimpleItem(
                  theme,
                  icon: Icons.info_outline,
                  title: 'Sobre o App',
                  subtitle: 'Versão 1.0.0',
                  onTap: () => Navigator.of(
                    context,
                  ).push(MockScreen.route('Sobre o App')),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppTheme.kRoxoEscuro,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildContatoItem(ThemeData theme) {
    final temContato = _contato != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: temContato
          ? AppTheme.kRoxoEscuro.withValues(alpha: 0.05)
          : const Color(0xFFD32F2F).withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: temContato
              ? AppTheme.kRoxoEscuro.withValues(alpha: 0.15)
              : const Color(0xFFD32F2F).withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: temContato
              ? AppTheme.kRoxoEscuro.withValues(alpha: 0.15)
              : const Color(0xFFD32F2F).withValues(alpha: 0.15),
          child: Icon(
            temContato ? Icons.contact_phone : Icons.warning_amber_rounded,
            color: temContato ? AppTheme.kRoxoEscuro : const Color(0xFFD32F2F),
          ),
        ),
        title: Text(
          'Contato de Emergência',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: temContato ? AppTheme.kRoxoEscuro : const Color(0xFFD32F2F),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            temContato
                ? '${_contato!.nome ?? "Sem nome"} — ${_contato!.telefone}'
                : 'Nenhum contato cadastrado',
            style: TextStyle(
              color: temContato
                  ? Colors.black.withValues(alpha: 0.6)
                  : const Color(0xFFD32F2F),
            ),
          ),
        ),
        trailing: Icon(
          Icons.edit_outlined,
          color: temContato ? AppTheme.kRoxoEscuro : const Color(0xFFD32F2F),
        ),
        onTap: _abrirEdicao,
      ),
    );
  }

  Widget _buildSimpleItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppTheme.kRoxoEscuro),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
