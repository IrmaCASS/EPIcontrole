class ResultadoAuth {
  final bool sucesso;
  final String mensagem;
  final Map<String, dynamic>? dados;

  ResultadoAuth({
    required this.sucesso,
    required this.mensagem,
    this.dados,
  });
}

class AuthService {
  // --------------------------------------------------------------------------
  // CONTROLE DE MODO:
  // - true: 100% Front-end (Mock local com delay, sem precisar de servidor rodando)
  // - false: Conexão real HTTP/REST com o servidor back-end
  // --------------------------------------------------------------------------
  static const bool usarMockLocal = true;

  // URL base da sua API (Node.js, Python, Java, PHP, etc.)
  static const String baseUrl = 'https://sua-api.com/api';

  /// Servico de Cadastro de Novo Usuário
  static Future<ResultadoAuth> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    if (usarMockLocal) {
      // Simulação 100% Front-End
      await Future.delayed(const Duration(milliseconds: 1200));

      return ResultadoAuth(
        sucesso: true,
        mensagem: 'Conta criada com sucesso para $nome!',
        dados: {
          'id': 'usr_9981',
          'nome': nome,
          'email': email,
          'token': 'mock_jwt_token_frontend_xyz',
        },
      );
    } else {
      return ResultadoAuth(
        sucesso: false,
        mensagem: 'Ative o pacote http no pubspec.yaml para conectar ao servidor.',
      );
    }
  }

  /// Servico de Login de Usuário
  static Future<ResultadoAuth> login({
    required String email,
    required String senha,
  }) async {
    if (usarMockLocal) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return ResultadoAuth(
        sucesso: true,
        mensagem: 'Login efetuado com sucesso!',
        dados: {'email': email},
      );
    } else {
      return ResultadoAuth(
        sucesso: true,
        mensagem: 'Login conectado com API',
      );
    }
  }
}
