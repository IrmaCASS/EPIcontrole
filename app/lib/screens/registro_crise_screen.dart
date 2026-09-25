import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/crise_model.dart';
import 'package:flutter/services.dart';
import 'package:app/widgets/activity_selector_card.dart';
import 'package:app/widgets/multi_select_expandable_card.dart';
import 'package:app/providers/botao_crise_provider.dart';
import 'package:app/providers/registro_crise_provider.dart';
import 'package:app/models/diario_model.dart';

// ============================================================================
// WIDGET PRINCIPAL: TELA DE REGISTRO DE CRISE
// ============================================================================
class RegistroCriseScreen extends ConsumerStatefulWidget {
  const RegistroCriseScreen({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (_) => const RegistroCriseScreen());
  }

  @override
  ConsumerState<RegistroCriseScreen> createState() =>
      _RegistroCriseScreenState();
}

class _RegistroCriseScreenState extends ConsumerState<RegistroCriseScreen> {
  // --- Estados do Formulário (Variáveis básicas de tempo e duração) ---
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  // --- Controladores para Duração ---
  final TextEditingController _minutosController = TextEditingController();
  final TextEditingController _segundosController = TextEditingController();

  // --- Controladores para capturar o texto dos campos "Outro" ---
  final TextEditingController _outroAvisoController = TextEditingController();
  final TextEditingController _outroGatilhoController = TextEditingController();
  final TextEditingController _outroPosCriseController =
      TextEditingController();

  final TextEditingController _outroSintomaController = TextEditingController();
  final TextEditingController _outroMedicamentoController =
      TextEditingController();

  // --- Variáveis que guardam a seleção  (Radio/Dropdown) ---
  String? _atividadeSelecionada;
  String? _tipoCriseSelecionado;

  // --- Variáveis que guardam seleções múltiplas (Checkboxes) ---
  final Set<String> _gatilhosSelecionados = {};
  final Set<String> _condicoesPosCriseSelecionadas = {};
  final Set<String> _avisosSelecionados = {};
  final Set<String> _sintomasSelecionados = {};
  final Set<String> _medicamentosSelecionados = {};

  // --- Listas de opções fixas que populam a interface gráfica ---
  final List<String> tiposDeCrise = [
    'Focal consciente',
    'Focal com perda de consciência',
    'Tônico-clônica generalizada',
    'Ausência',
    'Mioclônica',
    'Atônica',
    'Outro',
  ];

  final List<String> avisos = [
    'Dormência',
    'Abalos musculares',
    'Alteração da visão',
    'Desconforto no estômago',
    'Medo',
    'Outro',
  ];

  final List<String> gatilhos = [
    'Estresse emocional',
    'Privação de sono',
    'Esquecimento da medicação',
    'Luzes piscantes',
    'Período menstrual',
    'Febre',
    'Consumo de álcool',
    'Exercício intenso',
    'Outro',
  ];

  final List<String> condicoesPosCrise = [
    'Demorou para voltar a falar',
    'Fraqueza em uma parte do corpo',
    'Sonolência prolongada',
    'Confusão mental',
    'Mordedura de língua',
    'Urinou/evacuou',
    'Recobrou a consciência imediatamente',
    'Outro',
  ];

  // Opções carregadas do catálogo v4 (populadas no initState).
  List<String> _sintomasCatalogo = [];
  List<String> _gatilhosCatalogo = [];
  List<String> _medicamentosCatalogo = [];

  // Guarda os ids do catálogo para vincular nas relações N:N no save.
  Map<String, int> _sintomasIds = {};
  Map<String, int> _gatilhosIds = {};
  Map<String, int> _medicamentosIds = {};

  // --- Paleta de cores base para esta tela ---
  final Color darkText = const Color(0xFF2B1C4C);
  final Color lightBackground = const Color(0xFFF9F7FC);
  final Color baseCardColor = Colors.white;

