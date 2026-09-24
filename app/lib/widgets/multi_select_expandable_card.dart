import 'package:flutter/material.dart';

/// Widget reutilizável para os Menus Sanfona (Avisos, Gatilhos e Condição pós-crise)
/// com suporte a seleção múltipla (Checkboxes circulares) e campo de texto "Outro".
class MultiSelectExpandableCard extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color corTema;
  final List<String> itens;
  final Set<String> selecoes;
  final TextEditingController controllerOutro;
  final VoidCallback onChanged;

  const MultiSelectExpandableCard({
    super.key,
    required this.titulo,
    required this.icone,
    required this.corTema,
    required this.itens,
    required this.selecoes,
    required this.controllerOutro,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color darkText = const Color(0xFF2B1C4C);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Theme(
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
                    if (isSelected) {
                      selecoes.remove(item);
                      // Limpa o texto se o usuário desmarcar a opção "Outro"
                      if (isOutro) controllerOutro.clear();
                    } else {
                      selecoes.add(item);
                    }
                    onChanged();
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
                      onChanged: (_) => onChanged(),
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