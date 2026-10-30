import 'package:flutter/material.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  int _filtroAtivo = 0; 
  String _periodoSelecionado = "Hoje";
  final TextEditingController _searchController = TextEditingController();

  static const Color accentColor = Color(0xFF00E676);

  final List<Map<String, dynamic>> _logsMock = [
    {"prod": "Picanha Argentina", "user": "Gerente Carlos", "qtd": 5.0, "tipo": "ENTRADA", "hora": "10:30", "motivo": "Compra Fornecedor"},
    {"prod": "Coca-Cola 350ml", "user": "Garçom Ana", "qtd": 12.0, "tipo": "SAÍDA", "hora": "11:45", "motivo": "Venda Salão"},
    {"prod": "Tomate Cereja", "user": "Cozinha João", "qtd": 2.5, "tipo": "DESPERDÍCIO", "hora": "09:15", "motivo": "Vencido/Estragado"},
    {"prod": "Filé Mignon", "user": "Gerente Carlos", "qtd": 10.0, "tipo": "ENTRADA", "hora": "08:00", "motivo": "Reposição"},
    {"prod": "Alface Americana", "user": "Cozinha João", "qtd": 1.0, "tipo": "DESPERDÍCIO", "hora": "14:20", "motivo": "Folhas Murchas"},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    final logsFiltrados = _logsMock.where((log) {
      final busca = _searchController.text.toLowerCase();
      final matchBusca = log['prod'].toLowerCase().contains(busca) || 
                         log['user'].toLowerCase().contains(busca);
      
      bool matchTipo = true;
      if (_filtroAtivo == 1) matchTipo = log['tipo'] == "ENTRADA";
      if (_filtroAtivo == 2) matchTipo = log['tipo'] == "SAÍDA";
      if (_filtroAtivo == 3) matchTipo = log['tipo'] == "DESPERDÍCIO";
      
      return matchBusca && matchTipo;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("HISTÓRICO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: baseTextColor, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded, color: accentColor),
            onPressed: () => _abrirFiltroPeriodo(isEscuro, baseTextColor),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "Buscar produto ou usuário...",
                hintStyle: TextStyle(color: hintColor, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: hintColor, size: 20),
                filled: true,
                fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                _buildChipFiltro("Todos", 0, isEscuro),
                const SizedBox(width: 8),
                _buildChipFiltro("Entradas", 1, isEscuro),
                const SizedBox(width: 8),
                _buildChipFiltro("Vendas", 2, isEscuro),
                const SizedBox(width: 8),
                _buildChipFiltro("Perdas", 3, isEscuro),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: logsFiltrados.length,
              itemBuilder: (context, index) => _buildCardHistorico(logsFiltrados[index], isEscuro, baseTextColor, hintColor, cardColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipFiltro(String label, int index, bool isEscuro) {
    bool selecionado = _filtroAtivo == index;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: selecionado ? Colors.black : (isEscuro ? Colors.white54 : Colors.black54))),
      selected: selecionado,
      onSelected: (_) => setState(() => _filtroAtivo = index),
      selectedColor: accentColor,
      backgroundColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
    );
  }

  Widget _buildCardHistorico(Map<String, dynamic> item, bool isEscuro, Color baseTextColor, Color hintColor, Color cardColor) {
    Color cor = item['tipo'] == "ENTRADA" ? accentColor : (item['tipo'] == "SAÍDA" ? const Color(0xFF2979FF) : Colors.redAccent.shade400);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['prod'], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: baseTextColor)),
                    Text("${item['tipo'] == 'ENTRADA' ? '+' : '-'}${item['qtd']}", style: TextStyle(fontWeight: FontWeight.w900, color: cor)),
                  ],
                ),
                const SizedBox(height: 4),
                Text("${item['user']} • ${item['motivo']}", style: TextStyle(color: hintColor, fontSize: 11, fontWeight: FontWeight.w600)),
                Text(item['hora'], style: TextStyle(color: hintColor.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _abrirFiltroPeriodo(bool isEscuro, Color baseTextColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isEscuro ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PERÍODO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.5)),
            const SizedBox(height: 20),
            ...["Hoje", "Últimos 7 dias", "Últimos 30 dias"].map((p) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(p, style: TextStyle(fontWeight: FontWeight.w600, color: baseTextColor)),
              trailing: _periodoSelecionado == p ? const Icon(Icons.check_rounded, color: accentColor) : null,
              onTap: () {
                setState(() => _periodoSelecionado = p);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}