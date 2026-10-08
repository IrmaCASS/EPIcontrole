import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/models/medicamento_model.dart';
import 'package:app/providers/medicamento_provider.dart';
import 'package:app/widgets/custom_floating_button.dart';
import 'package:app/screens/registro_medicamento_screen.dart';
import 'package:app/screens/detalhes_medicamento_screen.dart';

class MedicamentoScreen extends ConsumerStatefulWidget {
  const MedicamentoScreen({super.key});

  @override
  ConsumerState<MedicamentoScreen> createState() => _MedicamentoScreenState();
}

class _MedicamentoScreenState extends ConsumerState<MedicamentoScreen> {
  final Color darkText = const Color(0xFF2B1C4C);
  final Color corVerde = const Color(0xFF27AE60);

  List<MedicamentoModel> medicamentos = [];

  // Variáveis para controle do texto do botão
  final ScrollController _scrollController = ScrollController();
  bool _isFabExpanded = true;
  Timer? _timerOcultarTexto;

  @override
  void initState() {
    super.initState();
    _carregarMedicamentos();
    _iniciarTimerTexto();

    // Mostra o texto novamente sempre que o usuário tocar na tela para rolar
    _scrollController.addListener(() {
      _iniciarTimerTexto();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timerOcultarTexto?.cancel();
    super.dispose();
  }

  // Mostra o texto do botao, e agenda para sumir após 3 segundos
  void _iniciarTimerTexto() {
    if (!_isFabExpanded) setState(() => _isFabExpanded = true);

    _timerOcultarTexto?.cancel();
    _timerOcultarTexto = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isFabExpanded = false);
    });
  }

  // Lê os medicamentos do banco (tabela medicamento)
  Future<void> _carregarMedicamentos() async {
    final lista =
        await ref.read(medicamentoRepositoryProvider).listarMedicamentos();
    if (!mounted) return;
    setState(() => medicamentos = lista);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: GestureDetector(
        onPanDown: (_) => _iniciarTimerTexto(),
        child: medicamentos.isEmpty
            ? _buildEmptyState()
            : _buildListaMedicamentos(),
      ),

      // Botão Flutuante Customizado
      floatingActionButton: CustomFloatingButton(
        heroTag: 'btnAddMed',
        legenda: 'Novo Medicamento',
        icone: Icons.add,
        corTema: corVerde,
        isExpanded: _isFabExpanded, // Controla apenas o aparecimento da legenda
        onPressed: () async {
          await Navigator.push(context, RegistroMedicamentoScreen.route());
          await _carregarMedicamentos();
        },
      ),
    );
  }

  // --- ESTADO VAZIO ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5E5E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Lista de Rémedios',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: darkText),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhum Remédio cadastrado ainda.',
            style: TextStyle(fontSize: 16, color: darkText.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // --- LISTA COM DADOS ---
  Widget _buildListaMedicamentos() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
      itemCount: medicamentos.length,
      itemBuilder: (context, index) {
        final med = medicamentos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), offset: const Offset(0, 2), blurRadius: 6),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: corVerde.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medication_outlined, color: corVerde),
            ),
            title: Text(med.nome, style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (med.dosagem != null && med.dosagem!.isNotEmpty)
                    Text('Dose: ${med.dosagem}', style: TextStyle(color: darkText.withValues(alpha: 0.6))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: darkText.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          med.horarios.join(', '),
                          style: TextStyle(color: darkText.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: darkText.withValues(alpha: 0.3)),
            onTap: () async {
              await Navigator.push(context, DetalhesMedicamentoScreen.route(med));
              await _carregarMedicamentos();
            },
          ),
        );
      },
    );
  }
}