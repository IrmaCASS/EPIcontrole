# EPIcontrole

Aplicativo de autocuidado para pessoas com epilepsia. Permite registrar crises por meio de um **Botão de Crise**, acompanhar diários (crises e medicamentos), gerar relatórios e acessar configurações.

> Status atual: **esqueleto do sistema** + **Botão de Crise** (navegação e telas de mock em branco). A lógica de negócio e a persistência (banco de dados) ainda serão implementadas pelo time de back end.

## Implementação da tela principal + botão de crise

Nesta etapa foi implementada a **tela principal (Home)** e o **Botão de Crise** com suas animações e navegação:

- **Tela principal (Home):** contém o Botão de Crise centralizado e o **Menu Principal** com os cards `Relatórios` e `Registrar Nova Crise`, que abrem **páginas de mock (em branco)** com animação do tipo **pop up**.
- **Botão de Crise:**
  - Ocupa **60% da largura da tela** em repouso e **cresce para ~75%** (70–80%) quando a crise é iniciada.
  - Cores da paleta: `kLavanda` (repouso) e `kRoxoEscuro` (crise ativa).
  - Ao ser clicado, apresenta um **flash de fade out** em `kBrancoAcizentado`, **anéis expansivos** ao redor do botão nas cores da paleta (`kLavanda`, `kRoxoEscuro`, `kBrancoAcizentado`) e **animação de pulsação** (escala contínua).
  - Cronômetro em **MM:SS**, com **limite de 5 minutos**; novo toque encerra antes do limite. Ao encerrar, navega direto para o **Diário de Crise** (mock).
- **Navegação:** as abas inferiores são `Remédios`, `Início` (botão de crise) e `Configurações`. No **menu hambúrguer**, a opção `Início` leva à tela do Botão de Crise (mesma aba do NavBar) e as demais opções levam a páginas de mock.
- **Usabilidade:** quando o botão de crise é clicado e cresce/pulsa, o espaço para o **Menu Principal** é ampliado para que os cards não sejam encobertos pela barra de navegação inferior.

## Tecnologias

- **Flutter** (Dart) — app mobile (Android/iOS)
- **Riverpod** (`flutter_riverpod`) — gerenciamento de estado global
- **SQLite** (futuro, via `database_helper.dart` — esboço já disposto em `app/lib/database`)
- **Material 3** — tema/clara

## Estrutura de pastas

```
EPIcontrole/
├─ README.md                    # Documentação do projeto
├─ app/                         # Aplicativo Flutter
│  ├─ lib/
│  │  ├─ main.dart              # Entrada do app (ProviderScope + MaterialApp)
│  │  ├─ screens/               # Telas
│  │  │  ├─ tabs_screen.dart        # Scaffold principal (AppBar, Drawer, abas)
│  │  │  ├─ home_screen.dart        # Tela inicial (Botão de Crise + Menu Principal)
│  │  │  ├─ medicamento_screen.dart # Aba Remédios
│  │  │  ├─ configuracoes_screen.dart # Aba Configurações
│  │  │  ├─ diario_screen.dart      # Placeholder do Diário de Crises
│  │  │  └─ mock_screen.dart        # Página de mock (em branco) reaproveitável
│  │  ├─ widgets/               # Componentes reutilizáveis
│  │  │  ├─ botao_de_crise.dart      # Botão de Crise (cronômetro + animações)
│  │  │  ├─ custom_bottom_nav_bar.dart # Barra de navegação inferior
│  │  │  ├─ main_drawer.dart         # Menu hambúrguer (todas as opções)
│  │  │  └─ menu_card.dart           # Card do Menu Principal (com animação pop up)
│  │  ├─ providers/             # Estado global (Riverpod)
│  │  │  └─ botao_crise_provider.dart # Estado/lógica do Botão de Crise
│  │  ├─ theme/
│  │  │  └─ app_theme.dart           # Paleta de cores e tema Material 3
│  │  ├─ models/                # (esboço) modelos de dados (.txt)
│  │  ├─ database/              # (esboço) DatabaseHelper/SQLite (.txt)
│  │  └─ services/              # (esboço) serviços externos (SMS, áudio) (.txt)
│  ├─ android/                  # Projeto Android nativo
│  ├─ ios/                      # Projeto iOS nativo
│  ├─ assets/images/            # logo.jpeg
│  └─ pubspec.yaml              # Dependências
├─ design/                      # Prints e referências de design
├─ docs/                        # Documentação complementar
└─ sprints/                     # Planejamento por sprint
```

## Navegação atual

- **AppBar** exibe o logo e o título da aba ativa (sem ícone de notificações).
- **Tabs inferiores (NavBar):** `Remédios` / `Início` / `Configurações`.
- **Menu hambúrguer (Drawer):** Início, Diário de Crises, Medicamentos, Relatórios, Registrar Nova Crise, Meu Perfil e Configurações — todas levam para **páginas de mock (em branco)**.
- **Menu Principal (Home):** cards `Relatórios` e `Registrar Nova Crise` levam para páginas de mock com animação do tipo **pop up** (escala + fade).

## Botão de Crise — comportamento implementado

