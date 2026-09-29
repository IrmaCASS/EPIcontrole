import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/models/crise_model.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/widgets/empty_state_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/providers/registro_crise_provider.dart';

// ============================================================================
// WIDGET PRINCIPAL: TELA DE DIÁRIO DE CRISES
// Responsável por exibir o calendário interativo e a lista de registros diários.
// ============================================================================
class DiarioScreen extends ConsumerStatefulWidget {
  const DiarioScreen({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (_) => const DiarioScreen());
  }

  @override
  ConsumerState<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends ConsumerState<DiarioScreen> {
  // --- Estados do Calendário ---
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // Crises reais carregadas do banco para o mês focado
  List<CriseModel> _crisesDoMes = [];

  // --- Cores da Paleta ---
  final Color darkText = AppTheme.primaryPurple;
  final Color lightBackground = AppTheme.backgroundLight;
  final Color corCrise = AppTheme.primaryPurple; // Roxo para crises
  final Color corFocusedDaySelected = AppTheme.accentLilac; // Lilás
  final Color corMedicamento = const Color(0xFF27AE60);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _carregarEventosDoMes(_focusedDay);
  }

  void _carregarEventosDoMes(DateTime mes) {
    _carregarCrisesDoMes(mes);
  }

  Future<void> _carregarCrisesDoMes(DateTime mes) async {
    try {
      final inicio = DateTime(mes.year, mes.month, 1);
      final fim = DateTime(
        mes.year,
        mes.month + 1,
        0,
      ).add(const Duration(days: 1));
      final crises = await ref
          .read(criseRepositoryProvider)
          .buscarCrisesPorPeriodo(inicio: inicio, fim: fim);
      if (mounted) setState(() => _crisesDoMes = crises);
    } catch (e) {
      // Se der erro no banco, não deixa o app travar
    }
  }

  List<CriseModel> _getCrisesParaDia(DateTime dia) {
    return _crisesDoMes
        .where((crise) => isSameDay(crise.dataHoraInicio, dia))
        .toList();
  }

  List<String> _getMedicamentosParaDia(DateTime dia) {
    final hoje = DateTime.now();
    if (isSameDay(dia, hoje) ||
        isSameDay(dia, hoje.add(const Duration(days: 1)))) {
      return ['Carbamazepina 200mg - 08:00', 'Ácido Valproico 500mg - 20:00'];
    }
    return [];
  }
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final crisesDoDia = _selectedDay != null
        ? _getCrisesParaDia(_selectedDay!)
        : <CriseModel>[];
    final medicamentosDoDia = _selectedDay != null
        ? _getMedicamentosParaDia(_selectedDay!)
        : <String>[];
    final temEventos = crisesDoDia.isNotEmpty || medicamentosDoDia.isNotEmpty;

    return Scaffold(
      backgroundColor: lightBackground,
      body: Column(
        children: [
          //CALENDÁRIO INTERATIVO
          _buildCalendario(),
          //LISTA COM FADE EFFECT
          Expanded(
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent, // Topo transparente (sob o calendário)
                    Colors.black, // Conteúdo visível
                    Colors.black, // Conteúdo visível
                    Colors.transparent, // Fundo transparente (sob a nav bar)
                  ],
                  stops: [
                    0.0,
                    0.015, // 0.5% de esfumaçado no topo
                    0.92, // Começa a esfumaçar nos últimos 8%
                    1.0, // Termina totalmente transparente
                  ],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: temEventos
                  ? _buildListaEventos(crisesDoDia, medicamentosDoDia)
                  : const EmptyStateWidget(), // Uso do componente reutilizável
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // COMPONENTES DA UI
  // ============================================================================

  Widget _buildCalendario() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        // Arredondamento no final do calendário
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: TableCalendar(
        locale: 'pt_BR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        //ALTURA DO CALENDÁRIO
        rowHeight: 42,
        daysOfWeekHeight: 24,

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: const EdgeInsets.symmetric(vertical: 4),
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: darkText),
          rightChevronIcon: Icon(Icons.chevron_right, color: darkText),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: corFocusedDaySelected.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: corCrise,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: BoxDecoration(
            color: corFocusedDaySelected,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _carregarEventosDoMes(focusedDay);
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final crises = _getCrisesParaDia(date);
            final meds = _getMedicamentosParaDia(date);

            if (crises.isEmpty && meds.isEmpty) return const SizedBox();

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (crises.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      height: 4,
                      width: 12,
                      decoration: BoxDecoration(
                        color: corCrise,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  if (meds.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      height: 4,
                      width: 12,
                      decoration: BoxDecoration(
                        color: corMedicamento,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListaEventos(
    List<CriseModel> crises,
    List<String> medicamentos,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        Text(
          'Registros do dia ${_selectedDay!.day}/${_selectedDay!.month}',
          style: TextStyle(
            color: darkText.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        if (crises.isNotEmpty)
          _buildSanfona(
            titulo: 'Registros de Crises',
            icone: Icons.bolt,
            corTema: corCrise,
            quantidade: crises.length,
            filhos: crises.map((crise) => _buildCardCrise(crise)).toList(),
          ),

        if (crises.isNotEmpty && medicamentos.isNotEmpty)
          const SizedBox(height: 16),

        if (medicamentos.isNotEmpty)
          _buildSanfona(
            titulo: 'Alertas de Medicamento',
            icone: Icons.medical_services_outlined,
            corTema: corMedicamento,
            quantidade: medicamentos.length,
            filhos: medicamentos
                .map((med) => _buildCardMedicamento(med))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildSanfona({
    required String titulo,
    required IconData icone,
    required Color corTema,
    required int quantidade,
    required List<Widget> filhos,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: corTema.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: corTema, size: 24),
          ),
          title: Text(
            titulo,
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: corTema,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              quantidade.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          children: filhos,
        ),
      ),
    );
  }

  Widget _buildCardCrise(CriseModel crise) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        crise.tipoCrise ?? 'Crise não especificada',
        style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${crise.dataHoraInicio.hour.toString().padLeft(2, '0')}:${crise.dataHoraInicio.minute.toString().padLeft(2, '0')} • Duração: ${crise.duracao != null && crise.duracao!.inSeconds > 0 ? '${crise.duracao!.inMinutes}m ${crise.duracao!.inSeconds % 60}s' : 'Não informada'}',
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: darkText.withValues(alpha: 0.4),
      ),
      onTap: () {},
    );
  }

  Widget _buildCardMedicamento(String nome) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        nome,
        style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
      ),
      leading: Icon(Icons.check_circle, color: corMedicamento),
    );
  }
}
