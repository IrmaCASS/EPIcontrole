// Arquivo: lib/screens/detalhes_crise_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/crise_model.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/registro_crise_provider.dart';
import 'package:app/screens/registro_crise_screen.dart';
import 'package:app/widgets/custom_floating_button.dart';

// ============================================================================
//TELA DE DETALHES DA CRISE
// Exibe todos os dados registrados de uma crise específica e edição/exclusão.
// ============================================================================
class DetalhesCriseScreen extends ConsumerStatefulWidget {
  final CriseModel crise;

  const DetalhesCriseScreen({super.key, required this.crise});

  // Metodo para navegação
  static Route route(CriseModel crise) {
    return MaterialPageRoute(
      builder: (_) => DetalhesCriseScreen(crise: crise),
    );
  }

  @override
  ConsumerState<DetalhesCriseScreen> createState() => _DetalhesCriseScreenState();
}

class _DetalhesCriseScreenState extends ConsumerState<DetalhesCriseScreen> {
  final Color darkText = const Color(0xFF2B1C4C);

  // ============================================================================
  // INTEGRAÇÃO COM BACKEND: EXCLUSÃO
  // ============================================================================
  Future<void> _excluirCrise() async {
    // Exibe um modal de confirmação antes de apagar do banco de dados local
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Registro'),
        content: const Text('Tem certeza que deseja excluir esta crise? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        /*
        // TODO: BACKEND - PASSO A PASSO PARA EXCLUSÃO:
        // 1. Chamar o repositório para deletar a crise no banco local usando o ID.
        // Exemplo: await ref.read(criseRepositoryProvider).deletarCrise(widget.crise.idCrise!);

        // 2. Deletar também o registro no Diário (DiarioModel) associado,
        // ou garantir que o banco de dados faça isso via ON DELETE CASCADE

        // 3. Atualizar o calendário da tela anterior emitindo um sinal:
        refreshDiarioNotifier.value++;
        */

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crise excluída com sucesso!')),
          );
          // Fecha a tela de detalhes e volta para o diário
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  // ============================================================================
  // INTEGRAÇÃO COM BACKEND: EDIÇÃO
  // ============================================================================
  Future<void> _editarCrise() async{
    /*
    // TODO: BACKEND - PASSO A PASSO PARA EDIÇÃO:
    // 1. Navegar para a tela `RegistroCriseScreen` (ou uma nova `EdicaoCriseScreen`).
    // 2. Você precisará alterar o construtor da tela de registro para aceitar um objeto `CriseModel? criseExistente`.
    // 3. Se `criseExistente` não for nulo, os `TextEditingControllers` e variáveis da tela
    //    devem ser inicializados com os valores do banco no `initState`.
    // 4. Ao salvar na outra tela, use um método de UPDATE no banco ao invés de INSERT.

    // Exemplo de navegação aguardando o retorno para atualizar esta tela:
    // final atualizou = await Navigator.push(context, RegistroCriseScreen.route(crise: widget.crise));
    // if (atualizou == true) {
    //    setState(() { /* recarregar dados da crise do banco */ });
    //    refreshDiarioNotifier.value++;
    // }
    */

    // Salva o valor atual do notificador para saber se houve alteração
    final notificacaoAnterior = refreshDiarioNotifier.value;

    // Navega para a tela de Registro passando a crise atual
    await Navigator.push(
      context,
      RegistroCriseScreen.route(crise: widget.crise),
    );

