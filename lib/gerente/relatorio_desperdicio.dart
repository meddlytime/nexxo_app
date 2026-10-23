import 'package:flutter/material.dart';

class RelatorioDesperdicioGerentePage extends StatefulWidget {
  const RelatorioDesperdicioGerentePage({super.key});

  @override
  State<RelatorioDesperdicioGerentePage> createState() => _RelatorioDesperdicioGerentePageState();
}

class _RelatorioDesperdicioGerentePageState extends State<RelatorioDesperdicioGerentePage> {
  String _mesSelecionado = "Junho";
  String _categoriaSelecionada = "Todos";

  bool _alertasAtivados = true;
  double _limiteCritico = 100.00;

  final List<String> _meses = ["Abril", "Maio", "Junho"];
  final List<String> _categorias = ["Todos", "Cozinha", "Bar", "Vencimento"];

  final List<Map<String, dynamic>> _desperdiciosGerais = [
    {"item": "Picanha Argentina", "qtd": "1.5 kg", "custo": 135.00, "responsavel": "João Silva", "motivo": "Queimado", "data": "02/06", "categoria": "Cozinha", "mes": "Junho"},
    {"item": "Tomate Italiano", "qtd": "2.0 kg", "custo": 24.00, "responsavel": "Maria Santos", "motivo": "Passou do ponto", "data": "02/06", "categoria": "Cozinha", "mes": "Junho"},
    {"item": "Limão Taiti", "qtd": "0.5 kg", "custo": 4.50, "responsavel": "Lucas (Bar)", "motivo": "Ressecado", "data": "01/06", "categoria": "Bar", "mes": "Junho"},
    {"item": "Cerveja IPA", "qtd": "12 un", "custo": 180.00, "responsavel": "Ana", "motivo": "Vencimento", "data": "28/05", "categoria": "Vencimento", "mes": "Maio"},
  ];

  static const Color accentColor = Color(0xFF2979FF); 

  List<Map<String, dynamic>> get _desperdiciosFiltrados {
    return _desperdiciosGerais.where((item) {
      final mesMatch = item['mes'] == _mesSelecionado;
      final catMatch = _categoriaSelecionada == "Todos" || item['categoria'] == _categoriaSelecionada;
      return mesMatch && catMatch;
    }).toList();
  }

  double get _impactoFinanceiroTotal {
    return _desperdiciosFiltrados.fold(0.0, (sum, item) => sum + (item['custo'] as num).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    final filtrados = _desperdiciosFiltrados;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("AUDITORIA DE DESPERDÍCIO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: baseTextColor, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_alertasAtivados ? Icons.notifications_active_rounded : Icons.notifications_off_rounded, color: _alertasAtivados ? accentColor : hintColor, size: 22),
            onPressed: () => _modalConfiguracaoAlertas(baseTextColor, cardColor, hintColor, isEscuro),
          ),
          _buildMesSelector(baseTextColor, cardColor, isEscuro),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Row(
              children: [
                _buildStatCard("Total Registros", "${filtrados.length}", isEscuro, cardColor, baseTextColor, hintColor),
                const SizedBox(width: 16),
                _buildStatCard("Impacto (R\$)", _impactoFinanceiroTotal.toStringAsFixed(2), isEscuro, cardColor, Colors.redAccent.shade400, hintColor),
              ],
            ),
          ),
          
          _buildCategoriaFiltros(isEscuro, cardColor, baseTextColor),
          
          const SizedBox(height: 16),

          Expanded(
            child: filtrados.isEmpty
                ? Center(child: Text("Nenhum registro encontrado para este filtro.", style: TextStyle(color: hintColor, fontWeight: FontWeight.w600)))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final item = filtrados[index];
                      bool showDateHeader = index == 0 || filtrados[index]['data'] != filtrados[index - 1]['data'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 12),
                              child: Text(item['data'], style: TextStyle(color: hintColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                            ),
                          _buildItemDesperdicio(item, baseTextColor, hintColor, cardColor, isEscuro),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _modalConfiguracaoAlertas(Color baseTextColor, Color cardColor, Color hintColor, bool isEscuro) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("GESTÃO DE ALERTAS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: baseTextColor, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text("Seja notificado em tempo real quando houver uma baixa crítica no estoque.", style: TextStyle(fontSize: 13, color: hintColor, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: accentColor,
                      title: Text("Alertas Push (Gerente)", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: baseTextColor)),
                      subtitle: Text("Receber notificação no celular", style: TextStyle(fontSize: 11, color: hintColor)),
                      value: _alertasAtivados,
                      onChanged: (val) {
                        setModalState(() => _alertasAtivados = val);
                        setState(() => _alertasAtivados = val);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text("VALOR CRÍTICO DE ALERTA (R\$)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: accentColor, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  
                  Slider(
                    value: _limiteCritico,
                    min: 50.0,
                    max: 500.0,
                    divisions: 9,
                    activeColor: accentColor,
                    inactiveColor: isEscuro ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    label: "R\$ ${_limiteCritico.toStringAsFixed(2)}",
                    onChanged: _alertasAtivados ? (val) {
                      setModalState(() => _limiteCritico = val);
                      setState(() => _limiteCritico = val);
                    } : null,
                  ),
                  Center(
                    child: Text(
                      "Notificar se a perda ultrapassar R\$ ${_limiteCritico.toStringAsFixed(2)}", 
                      style: TextStyle(fontSize: 12, color: _alertasAtivados ? baseTextColor : hintColor, fontWeight: FontWeight.w600)
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("SALVAR CONFIGURAÇÃO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildMesSelector(Color textColor, Color cardColor, bool isEscuro) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _mesSelecionado,
          dropdownColor: cardColor,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor, size: 20),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 13),
          onChanged: (String? newValue) {
            if (newValue != null) setState(() => _mesSelecionado = newValue);
          },
          items: _meses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoriaFiltros(bool isEscuro, Color cardColor, Color textColor) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final cat = _categorias[index];
          final isSelected = cat == _categoriaSelecionada;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) setState(() => _categoriaSelecionada = cat);
              },
              backgroundColor: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              selectedColor: accentColor.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? accentColor : (isEscuro ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 12
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? accentColor.withOpacity(0.5) : Colors.transparent),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String valor, bool isEscuro, Color cardColor, Color textColor, Color hintColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: hintColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Text(valor, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDesperdicio(Map<String, dynamic> item, Color textColor, Color hintColor, Color cardColor, bool isEscuro) {
    final double custo = (item['custo'] as num).toDouble();
    final bool isCritico = custo >= _limiteCritico;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: isCritico ? Colors.redAccent.shade400.withOpacity(0.3) : (isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCritico ? Colors.redAccent.shade400.withOpacity(0.1) : (isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(isCritico ? Icons.warning_rounded : Icons.delete_outline_rounded, color: isCritico ? Colors.redAccent.shade400 : hintColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['item'], style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 14)),
                const SizedBox(height: 4),
                Text("${item['qtd']} • ${item['motivo']}", style: TextStyle(fontSize: 12, color: hintColor, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("R\$ ${custo.toStringAsFixed(2)}", style: TextStyle(fontSize: 14, color: isCritico ? Colors.redAccent.shade400 : textColor, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(item['responsavel'], style: const TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w800)),
            ],
          )
        ],
      ),
    );
  }
}