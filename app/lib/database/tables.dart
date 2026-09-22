/// Definições de DDL (Data Definition Language) do banco local do EPIcontrole.
///
/// Organizado por sprint para facilitar a evolução do banco:
/// - As tabelas da Sprint 1 já são criadas pelo [DatabaseHelper].
/// - As tabelas das próximas sprints já estão escritas aqui (baseadas no DER
///   do projeto), só precisam ser "ligadas" no _createDB / _onUpgrade do
///   DatabaseHelper quando chegar a hora de implementá-las.
class AppDatabaseTables {
  AppDatabaseTables._(); // classe estática, não instanciável

  // ---------------------------------------------------------------------
  // SPRINT 1 — Paciente & Crise (ativas)
  // ---------------------------------------------------------------------

  static const String paciente = '''
    CREATE TABLE paciente (
      id_paciente INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT,
      email TEXT,
      senha_hash TEXT,
      data_cadastro TEXT
    )
  ''';

  static const String crise = '''
    CREATE TABLE crise (
      id_crise INTEGER PRIMARY KEY AUTOINCREMENT,
      id_paciente INTEGER NOT NULL,
      data_hora_inicio TEXT NOT NULL,
      duracao_segundos INTEGER NOT NULL,
      tipo_crise TEXT,
      turno TEXT,
      sintomas TEXT,
      prodromos_auras TEXT,
      desencadeantes TEXT,
      estado_pos_ictal TEXT,
      atividade_antes_crise TEXT,
      anotacoes TEXT,
      FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
    )
  ''';

  /// Coluna adicionada na Sprint 2 (tela "Diário de Crises" — campo
  /// "Você estava? Dormindo / Acordado / Acordando"). Usada pelo
  /// DatabaseHelper._onUpgrade para quem já tinha o app instalado
  /// com a tabela `crise` na versão da Sprint 1 (sem essa coluna).
  static const String addColunaAtividadeAntesCrise =
      'ALTER TABLE crise ADD COLUMN atividade_antes_crise TEXT';

  // ---------------------------------------------------------------------
  // SPRINT 2 (planejadas — ainda não criadas pelo DatabaseHelper)
  // Baseadas no DER: Medicamento, Registro_Dose, Contato_Emergencia
  // ---------------------------------------------------------------------

  static const String medicamento = '''
    CREATE TABLE medicamento (
      id_medicamento INTEGER PRIMARY KEY AUTOINCREMENT,
      id_paciente INTEGER NOT NULL,
      nome TEXT NOT NULL,
      dosagem TEXT,
      frequencia_horarios TEXT,
      alertas_ativos INTEGER DEFAULT 1,
      FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
    )
  ''';

  static const String registroDose = '''
    CREATE TABLE registro_dose (
      id_registro_dose INTEGER PRIMARY KEY AUTOINCREMENT,
      id_medicamento INTEGER NOT NULL,
      data_hora_registro TEXT NOT NULL,
      status_tomada TEXT,
      FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento) ON DELETE CASCADE
    )
  ''';

  static const String contatoEmergencia = '''
    CREATE TABLE contato_emergencia (
      id_contato INTEGER PRIMARY KEY AUTOINCREMENT,
      id_paciente INTEGER NOT NULL,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL,
      FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
    )
  ''';

  // ---------------------------------------------------------------------
  // SPRINT 3 (planejada — ainda não criada pelo DatabaseHelper)
  // ---------------------------------------------------------------------

  static const String blocoNotas = '''
    CREATE TABLE bloco_notas (
      id_nota INTEGER PRIMARY KEY AUTOINCREMENT,
      id_paciente INTEGER NOT NULL,
      texto TEXT,
      data_criacao TEXT,
      FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
    )
  ''';

  // ---------------------------------------------------------------------
  // SPRINT — Diário de Crises: catálogos e relações N:N (ativa a partir
  // da v4). Diferente da coluna atividade_antes_crise (v2): aqui o
  // Diário vira uma entidade própria, com sintomas/gatilhos catalogados
  // e reutilizáveis tanto no diário quanto nas crises.
  // ---------------------------------------------------------------------

  static const String diario = '''
    CREATE TABLE diario (
      id_diario INTEGER PRIMARY KEY AUTOINCREMENT,
      id_paciente INTEGER NOT NULL,
      data_hora TEXT NOT NULL,
      anotacoes TEXT,
      FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
    )
  ''';

  static const String catalogoSintoma = '''
    CREATE TABLE catalogo_sintoma (
      id_sintoma INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL UNIQUE
    )
  ''';

  static const String catalogoGatilho = '''
    CREATE TABLE catalogo_gatilho (
      id_gatilho INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL UNIQUE
    )
  ''';

  /// Catálogo de referência de medicamentos associáveis a uma crise.
  /// Não confundir com a futura tabela `medicamento` (Sprint 2, ainda
  /// não criada), que guardará os medicamentos de uso contínuo do
  /// próprio paciente, com dosagem e frequência.
  static const String catalogoMedicamento = '''
    CREATE TABLE catalogo_medicamento (
      id_catalogo_medicamento INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL UNIQUE
    )
  ''';

  static const String diarioSintoma = '''
    CREATE TABLE diario_sintoma (
      id_diario INTEGER NOT NULL,
      id_sintoma INTEGER NOT NULL,
      PRIMARY KEY (id_diario, id_sintoma),
      FOREIGN KEY (id_diario) REFERENCES diario (id_diario) ON DELETE CASCADE,
      FOREIGN KEY (id_sintoma) REFERENCES catalogo_sintoma (id_sintoma) ON DELETE CASCADE
    )
  ''';

  static const String diarioGatilho = '''
    CREATE TABLE diario_gatilho (
      id_diario INTEGER NOT NULL,
      id_gatilho INTEGER NOT NULL,
      PRIMARY KEY (id_diario, id_gatilho),
      FOREIGN KEY (id_diario) REFERENCES diario (id_diario) ON DELETE CASCADE,
      FOREIGN KEY (id_gatilho) REFERENCES catalogo_gatilho (id_gatilho) ON DELETE CASCADE
    )
  ''';

  static const String criseSintoma = '''
    CREATE TABLE crise_sintoma (
      id_crise INTEGER NOT NULL,
      id_sintoma INTEGER NOT NULL,
      PRIMARY KEY (id_crise, id_sintoma),
      FOREIGN KEY (id_crise) REFERENCES crise (id_crise) ON DELETE CASCADE,
      FOREIGN KEY (id_sintoma) REFERENCES catalogo_sintoma (id_sintoma) ON DELETE CASCADE
    )
  ''';

  static const String criseGatilho = '''
    CREATE TABLE crise_gatilho (
      id_crise INTEGER NOT NULL,
      id_gatilho INTEGER NOT NULL,
      PRIMARY KEY (id_crise, id_gatilho),
      FOREIGN KEY (id_crise) REFERENCES crise (id_crise) ON DELETE CASCADE,
      FOREIGN KEY (id_gatilho) REFERENCES catalogo_gatilho (id_gatilho) ON DELETE CASCADE
    )
  ''';

  static const String criseMedicamento = '''
    CREATE TABLE crise_medicamento (
      id_crise INTEGER NOT NULL,
      id_catalogo_medicamento INTEGER NOT NULL,
      PRIMARY KEY (id_crise, id_catalogo_medicamento),
      FOREIGN KEY (id_crise) REFERENCES crise (id_crise) ON DELETE CASCADE,
      FOREIGN KEY (id_catalogo_medicamento) REFERENCES catalogo_medicamento (id_catalogo_medicamento) ON DELETE CASCADE
    )
  ''';
}