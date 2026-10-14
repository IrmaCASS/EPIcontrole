import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/contato_emergencia_model.dart';
import 'package:app/repositories/contato_emergencia_repository.dart';
import 'package:app/screens/tabs_screen.dart';
import 'package:app/theme/app_theme.dart';

/// Tela de ONBOARDING: cadastro inicial do contato de emergência.
/// Aparece uma única vez, logo após o cadastro do usuário.
/// Não tem opção de "pular" — o contato é essencial para o Botão de Crise.
class OnboardingContatoScreen extends ConsumerStatefulWidget {
  const OnboardingContatoScreen({super.key});

  @override
  ConsumerState<OnboardingContatoScreen> createState() =>
      _OnboardingContatoScreenState();
}

class _OnboardingContatoScreenState
    extends ConsumerState<OnboardingContatoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();

  final ContatoEmergenciaRepository _repository = ContatoEmergenciaRepository();

  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarEContinuar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final contato = ContatoEmergencia(
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.trim(),
      );
      await _repository.salvarContatoPrincipal(contato);

      if (!mounted) return;
      // Substitui a tela atual pela Home (não pode voltar para o onboarding)
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const TabsScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone decorativo
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.kRoxoEscuro.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.contact_phone,
                      color: AppTheme.kRoxoEscuro,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Título
                Center(
                  child: Text(
                    'Uma última coisa importante',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.kRoxoEscuro,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtítulo explicativo
                Text(
                  'Para sua segurança, precisamos saber para quem ligar em caso de crise. '
                  'Esse contato será discado automaticamente 5 segundos após você iniciar o registro de uma crise.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Campo Nome
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-ZÀ-ÿ\s'\-]"),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Nome do contato',
                    hintText: 'Ex: Maria Silva',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do contato';
                    }
                    if (value.trim().length < 2) {
                      return 'Nome muito curto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo Telefone
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9()\-\s]')),
                    _TelefoneInputFormatter(),
                  ],
                  maxLength: 15,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        required maxLength,
                      }) {
                        final digits = _telefoneController.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        return Text(
                          '${digits.length}/11',
                          style: TextStyle(
                            color: digits.length == 11
                                ? const Color(0xFF27AE60)
                                : Colors.black.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        );
                      },
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(11) 98765-4321',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o telefone';
                    }
                    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length < 10) {
                      return 'Telefone incompleto (mínimo 10 dígitos com DDD)';
                    }
                    if (digits.length > 11) {
                      return 'Telefone muito longo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Botão Salvar e continuar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _salvando ? null : _salvarEContinuar,
                    icon: _salvando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _salvando ? 'SALVANDO...' : 'SALVAR E CONTINUAR',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.kRoxoEscuro,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Formatter que aplica máscara de telefone brasileiro automaticamente.
class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    final buffer = StringBuffer();

    if (limited.isEmpty) {
      return const TextEditingValue(text: '');
    }

    if (limited.length <= 2) {
      buffer.write('($limited');
    } else if (limited.length <= 6) {
      buffer.write('(${limited.substring(0, 2)}) ');
      buffer.write(limited.substring(2));
    } else if (limited.length <= 10) {
      buffer.write('(${limited.substring(0, 2)}) ');
      buffer.write(limited.substring(2, 6));
      buffer.write('-');
      buffer.write(limited.substring(6));
    } else {
      buffer.write('(${limited.substring(0, 2)}) ');
      buffer.write(limited.substring(2, 7));
      buffer.write('-');
      buffer.write(limited.substring(7));
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
