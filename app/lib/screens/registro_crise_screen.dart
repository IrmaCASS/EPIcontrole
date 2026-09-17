import 'package:flutter/material.dart';
import 'package:app/models/crise_model.dart';
import 'package:flutter/services.dart';

// ============================================================================
// WIDGET PRINCIPAL: TELA DE REGISTRO DE CRISE
// Responsável por renderizar o formulário interativo de registro manual de crises.
// ============================================================================
class RegistroCriseScreen extends StatefulWidget {
  const RegistroCriseScreen({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (_) => const RegistroCriseScreen());
  }

  @override
  State<RegistroCriseScreen> createState() => _RegistroCriseScreenState();
}

class _RegistroCriseScreenState extends State<RegistroCriseScreen> {
  // --- Estados do Formulário (Variáveis básicas de tempo e duração) ---
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  // --- Controladores para Duração ---
  final TextEditingController _minutosController = TextEditingController();
  final TextEditingController _segundosController = TextEditingController();

  // --- Controladores para capturar o texto dos campos "Outro" ---
  final TextEditingController _outroAvisoController = TextEditingController();
  final TextEditingController _outroGatilhoController = TextEditingController();
  final TextEditingController _outroPosCriseController = TextEditingController();

  // --- Variáveis que guardam a seleção  (Radio/Dropdown) ---
  String? _atividadeSelecionada;
  String? _tipoCriseSelecionado;

  // --- Variáveis que guardam seleções múltiplas (Checkboxes) ---
  final Set<String> _gatilhosSelecionados = {};
  final Set<String> _condicoesPosCriseSelecionadas = {};
  final Set<String> _avisosSelecionados = {};

  // --- Listas de opções fixas que populam a interface gráfica ---
  final List<String> tiposDeCrise = [
    'Focal consciente',
    'Focal com perda de consciência',
    'Tônico-clônica generalizada',
    'Ausência',
    'Mioclônica',
    'Atônica',
    'Outro'
  ];

  final List<String> avisos = [
    'Dormência',
    'Abalos musculares',
    'Alteração da visão',
    'Desconforto no estômago',
    'Medo',
    'Outro'
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
    'Outro'
  ];

  final List<String> condicoesPosCrise = [
    'Demorou para voltar a falar',
    'Fraqueza em uma parte do corpo',
    'Sonolência prolongada',
    'Confusão mental',
    'Mordedura de língua',
    'Urinou/evacuou',
    'Recobrou a consciência imediatamente',
    'Outro'
  ];

  // --- Paleta de cores base para esta tela ---
  final Color darkText = const Color(0xFF2B1C4C);
  final Color lightBackground = const Color(0xFFF9F7FC);
  final Color baseCardColor = Colors.white;

  // Libera a memória ocupada pelos controladores de texto ao sair da tela
  @override
  void dispose() {
    _minutosController.dispose();
    _segundosController.dispose();
    _outroAvisoController.dispose();
    _outroGatilhoController.dispose();
    _outroPosCriseController.dispose();
    super.dispose();
  }