  @override
  void initState() {
    super.initState();

    // Pega o tempo da última crise gravada no state do botão de crise
    final int duracaoSegundos = ref.read(criseProvider).lastCrisisDuration;

    if (duracaoSegundos > 0) {
      // Converte os segundos totais em minutos e segundos restantes
      final int minutos = duracaoSegundos ~/ 60;
      final int segundos = duracaoSegundos % 60;

      // Preenche automaticamente os controladores de texto
      _minutosController.text = minutos.toString();
      _segundosController.text = segundos.toString();
    }
    // Carrega os catálogos de sintomas, gatilhos e medicamentos do banco v4.
    _carregarCatalogos();
  }

  Future<void> _carregarCatalogos() async {
    try {
      final diarioRepository = ref.read(diarioRepositoryProvider);
      final sintomas = await diarioRepository.buscarSintomas();
      final gatilhos = await diarioRepository.buscarGatilhos();
      final medicamentos = await diarioRepository.buscarMedicamentos();
      if (!mounted) return;
      setState(() {
        _sintomasCatalogo = [for (final s in sintomas) s.nome];
        _gatilhosCatalogo = [for (final g in gatilhos) g.nome];
        _medicamentosCatalogo = [for (final m in medicamentos) m.nome];
        _sintomasIds = {for (final s in sintomas) s.nome: s.idSintoma!};
        _gatilhosIds = {for (final g in gatilhos) g.nome: g.idGatilho!};
        _medicamentosIds = {
          for (final m in medicamentos) m.nome: m.idCatalogoMedicamento!,
        };
      });
    } catch (_) {
      // Sem catálogo disponível, a tela segue com as listas vazias.
    }
  }

  // Libera a memória ocupada pelos controladores de texto ao sair da tela
  @override
  void dispose() {
    _minutosController.dispose();
    _segundosController.dispose();
    _outroAvisoController.dispose();
    _outroGatilhoController.dispose();
    _outroPosCriseController.dispose();
    _outroSintomaController.dispose();
    _outroMedicamentoController.dispose();
    super.dispose();
  }

  // --- FUNÇÃO AUXILIAR: Formata a saída dos itens selecionados ---
  // Se a pessoa marcou várias coisas e a opção "Outro" também, ele anexa o que
  // foi digitado no TextField (Ex: "Aura, Medo, Outro (Cheiro forte)").
  String _prepararStringSelecoes(
    Set<String> selecoes,
    TextEditingController controller,
  ) {
    List<String> finalSelecoes = selecoes.where((e) => e != 'Outro').toList();
    if (selecoes.contains('Outro')) {
      if (controller.text.trim().isNotEmpty) {
        finalSelecoes.add('Outro (${controller.text.trim()})');
      } else {
        finalSelecoes.add('Outro');
      }
    }
    return finalSelecoes.join(', '); // Retorna uma string separada por vírgulas
  }

  // --- FUNÇÃO PRINCIPAL: Salvar o Registro ---
  Future<void> _salvarRegistro() async {
    final dataInicio = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaSelecionada.hour,
      _horaSelecionada.minute,
    );

    final int minutos = int.tryParse(_minutosController.text) ?? 0;
    final int segundos = int.tryParse(_segundosController.text) ?? 0;
    final int totalSegundos = (minutos * 60) + segundos;

    final novaCrise = CriseModel(
      dataHoraInicio: dataInicio,
      duracao: Duration(seconds: totalSegundos),
      tipoCrise: _tipoCriseSelecionado,
      atividadeAntesCrise: _atividadeSelecionada,
      prodromosAuras: _prepararStringSelecoes(
        _avisosSelecionados,
        _outroAvisoController,
      ),
      desencadeantes: _prepararStringSelecoes(
        _gatilhosSelecionados,
        _outroGatilhoController,
      ),
      estadoPosIctal: _prepararStringSelecoes(
        _condicoesPosCriseSelecionadas,
        _outroPosCriseController,
      ),
    );

    final criseRepository = ref.read(criseRepositoryProvider);
    final diarioRepository = ref.read(diarioRepositoryProvider);

    // 1) Insere a crise e pega o id gerado
    final idCrise = await criseRepository.inserirCrise(novaCrise);

