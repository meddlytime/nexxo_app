import 'package:flutter/material.dart';

class ListaComprasGerentePage extends StatefulWidget {
  const ListaComprasGerentePage({super.key});

  @override
  State<ListaComprasGerentePage> createState() => _ListaComprasGerentePageState();
}

class _ListaComprasGerentePageState extends State<ListaComprasGerentePage> {
  final bool _gerentePodeComprar = true; 
  final TextEditingController _justController = TextEditingController();

  List<Map<String, dynamic>> comprasDoDia = [
    {"id": "compra_01", "nome": "Carne Moída", "status": "PENDENTE", "obs": ""},
    {"id": "compra_02", "nome": "Leite Condensado", "status": "PENDENTE", "obs": "Pegar marca Nestlé"},
    {"id": "compra_03", "nome": "Tomate Italiano", "status": "COMPRADO", "obs": "Já comprado no Ceasa"},
  ];

  static const Color accentColor = Color(0xFF2979FF); // Azul Cobalto Gerencial

  @override
  void dispose() {
    _justController.dispose();
    super.dispose();
  }

  void _abrirEdicao(int index, Color baseTextColor, Color hintColor) {
    if (!_gerentePodeComprar) return;
    _justController.text = comprasDoDia[index]['obs'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("OBSERVAÇÕES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
        content: TextField(
          controller: _justController,
          maxLines: 2,
          style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Ex: Já na transportadora",
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => comprasDoDia.removeAt(index));
              Navigator.pop(context);
            },
            child: Text("REMOVER", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              setState(() => comprasDoDia[index]['obs'] = _justController.text.trim());
              Navigator.pop(context);
            },
            child: Text("SALVAR", style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("LISTA DE COMPRAS", style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (!_gerentePodeComprar)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded, size: 16, color: Colors.orange.shade400),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Modo Visualização. Solicite permissão ao Proprietário.", style: TextStyle(fontSize: 12, color: Colors.orange.shade400, fontWeight: FontWeight.w800))),
                ],
              ),
            ),
          
          Expanded(
            child: comprasDoDia.isEmpty
                ? Center(child: Text("Lista vazia.", style: TextStyle(color: hintColor, fontWeight: FontWeight.w600)))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    itemCount: comprasDoDia.length,
                    itemBuilder: (context, index) {
                      final item = comprasDoDia[index];
                      final bool isComprado = item['status'] == 'COMPRADO';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: _gerentePodeComprar
                              ? Checkbox(
                                  value: isComprado,
                                  activeColor: accentColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (v) => setState(() => item['status'] = v! ? 'COMPRADO' : 'PENDENTE'),
                                )
                              : Icon(isComprado ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: isComprado ? accentColor : hintColor),
                          title: Text(item['nome'], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isComprado ? hintColor : baseTextColor, decoration: isComprado ? TextDecoration.lineThrough : null)),
                          subtitle: item['obs'].toString().isNotEmpty 
                            ? Text(item['obs'], style: TextStyle(fontSize: 11, color: isComprado ? hintColor.withOpacity(0.3) : accentColor.withOpacity(0.8), fontWeight: FontWeight.w600)) 
                            : null,
                          trailing: _gerentePodeComprar
                              ? IconButton(icon: Icon(Icons.edit_note_rounded, color: hintColor), onPressed: () => _abrirEdicao(index, baseTextColor, hintColor))
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}