  // --- FUNÇÃO AUXILIAR: Formata a saída dos itens selecionados ---
  // Se a pessoa marcou várias coisas e a opção "Outro" também, ele anexa o que
  // foi digitado no TextField (Ex: "Aura, Medo, Outro (Cheiro forte)").
  String _prepararStringSelecoes(Set<String> selecoes, TextEditingController controller) {
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
  // Monta o objeto DTO (CriseModel) usando os estados atuais da interface.
  void _salvarRegistro() {
    // Unifica a data e hora escolhidas em um único objeto DateTime
    final dataInicio = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaSelecionada.hour,
      _horaSelecionada.minute,
    );

    // Converte os textos em números, soma e formata em segundos pro DB
    final int minutos = int.tryParse(_minutosController.text) ?? 0;
    final int segundos = int.tryParse(_segundosController.text) ?? 0;
    final int totalSegundos = (minutos * 60) + segundos;

    // Instancia o modelo empacotando os dados
    final novaCrise = CriseModel(
      dataHoraInicio: dataInicio,
      duracao: Duration(seconds: totalSegundos), // Enviado pro DB em segundos precisos
      tipoCrise: _tipoCriseSelecionado,
      atividadeAntesCrise: _atividadeSelecionada,
      prodromosAuras: _prepararStringSelecoes(_avisosSelecionados, _outroAvisoController),
      desencadeantes: _prepararStringSelecoes(_gatilhosSelecionados, _outroGatilhoController),
      estadoPosIctal: _prepararStringSelecoes(_condicoesPosCriseSelecionadas, _outroPosCriseController),
    );

    // ==========================================================
    // TODO: INTEGRAÇÃO BACKEND (CriseRepository)
    // Local onde a chamada ao Provider ou Repositório irá inserir
    // a `novaCrise` no banco de dados local.
    // ==========================================================

    // Exibe um feedback visual de sucesso e retorna para a tela anterior
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crise registrada (Simulação Frontend)')),
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
              style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecione as informações da sua crise',
              style: TextStyle(color: Color(0xFF5B3089), fontSize: 14, fontWeight: FontWeight.normal),
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

            _buildCardAtividade(), // Sessão "Você estava?" (Dormindo, Acordado, etc)
            const SizedBox(height: 16),

            // Sessões em formato de "Sanfona" (Accordion) com listas de seleção múltipla
            _buildMenuExpansivel(
              titulo: 'Aviso da crise',
              icone: Icons.warning_amber_rounded,
              corTema: const Color(0xFF8E62AE),
              itens: avisos,
              selecoes: _avisosSelecionados,
              controllerOutro: _outroAvisoController,
            ),
            const SizedBox(height: 16),

            _buildMenuExpansivel(
              titulo: 'Possíveis gatilhos',
              icone: Icons.error_outline,
              corTema: const Color(0xFFD67733),
              itens: gatilhos,
              selecoes: _gatilhosSelecionados,
              controllerOutro: _outroGatilhoController,
            ),
            const SizedBox(height: 16),

            _buildMenuExpansivel(
              titulo: 'Condição pós-crise',
              icone: Icons.show_chart_rounded,
              corTema: const Color(0xFF3F8241),
              itens: condicoesPosCrise,
              selecoes: _condicoesPosCriseSelecionadas,
              controllerOutro: _outroPosCriseController,
            ),
            const SizedBox(height: 32),

            // --- BOTÃO DE SALVAR ---
            ElevatedButton(
              onPressed: _salvarRegistro,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B3089),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SALVAR REGISTRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // COMPONENTES (WIDGETS) AUXILIARES PARA A UI
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
                    border: Border.all(color: const Color(0xFFE2D9F3), width: 1.2),
                  ),
                  child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF5B3089), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Informações Básicas',
                  style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18),
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
                    valor: '${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}',
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
                    valor: '${_horaSelecionada.hour.toString().padLeft(2, '0')}:${_horaSelecionada.minute.toString().padLeft(2, '0')}',
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
              style: TextStyle(color: darkText.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 13),
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

            _buildDropdownTipoCrise(), // Chamada para o Dropdown
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
              FilteringTextInputFormatter.digitsOnly, // Impede a digitação de letras e sinal de negativo (-)
              _NumericalRangeFormatter(min: 0, max: maxVal), // Formater customizado para limitar o teto
            ],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: darkText.withValues(alpha: 0.4), fontSize: 15),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2D9F3), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF5B3089), width: 1.5),
              ),
            ),
            style: TextStyle(color: darkText, fontSize: 15),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: darkText, fontWeight: FontWeight.w600, fontSize: 15),
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
          style: TextStyle(color: darkText.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 13),
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
        Text('Tipo de Crise', style: TextStyle(color: darkText.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 13)),
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
                child: Text('Selecione o tipo', style: TextStyle(color: darkText, fontSize: 15)),
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
                    child: Text(tipo, style: TextStyle(color: darkText, fontSize: 15)),
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

  // Constrói o cartão que pergunta "Você estava?" (Atividade).
  // Possui 3 botões expansíveis dispostos lado a lado.
  Widget _buildCardAtividade() {
    return Material(
      color: baseCardColor,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Você estava?', style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildOpcaoAtividade(
                    titulo: 'Dormindo',
                    icone: Icons.bed_outlined,
                    corAtiva: const Color(0xFF1E67D6), // Azul
                    fundoInativo: const Color(0xFFF6F2FA),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOpcaoAtividade(
                    titulo: 'Acordado',
                    icone: Icons.show_chart_rounded,
                    corAtiva: const Color(0xFF3F8241), // Verde
                    fundoInativo: const Color(0xFFF6F2FA),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOpcaoAtividade(
                    titulo: 'Acordando',
                    icone: Icons.wb_twilight_rounded,
                    corAtiva: const Color(0xFFD65C00), // Laranja
                    fundoInativo: const Color(0xFFF6F2FA),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Constrói individualmente as opções do cartão "Você estava?".
  Widget _buildOpcaoAtividade({
    required String titulo,
    required IconData icone,
    required Color corAtiva,
    required Color fundoInativo,
  }) {
    final bool isSelected = _atividadeSelecionada == titulo;

    return GestureDetector(
      onTap: () => setState(() => _atividadeSelecionada = titulo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? corAtiva.withValues(alpha: 0.1) : fundoInativo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? corAtiva : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? corAtiva : const Color(0xFFEAE4F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icone,
                color: isSelected ? Colors.white : const Color(0xFF7A609E),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color: isSelected ? corAtiva : const Color(0xFF7A609E),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constrói os Menus Sanfona (Avisos, Gatilhos e Condição pós-crise).
  // Eles recebem uma lista e gerenciam uma seleção múltipla (Checkboxes circulares).
  Widget _buildMenuExpansivel({
    required String titulo,
    required IconData icone,
    required Color corTema,
    required List<String> itens,
    required Set<String> selecoes,
    required TextEditingController controllerOutro, // Controlador exclusivo da respectiva seção
  }) {
    return Material(
      color: baseCardColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias, // Mantém a animação de clique contida nos limites arredondados
      child: Theme(
        // Remove as linhas cinzas nativas que aparecem quando o componente abre
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: corTema.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: corTema, size: 24),
          ),
          title: Text(
            titulo,
            style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          iconColor: darkText,
          collapsedIconColor: darkText.withValues(alpha: 0.5),
          children: itens.map((item) {
            final isSelected = selecoes.contains(item);
            final isOutro = item == 'Outro';

            return Column(
              children: [
                // Linha interativa contendo o checkbox customizado circular e o texto
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selecoes.remove(item);
                        // Limpa o texto se o usuário desmarcar a opção "Outro"
                        if (isOutro) controllerOutro.clear();
                      } else {
                        selecoes.add(item);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Checkbox Circular Animado
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? corTema : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? corTema : const Color(0xFFD1C8E1),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(item, style: TextStyle(color: darkText, fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Exibe o Campo de Texto extra imediatamente abaixo caso a opção "Outro" esteja marcada
                if (isOutro && isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: TextField(
                      controller: controllerOutro,
                      decoration: InputDecoration(
                        hintText: 'Descreva aqui...',
                        hintStyle: TextStyle(color: darkText.withValues(alpha: 0.4), fontSize: 15),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2D9F3), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: corTema, width: 1.5),
                        ),
                      ),
                      style: TextStyle(color: darkText, fontSize: 15),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
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