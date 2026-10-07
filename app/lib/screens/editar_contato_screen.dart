import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/contato_emergencia_model.dart';
import 'package:app/repositories/contato_emergencia_repository.dart';
import 'package:app/theme/app_theme.dart';

/// Tela para ALTERAR o contato de emergência (cadastrado no onboarding).
class EditarContatoScreen extends ConsumerStatefulWidget {
  const EditarContatoScreen({super.key});

  @override
  ConsumerState<EditarContatoScreen> createState() =>
      _EditarContatoScreenState();
}

class _EditarContatoScreenState extends ConsumerState<EditarContatoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();

  final ContatoEmergenciaRepository _repository = ContatoEmergenciaRepository();

  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarContatoExistente();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _carregarContatoExistente() async {
    final db = await _repository.database;
    final result = await db.query(
      'contato_emergencia',
      where: 'id_paciente = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final contato = ContatoEmergencia.fromMap(result.first);
      _nomeController.text = contato.nome ?? '';
      _telefoneController.text = contato.telefone;
    }

    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final contato = ContatoEmergencia(
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.trim(),
      );
      await _repository.salvarContatoPrincipal(contato);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contato de emergência atualizado!'),
          backgroundColor: Color(0xFF27AE60),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true); // Retorna true = "salvou"
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
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.contact_phone, color: AppTheme.kRoxoEscuro, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Alterar Contato',
                style: TextStyle(
                  color: AppTheme.kRoxoEscuro,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Esse contato será discado automaticamente 5 segundos após o início de uma crise.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),

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
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9()\-\s]'),
                        ),
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
                    const SizedBox(height: 32),

                    // Botão Salvar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _salvando ? null : _salvar,
                        icon: _salvando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _salvando ? 'SALVANDO...' : 'SALVAR ALTERAÇÃO',
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
