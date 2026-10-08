import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/medicamento_model.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/widgets/custom_floating_button.dart';
import 'package:app/screens/registro_medicamento_screen.dart';

class DetalhesMedicamentoScreen extends ConsumerStatefulWidget {
  final MedicamentoModel medicamento;

  const DetalhesMedicamentoScreen({super.key, required this.medicamento});

  static Route route(MedicamentoModel med) {
    return MaterialPageRoute(builder: (_) => DetalhesMedicamentoScreen(medicamento: med));
  }

  @override
  ConsumerState<DetalhesMedicamentoScreen> createState() => _DetalhesMedicamentoScreenState();
}

class _DetalhesMedicamentoScreenState extends ConsumerState<DetalhesMedicamentoScreen> {
  final Color darkText = const Color(0xFF2B1C4C);
  final Color corVerde = const Color(0xFF27AE60);

  Future<void> _excluirMedicamento() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Medicamento'),
        content: const Text('Tem certeza que deseja excluir este medicamento e todos os seus alarmes?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // TODO BACKEND: await ref.read(medicamentoRepositoryProvider).excluir(widget.medicamento.idMedicamento!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicamento excluído!')));
        Navigator.pop(context, true); // Retorna true para a tela anterior atualizar a lista
      }
    }
  }

  Future<void> _editarMedicamento() async {
    final atualizou = await Navigator.push(
        context,
        RegistroMedicamentoScreen.route(medicamentoExistente: widget.medicamento)
    );
    if (atualizou == true && mounted) {
      Navigator.pop(context, true); // Fecha os detalhes e manda a lista atualizar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(color: darkText),
        title: Text('Detalhes', style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Principal
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: corVerde.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: Icon(Icons.medication, color: corVerde, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.medicamento.nome,
                      style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dose: ${widget.medicamento.dosagem ?? 'Não informada'}',
                      style: TextStyle(color: darkText.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de Alarmes e Horários
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_filled, color: corVerde),
                        const SizedBox(width: 8),
                        Text('Horários do Remédio', style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        // Status do Alarme
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: widget.medicamento.alertasAtivos ? corVerde.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(
                            widget.medicamento.alertasAtivos ? 'Alerta Ativo' : 'Pausado',
                            style: TextStyle(color: widget.medicamento.alertasAtivos ? corVerde : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        )
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.medicamento.horarios.map((hora) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: corVerde.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.backgroundLight,
                          ),
                          child: Text(
                            hora,
                            style: TextStyle(color: corVerde, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 24.0, top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomFloatingButton(
                    heroTag: 'btnEditMed',
                    legenda: 'Editar',
                    icone: Icons.edit_outlined,
                    corTema: AppTheme.primaryPurple,
                    onPressed: _editarMedicamento,
                  ),
                  const SizedBox(height: 16),
                  CustomFloatingButton(
                    heroTag: 'btnDeleteMed',
                    legenda: 'Excluir',
                    icone: Icons.delete_outline,
                    corTema: Colors.red,
                    onPressed: _excluirMedicamento,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}