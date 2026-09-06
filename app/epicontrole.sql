-- =======================================================================
-- EPIcontrole — Banco de Dados (Sprint 1: Paciente + Crise)
-- Versão definitiva do schema para validação.
-- =======================================================================

-- 1. ATIVA CHAVE ESTRANGEIRA
-- (Sem isso, o ON DELETE CASCADE e a verificação de integridade não funcionam)
PRAGMA foreign_keys = ON;

-- =======================================================================
-- 2. CRIAÇÃO DAS TABELAS (Sprint 1)
-- =======================================================================

-- Tabela PACIENTE
-- Guarda os dados do usuário do app (local).
CREATE TABLE IF NOT EXISTS paciente (
  id_paciente INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT,
  email TEXT,
  senha_hash TEXT,
  data_cadastro TEXT
);

-- Tabela CRISE (versão atualizada com o campo solicitado)
-- Os campos 'sintomas' e 'turno' estão mantidos, mas não serão usados agora.
CREATE TABLE IF NOT EXISTS crise (
  id_crise INTEGER PRIMARY KEY AUTOINCREMENT,
  id_paciente INTEGER NOT NULL,
  data_hora_inicio TEXT NOT NULL,      -- Data e horário do início
  duracao_segundos INTEGER NOT NULL,   -- Duração total em segundos
  tipo_crise TEXT,                     -- Ex: Focal, Tônico-clônica, etc.
  turno TEXT,                          -- (Não usado na Sprint 1, mas mantido)
  sintomas TEXT,                       -- (Não usado na Sprint 1, mas mantido)
  prodromos_auras TEXT,                -- "Aviso da crise" (checklist)
  desencadeantes TEXT,                 -- "Possíveis gatilhos" (checklist)
  estado_pos_ictal TEXT,               -- "Condição pós-crise" (checklist)
  atividade_antes_crise TEXT,          -- NOVO: "Você estava?" (Dormindo/Acordado/Acordando)
  anotacoes TEXT,                      -- "Campo adicional" e observações livres

  FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON DELETE CASCADE
);

-- =======================================================================
-- 3. DADOS DE TESTE (paciente local e exemplos)
-- =======================================================================

-- Insere um paciente fictício para você testar as crises
INSERT INTO paciente (id_paciente, nome, data_cadastro)
VALUES (1, 'Usuário Teste', datetime('now'));

-- =======================================================================
-- 4. COMANDOS PARA TESTAR (Descomente e execute um por vez)
-- =======================================================================

-- --- 4.1 Inserir uma crise DETALHADA (simulando o RF2) ---
-- INSERT INTO crise (
--   id_paciente, data_hora_inicio, duracao_segundos,
--   tipo_crise, prodromos_auras, desencadeantes, estado_pos_ictal,
--   atividade_antes_crise, anotacoes
-- ) VALUES (
--   1, datetime('now', '-2 hours'), 180,
--   'Focal', 'Dormência, Medo', 'Estresse, Privação de sono',
--   'Confusão mental, Sonolência', 'Acordado', 'Paciente relatou aura visual'
-- );

-- --- 4.2 Inserir uma crise RÁPIDA (simulando o RF1 - só data/hora) ---
-- INSERT INTO crise (id_paciente, data_hora_inicio, duracao_segundos)
-- VALUES (1, datetime('now'), 0);

-- --- 4.3 Consultar as últimas crises (ordenadas da mais nova pra mais antiga) ---
-- SELECT * FROM crise ORDER BY data_hora_inicio DESC LIMIT 5;

-- --- 4.4 Testar a FOREIGN KEY (isso DEVE dar erro de constraint) ---
-- INSERT INTO crise (id_paciente, data_hora_inicio, duracao_segundos)
-- VALUES (99, datetime('now'), 10);

-- --- 4.5 Contar crises dos últimos 7 dias (base para o relatório RF19) ---
-- SELECT COUNT(*) AS total_crises
-- FROM crise
-- WHERE data_hora_inicio BETWEEN datetime('now', '-7 days') AND datetime('now');