    // Quando voltar, verifica se a tela ainda está montada e se o notificador mudou (ou seja, se salvou)
    if (mounted && refreshDiarioNotifier.value > notificacaoAnterior) {
      // Fecha a tela de detalhes para voltar ao Diário, que recarregará os dados novos automaticamente
      Navigator.pop(context);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Função de edição será implementada na integração.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formatação de data e hora
    final dataStr = '${widget.crise.dataHoraInicio.day.toString().padLeft(2, '0')}/${widget.crise.dataHoraInicio.month.toString().padLeft(2, '0')}/${widget.crise.dataHoraInicio.year}';
    final horaStr = '${widget.crise.dataHoraInicio.hour.toString().padLeft(2, '0')}:${widget.crise.dataHoraInicio.minute.toString().padLeft(2, '0')}';

    // Formatação de duração
    String duracaoStr = 'Não informada';
    if (widget.crise.duracao != null && widget.crise.duracao!.inSeconds > 0) {
      final m = widget.crise.duracao!.inMinutes;
      final s = widget.crise.duracao!.inSeconds % 60;
      duracaoStr = '${m}m${s}s';
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(color: darkText),
        title: Text(
          'Detalhes da Crise',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        // Padding inferior aumentado (160.0) para os botões flutuantes não ficarem em cima do conteúdo no fim da rolagem
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 160.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD DE INFORMAÇÕES BÁSICAS
            _buildInfoCard(
              children: [
                _buildCabecalhoSecao(Icons.calendar_today_outlined, 'Informações Básicas', const Color(0xFF5B3089)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDadoBasico('Data', dataStr)),
                    Expanded(child: _buildDadoBasico('Horário', horaStr)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDadoBasico('Duração', duracaoStr)),
                    Expanded(child: _buildDadoBasico('Tipo', widget.crise.tipoCrise ?? 'Não informado')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDadoBasico('Atividade antes da crise', widget.crise.atividadeAntesCrise ?? 'Não informada'),
              ],
            ),
            const SizedBox(height: 16),

            // CARD DE DETALHAMENTO CLÍNICO (Avisos, Sintomas, Pós Crise)
            _buildInfoCard(
              children: [
                _buildCabecalhoSecao(Icons.healing_outlined, 'Detalhamento Clínico', const Color(0xFF8E62AE)),
                const SizedBox(height: 16),
                _buildSecaoLista('Avisos / Auras', widget.crise.prodromosAuras, const Color(0xFF8E62AE)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider(color: Color(0xFFE2D9F3))),

                // NOTA: No CriseModel (Diagrama de Classe) os sintomas não estão no modelo base como String simples,
                // eles vêm do N:N. Se seu backend agrupar isso em uma String, passe aqui.
                // Como exemplo, usarei os prodromos, mas deve ser substituído pelo atributo de sintomas quando populado.
                _buildSecaoLista('Sintomas durante a crise', widget.crise.sintomas ?? 'Nenhum registrado', const Color(0xFF5B3089)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider(color: Color(0xFFE2D9F3))),

                _buildSecaoLista('Condição Pós-Crise', widget.crise.estadoPosIctal, const Color(0xFF3F8241)),
              ],
            ),
            const SizedBox(height: 16),

            // 3. CARD DE GATILHOS
            _buildInfoCard(
              children: [
                _buildCabecalhoSecao(Icons.error_outline, 'Possíveis Gatilhos', const Color(0xFFD67733)),
                const SizedBox(height: 16),
                _buildSecaoLista(null, widget.crise.desencadeantes, const Color(0xFFD67733)),
              ],
            ),
            const SizedBox(height: 16),

            // 4. CARD DE ANOTAÇÕES LIVRES
            if (widget.crise.anotacoes != null && widget.crise.anotacoes!.isNotEmpty)
              _buildInfoCard(
                children: [
                  _buildCabecalhoSecao(Icons.notes, 'Anotações Livres', const Color(0xFF4F4F4F)),
                  const SizedBox(height: 16),
                  Text(
                    widget.crise.anotacoes!,
                    style: TextStyle(color: darkText.withValues(alpha: 0.8), fontSize: 15, height: 1.4),
                  ),
                ],
              ),
          ],
        ),
      ),

      // BOTÕES FLUTUANTES (EDIÇÃO E EXCLUSÃO) - AGORA USANDO O WIDGET
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomFloatingButton(
            heroTag: 'btnEditar',
            legenda: 'Editar Crise', // Será usado no tooltip
            icone: Icons.edit_outlined,
            corTema: AppTheme.primaryPurple,
            onPressed: _editarCrise,
            isExpanded: false, // Oculta o texto lateral, ativando apenas ao segurar (tooltip)
          ),
          const SizedBox(height: 16),
          CustomFloatingButton(
            heroTag: 'btnExcluir',
            legenda: 'Excluir Crise', // Será usado no tooltip
            icone: Icons.delete_outline,
            corTema: Colors.red,
            onPressed: _excluirCrise,
            isExpanded: false, // Oculta o texto lateral, ativando apenas ao segurar (tooltip)
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGETS AUXILIARES (UI)
  // ============================================================================

  Widget _buildInfoCard({required List<Widget> children}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildCabecalhoSecao(IconData icone, String titulo, Color corTema) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: corTema.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icone, color: corTema, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          titulo,
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ],
    );
  }

  Widget _buildDadoBasico(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: darkText.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildSecaoLista(String? titulo, String? dadosConcatenados, Color corTema) {
    if (dadosConcatenados == null || dadosConcatenados.trim().isEmpty) {
      dadosConcatenados = 'Não informado';
    }

    final itens = dadosConcatenados.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo != null) ...[
          Text(
            titulo,
            style: TextStyle(color: darkText.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: itens.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: item == 'Não informado' ? AppTheme.backgroundLight : corTema.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: item == 'Não informado' ? Colors.transparent : corTema.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: item == 'Não informado' ? darkText.withValues(alpha: 0.5) : corTema,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}