    // 2) Vincula o catálogo N:N na crise (Sintomas / Gatilhos / Medicamentos)
    for (final nome in _sintomasSelecionados.where((e) => e != 'Outro')) {
      final id = _sintomasIds[nome];
      if (id != null) {
        await diarioRepository.vincularSintomaACrise(idCrise, id);
      }
    }
    for (final nome in _gatilhosSelecionados.where((e) => e != 'Outro')) {
      final id = _gatilhosIds[nome];
      if (id != null) {
        await diarioRepository.vincularGatilhoACrise(idCrise, id);
      }
    }
    for (final nome in _medicamentosSelecionados.where((e) => e != 'Outro')) {
      final id = _medicamentosIds[nome];
      if (id != null) {
        await diarioRepository.vincularMedicamentoACrise(idCrise, id);
      }
    }

    // 3) Cria a entrada do diário com os MESMOS sintomas e gatilhos (N:N)
    final idsSintomas = _sintomasSelecionados
        .where((e) => e != 'Outro')
        .map((e) => _sintomasIds[e])
        .whereType<int>()
        .toList();
    final idsGatilhos = _gatilhosSelecionados
        .where((e) => e != 'Outro')
        .map((e) => _gatilhosIds[e])
        .whereType<int>()
        .toList();

    final novoDiario = DiarioModel(
      idPaciente: novaCrise.idPaciente,
      dataHora: dataInicio,
      anotacoes: _condicoesPosCriseSelecionadas.join(', '),
    );
    await diarioRepository.inserirDiarioComRelacoes(
      novoDiario,
      idsSintomas: idsSintomas,
      idsGatilhos: idsGatilhos,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crise registrada e vinculada ao diário')),
    );
    Navigator.pop(context);
  }

  // ============================================================================
  // CONSTRUÇÃO DA INTERFACE GRÁFICA (UI)
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      // --- BARRA SUPERIOR (AppBar) ---
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        toolbarHeight: 80,
        iconTheme: IconThemeData(color: darkText),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registro de Crise',
              style: TextStyle(
                color: darkText,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecione as informações da sua crise',
              style: TextStyle(
                color: Color(0xFF5B3089),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      // --- CORPO DA TELA COM ROLAGEM ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInformacoesBasicasCard(), // Sessão de Data, Hora, Duração e Tipo
            const SizedBox(height: 16),

            // Sessão "Você estava?" usando o widget
            ActivitySelectorCard(
              atividadeSelecionada: _atividadeSelecionada,
              onSelected: (val) => setState(() => _atividadeSelecionada = val),
            ),
            const SizedBox(height: 16),

            // Sessões em formato de "Sanfona" com listas de seleção múltipla
            MultiSelectExpandableCard(
              titulo: 'Aviso da crise',
              icone: Icons.warning_amber_rounded,
              corTema: const Color(0xFF8E62AE),
              itens: avisos,
              selecoes: _avisosSelecionados,
              controllerOutro: _outroAvisoController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 16),

            MultiSelectExpandableCard(
              titulo: 'Possíveis gatilhos',
              icone: Icons.error_outline,
              corTema: const Color(0xFFD67733),
              itens: _gatilhosCatalogo,
              selecoes: _gatilhosSelecionados,
              controllerOutro: _outroGatilhoController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 16),

            MultiSelectExpandableCard(
              titulo: 'Sintomas da crise',
              icone: Icons.healing_outlined,
              corTema: const Color(0xFF8E62AE),
              itens: _sintomasCatalogo,
              selecoes: _sintomasSelecionados,
              controllerOutro: _outroSintomaController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 16),

            MultiSelectExpandableCard(
              titulo: 'Condição pós-crise',
              icone: Icons.show_chart_rounded,
              corTema: const Color(0xFF3F8241),
              itens: condicoesPosCrise,
              selecoes: _condicoesPosCriseSelecionadas,
              controllerOutro: _outroPosCriseController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 32),

            MultiSelectExpandableCard(
              titulo: 'Medicamentos usados',
              icone: Icons.medication_outlined,
              corTema: const Color(0xFF27AE60),
              itens: _medicamentosCatalogo,
              selecoes: _medicamentosSelecionados,
              controllerOutro: _outroMedicamentoController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 16),

            // --- BOTÃO DE SALVAR ---
            ElevatedButton(
              onPressed: _salvarRegistro,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B3089),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'SALVAR REGISTRO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // COMPONENTES AUXILIARES PARA A UI
  // ============================================================================

  // Constrói o cartão branco superior que contém Data, Hora, Duração e Tipo de Crise
  Widget _buildInformacoesBasicasCard() {
    return Material(
      color: baseCardColor,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da seção
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7FC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE2D9F3),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF5B3089),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Informações Básicas',
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Seletores de Data e Hora organizados lado a lado
            Row(
              children: [
                Expanded(
                  child: _buildSeletorFalso(
                    label: 'Data',
                    valor:
                        '${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}',
                    icone: Icons.calendar_month,
                    onTap: () async {
                      // Abre o calendário nativo do sistema
                      final data = await showDatePicker(
                        context: context,
                        initialDate: _dataSelecionada,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (data != null) setState(() => _dataSelecionada = data);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSeletorFalso(
                    label: 'Horário',
                    valor:
                        '${_horaSelecionada.hour.toString().padLeft(2, '0')}:${_horaSelecionada.minute.toString().padLeft(2, '0')}',
                    icone: Icons.access_time,
                    onTap: () async {
                      // Abre o relógio nativo do sistema
                      final hora = await showTimePicker(
                        context: context,
                        initialTime: _horaSelecionada,
                      );
                      if (hora != null) setState(() => _horaSelecionada = hora);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campos para inserção de Duração em Minutos e Segundos
            Text(
              'Duração',
              style: TextStyle(
                color: darkText.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCampoNumerico(
                    hint: '00',
                    label: 'min',
                    controller: _minutosController,
                    maxVal: 60, // Limite máximo para minutos
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCampoNumerico(
                    hint: '00',
                    label: 'seg',
                    controller: _segundosController,
                    maxVal: 59, // Limite máximo para segundos
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildDropdownTipoCrise(),
          ],
        ),
      ),
    );
  }

  // Componente que renderiza um pequeno campo de texto numérico com um rótulo ao lado
  Widget _buildCampoNumerico({
    required String hint,
    required String label,
    required TextEditingController controller,
    required int maxVal,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly, // Impede a digitação de letras e sinal de negativo (-)
              _NumericalRangeFormatter(min: 0, max: maxVal),
            ],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: darkText.withValues(alpha: 0.4),
                fontSize: 15,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE2D9F3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF5B3089),
                  width: 1.5,
                ),
              ),
            ),
            style: TextStyle(color: darkText, fontSize: 15),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // Componente reutilizável que imita visualmente um input de texto,
  // mas funciona como um botão para abrir calendários/relógios.
  Widget _buildSeletorFalso({
    required String label,
    required String valor,
    required IconData icone,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: darkText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2D9F3), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(valor, style: TextStyle(color: darkText, fontSize: 15)),
                Icon(icone, color: const Color(0xFFE2D9F3), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Constrói a lista suspensa (Dropdown) para selecionar o Tipo de Crise,
  // customizada sem a linha inferir nativa.
  Widget _buildDropdownTipoCrise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Crise',
          style: TextStyle(
            color: darkText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2D9F3), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _tipoCriseSelecionado,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Selecione o tipo',
                  style: TextStyle(color: darkText, fontSize: 15),
                ),
              ),
              icon: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(Icons.keyboard_arrow_down, color: darkText),
              ),
              items: tiposDeCrise.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      tipo,
                      style: TextStyle(color: darkText, fontSize: 15),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _tipoCriseSelecionado = val),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FORMATADOR CUSTOMIZADO: LIMITA O RANGE NUMÉRICO (Ex: 0 a 59)
// ============================================================================
class _NumericalRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);

    // Se não for um número válido ou ultrapassar o limite, bloqueia a digitação
    if (value == null || value < min || value > max) {
      return oldValue;
    }

    return newValue;
  }
}
