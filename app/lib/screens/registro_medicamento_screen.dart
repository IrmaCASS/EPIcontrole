import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/medicamento_model.dart';
import 'package:app/providers/medicamento_provider.dart';
import 'package:app/theme/app_theme.dart';

class RegistroMedicamentoScreen extends ConsumerStatefulWidget {
  final MedicamentoModel? medicamentoExistente;

  const RegistroMedicamentoScreen({super.key, this.medicamentoExistente});

  static Route route({MedicamentoModel? medicamentoExistente}) {
    return MaterialPageRoute(builder: (_) => RegistroMedicamentoScreen(medicamentoExistente: medicamentoExistente));
  }

  @override
  ConsumerState<RegistroMedicamentoScreen> createState() => _RegistroMedicamentoScreenState();
}

class _RegistroMedicamentoScreenState extends ConsumerState<RegistroMedicamentoScreen> {
  final Color darkText = const Color(0xFF2B1C4C);
  final Color corVerde = const Color(0xFF27AE60);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dosagemController = TextEditingController();

  bool _alertasAtivos = true;

  // --- Configuração de Alertas ---
  TimeOfDay _primeiroHorario = const TimeOfDay(hour: 8, minute: 0);
  int _intervaloHoras = 12; // Começa por padrão de 12 em 12 horas

  // Opções de intervalo suportadas
  final List<int> _opcoesIntervalo = [0, 12, 8, 6, 4]; // 0 = Apenas 1x ao dia

