import 'package:flutter/material.dart';
import 'package:app/screens/tabs_screen.dart';
import 'package:app/screens/tela_login.dart';
import 'package:app/services/auth_service.dart';

/// ============================================================================
/// TELA DE CADASTRO
/// ============================================================================
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;
  bool _aceitouTermos = false;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, informe seu nome completo';
    }
    if (valor.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, informe seu e-mail';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(valor.trim())) {
      return 'Informe um e-mail válido (ex: nome@email.com)';
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, crie uma senha';
    }
    if (valor.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  String? _validarConfirmacaoSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (valor != _senhaController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  Future<void> _efetuarCadastro() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, concorde com os Termos de Uso e Privacidade.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    final resultado = await AuthService.cadastrar(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    if (!mounted) return;

    setState(() {
      _carregando = false;
    });

    if (resultado.sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  resultado.mensagem,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TabsScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensagem),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar ao Início',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo do App
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_add_alt_1,
                            size: 60,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Cadastro',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preencha seus dados para criar sua conta',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Nome Completo
                    TextFormField(
                      controller: _nomeController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: _validarNome,
                      decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        hintText: 'Ex: Carlos Silva',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // E-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validarEmail,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'seu.email@exemplo.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Senha
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _senhaOculta,
                      textInputAction: TextInputAction.next,
                      validator: _validarSenha,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Mínimo 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaOculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _senhaOculta = !_senhaOculta;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmar Senha
                    TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: _confirmarSenhaOculta,
                      textInputAction: TextInputAction.done,
                      validator: _validarConfirmacaoSenha,
                      onFieldSubmitted: (_) => _efetuarCadastro(),
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        hintText: 'Repita a senha',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmarSenhaOculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmarSenhaOculta = !_confirmarSenhaOculta;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Checkbox de Termos
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _aceitouTermos,
                            onChanged: (val) {
                              setState(() {
                                _aceitouTermos = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _aceitouTermos = !_aceitouTermos;
                              });
                            },
                            child: Text(
                              'Li e concordo com os Termos de Uso e Privacidade',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botão Cadastrar
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _efetuarCadastro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _carregando
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Voltar ao Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já possui uma conta?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const TelaLogin(),
                              ),
                            );
                          },
                          child: const Text(
                            'Fazer login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
