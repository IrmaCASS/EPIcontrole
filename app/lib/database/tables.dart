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
}