  @override
  void initState() {
    super.initState();
    if (widget.medicamentoExistente != null) {
      final med = widget.medicamentoExistente!;
      _nomeController.text = med.nome;
      _dosagemController.text = med.dosagem ?? '';
      _alertasAtivos = med.alertasAtivos;

      if (med.horarios.isNotEmpty) {
        final partesInicial = med.horarios.first.split(':');
        _primeiroHorario = TimeOfDay(hour: int.parse(partesInicial[0]), minute: int.parse(partesInicial[1]));

        //
        if (med.horarios.length > 1) {
          final partesSecundario = med.horarios[1].split(':');
          final tempo2 = TimeOfDay(hour: int.parse(partesSecundario[0]), minute: int.parse(partesSecundario[1]));

          int diferencaMinutos = (tempo2.hour * 60 + tempo2.minute) - (_primeiroHorario.hour * 60 + _primeiroHorario.minute);
          if (diferencaMinutos < 0) diferencaMinutos += 24 * 60; // Caso vire o dia (ex: 20:00 -> 08:00)

          _intervaloHoras = diferencaMinutos ~/ 60;
        } else {
          _intervaloHoras = 0;
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dosagemController.dispose();
    super.dispose();
  }

  // Gera a lista final de horários calculando automaticamente baseado no intervalo
  List<TimeOfDay> _calcularHorariosFinais() {
    List<TimeOfDay> lista = [_primeiroHorario];
    if (_intervaloHoras == 0) return lista;

    int qtdDoses = 24 ~/ _intervaloHoras;
    for (int i = 1; i < qtdDoses; i++) {
      int totalMinutos = _primeiroHorario.hour * 60 + _primeiroHorario.minute + (i * _intervaloHoras * 60);
      lista.add(TimeOfDay(hour: (totalMinutos ~/ 60) % 24, minute: totalMinutos % 60));
    }
    return lista;
  }

  String _getTextoIntervalo(int horas) {
    if (horas == 0) return 'Apenas uma vez ao dia';
    return 'De $horas em $horas horas (${24 ~/ horas}x ao dia)';
  }

  Future<void> _salvarMedicamento() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha o nome do medicamento.')));
      return;
    }

    // Converte os cálculos da tela em Strings para o Banco de Dados
    final horariosGerados = _calcularHorariosFinais();
    final horariosStrings = horariosGerados
        .map((h) => '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}')
        .toList();

    final med = MedicamentoModel(
      idMedicamento: widget.medicamentoExistente?.idMedicamento,
      idPaciente: widget.medicamentoExistente?.idPaciente ?? 1,
      nome: _nomeController.text.trim(),
      dosagem: _dosagemController.text.trim().isEmpty
          ? null
          : _dosagemController.text.trim(),
      horarios: horariosStrings,
      alertasAtivos: _alertasAtivos,
    );

    final repo = ref.read(medicamentoRepositoryProvider);
    try {
      if (widget.medicamentoExistente == null) {
        await repo.inserirMedicamento(med);
      } else {
        await repo.atualizarMedicamento(med);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o medicamento: $e')),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.medicamentoExistente == null ? 'Medicamento cadastrado!' : 'Medicamento atualizado!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horariosGerados = _calcularHorariosFinais();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(color: darkText),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.medicamentoExistente == null ? 'Novo Medicamento' : 'Editar Medicamento',
              style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure o remédio e seus alertas',
              style: TextStyle(color: corVerde, fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD DE INFORMAÇÕES
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSecaoTitulo(Icons.medication, 'Identificação', corVerde),
                    const SizedBox(height: 20),
                    _buildInput(label: 'Nome do Remédio', hint: 'Ex: Carbamazepina', controller: _nomeController),
                    const SizedBox(height: 16),
                    _buildInput(label: 'Dosagem', hint: 'Ex: 200mg, 10 gotas', controller: _dosagemController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // CARD DE ALARMES
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSecaoTitulo(Icons.access_alarm, 'Configurar Alertas', corVerde),
                        Switch(
                          value: _alertasAtivos,
                          activeThumbColor: corVerde,
                          onChanged: (val) => setState(() => _alertasAtivos = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_alertasAtivos) ...[
                      // Selecionar Horário Base
                      _buildSeletorFalso(
                        label: 'Primeira dose começa às',
                        valor: '${_primeiroHorario.hour.toString().padLeft(2, '0')}:${_primeiroHorario.minute.toString().padLeft(2, '0')}',
                        icone: Icons.access_time,
                        onTap: () async {
                          final hora = await showTimePicker(context: context, initialTime: _primeiroHorario);
                          if (hora != null) setState(() => _primeiroHorario = hora);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Selecionar Padrão de Repetição
                      Text('Frequência de repetição', style: TextStyle(color: darkText.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2D9F3), width: 1.5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _intervaloHoras,
                            icon: Padding(padding: const EdgeInsets.only(right: 16), child: Icon(Icons.keyboard_arrow_down, color: darkText)),
                            items: _opcoesIntervalo.map((horas) {
                              return DropdownMenuItem(
                                value: horas,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(_getTextoIntervalo(horas), style: TextStyle(color: darkText, fontSize: 15)),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _intervaloHoras = val!),
                          ),
                        ),
                      ),

                      // Previsão visual interativa de como os alarmes ficarão
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                      Text('Seus alarmes tocarão em:', style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: horariosGerados.map((hora) {
                          final horaStr = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: corVerde.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: corVerde.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_active, size: 14, color: corVerde),
                                const SizedBox(width: 6),
                                Text(horaStr, style: TextStyle(color: corVerde, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      // Se os alertas estiverem desligados
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Os alarmes para este remédio estão desativados. Ele continuará registrado, mas o sistema não emitirá notificações de lembrete.',
                          style: TextStyle(color: darkText.withValues(alpha: 0.6), height: 1.4),
                        ),
                      )
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // BOTÃO SALVAR
            ElevatedButton(
              onPressed: _salvarMedicamento,
              style: ElevatedButton.styleFrom(
                backgroundColor: corVerde,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                widget.medicamentoExistente == null ? 'SALVAR MEDICAMENTO' : 'ATUALIZAR MEDICAMENTO',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (UI) ---
  Widget _buildSecaoTitulo(IconData icone, String titulo, Color cor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: cor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icone, color: cor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(titulo, style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 17)),
      ],
    );
  }

  Widget _buildInput({required String label, required String hint, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: darkText.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: darkText.withValues(alpha: 0.4), fontSize: 15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2D9F3), width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: corVerde, width: 1.5)),
          ),
          style: TextStyle(color: darkText, fontSize: 15),
        ),
      ],
    );
  }

  // Imita visualmente um campo de texto, mas funciona como botão de calendário/relógio
  Widget _buildSeletorFalso({required String label, required String valor, required IconData icone, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: darkText.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
}