| Requisito | Como está |
|---|---|
| Tamanho | 60% da largura da tela em repouso; cresce para ~75% (70–80%) com crise ativa |
| Cores | `kLavanda` em repouso ↔ `kRoxoEscuro` durante crise |
| Fade out ao apertar | Flash em `kBrancoAcizentado` que surge e some ao tocar, usando a paleta `[kLavanda, kRoxoEscuro, kBrancoAcizentado]` |
| Raio (`Icons.bolt`) | Grande (72) em repouso, diminui (28) quando o cronômetro aparece |
| Fundo do raio | O próprio botão (sem bolinha separada) |
| Cronômetro | Formato **MM:SS** (somente minutos e segundos) |
| Tempo máximo | 5 minutos (300 s) — encerra automaticamente e redireciona |
| Encerrar antes | Segundo toque para antes dos 5 minutos |
| Ao parar | Navega direto para o **Diário de Crises** (mock) |

### Paleta do Botão de Crise (`app/lib/theme/app_theme.dart`)

```dart
static const Color kLavanda         = Color(0xFFA389D3); // Lavanda (repouso)
static const Color kRoxoEscuro      = Color(0xFF5B3089); // Roxo Escuro (crise ativa)
static const Color kBrancoAcizentado = Color(0xFFF2F2F2); // Branco Acinzentado (fade out)
```

## Variáveis que o time de back end precisa

Contrato de dados gerado pela camada de front end (estado em `app/lib/providers/botao_crise_provider.dart`):

```dart
// Classe CriseState — estado observável pelo botão
class CriseState {
  bool isActive;              // true = crise em andamento / false = em repouso
  int  secondsElapsed;        // segundos decorridos da crise atual (1 tick/seg)
  int  lastCrisisDuration;    // duração da última crise encerrada (segundos)
}

// Lógica (CriseNotifier)
int _maxCrisisDuration = 300; // tempo máximo da crise: 5 minutos em segundos
```

| Variável | Tipo | Descrição / uso esperado no back end |
|---|---|---|
| `isActive` | `bool` | Sinaliza se há crise em andamento. Pode bloquear novo registro ou disparar alerta. |
| `secondsElapsed` | `int` | Cronômetro da crise atual (incrementado a cada segundo). Base do tempo real de duração. |
| `lastCrisisDuration` | `int` | Duração (em segundos) da última crise, já formatável em MM:SS. **usada para persistir** a crise no Diário. |
| `_maxCrisisDuration` | `int` | Limite de 5 min (300 s); ao atingir, o app encerra e redireciona ao Diário de Crises. |
| `toggleCrise()` | `método` | Inicia/encerra a crise conforme o estado atual (`_startCrisis` / `_stopCrisis`). |
| `duracaoFinal` | `int` (local) | Cópia de `secondsElapsed` usada ao encerrar; a ser enviada ao banco quando o `DatabaseService` existir. |

### Pendências de integração (TODOs no código)

- **`services/`**: disparar SMS/GPS aos contatos de emergência e tocar alarme sonoro ao iniciar crise.
- **`database/`**: salvar a crise encerrada em SQLite (usar `isActive=false`, `duracaoFinal`/`lastCrisisDuration`, data/hora).
- **Páginas mock** (`mock_screen.dart`): Relatórios, Registrar Nova Crise, Diário de Crises, Configurações, Perfil — aguardam dados/lógica do back end.
- **Modelos** (`models/*.txt`): definir `Usuario` e `Crise` (esboços vazios).

## Como rodar

```bash
cd app
flutter pub get
flutter run          # escolha um dispositivo (ex.: emulador Android)
```

Build de debug: `flutter build apk --debug` → `app/build/app/outputs/flutter-apk/app-debug.apk`

## implementando o CRUD do banco de dados

Nesta etapa foi implementado o **CRUD do banco de dados** para as entidades atuais (`paciente` e `crise`) e a **integração do Botão de Crise com o SQLite**:

### Estrutura adicionada

- `app/lib/models/paciente_model.dart` — modelo da entidade `Paciente` (`toMap`, `fromMap`, `copyWith`).
- `app/lib/models/crise_model.dart` — modelo da entidade `Crise` (`toMap`, `fromMap`, `copyWith`).
- `app/lib/database/database_helper.dart` — conexão com o SQLite (`epicontrole.db`), criação das tabelas `paciente` e `crise`, `PRAGMA foreign_keys = ON` e seed do usuário de teste (id 1).
- `app/lib/repositories/paciente_repository.dart` — CRUD completo de `Paciente` (`inserirPaciente`, `buscarPacientePorId`, `buscarPacientePorEmail`, `buscarTodos`, `atualizarPaciente`, `excluirPaciente`).
- `app/lib/repositories/crise_repository.dart` — CRUD completo de `Crise` (`inserirCrise`, `buscarCrisePorId`, `buscarTodasCrises`, `buscarUltimasCrises`, `atualizarCrise`, `excluirCrise`, `contarCrisesUltimos7Dias`).
- Removidos os esboços `.txt` de `models/` e `database/`.
- `pubspec.yaml` — adicionadas as dependências `sqflite ^2.3.0` e `path ^1.9.0`.

### Integração com o Botão de Crise

- `app/lib/providers/botao_crise_provider.dart` agora registra o **início da crise** (`data_hora_inicio`) e, ao encerrar (novo toque **ou** limite de 5 minutos), persiste a crise no SQLite por meio de `CriseRepository.inserirCrise`, atribuindo a crise ao **usuário de teste (id 1)**.
- O fluxo do cronômetro (iniciar/parar/limite) permanece o que já existia.