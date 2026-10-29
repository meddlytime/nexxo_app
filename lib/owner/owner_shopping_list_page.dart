import 'package:flutter/material.dart';

class ListaComprasPatraoPage extends StatefulWidget {
  const ListaComprasPatraoPage({super.key});

  @override
  State<ListaComprasPatraoPage> createState() => _ListaComprasPatraoPageState();
}

class _ListaComprasPatraoPageState extends State<ListaComprasPatraoPage> {
  // 🛰️ LISTA ESTRUTURADA COM ID EXCLUSIVO PARA SEGURANÇA NO FIRESTORE
  List<Map<String, dynamic>> comprasDoDia = [
    {"id": "compra_01", "nome": "Carne Moída", "status": "PENDENTE", "obs": ""},
    {"id": "compra_02", "nome": "Leite Condensado", "status": "PENDENTE", "obs": "Pegar da marca Nestlé se houver"},
    {"id": "compra_03", "nome": "Tomate Italiano", "status": "COMPRADO", "obs": "Já comprado no Ceasa"},
  ];
  
  // 🧠 FIX: Controlador único declarado no escopo do State para evitar Memory Leaks
  final TextEditingController _justController = TextEditingController();

  static const Color accentColor = Color(0xFF00E676); // Verde Nexo

  @override
  void dispose() {
    _justController.dispose(); 
    super.dispose();
  }

  void _adicionarJustificativa(int index, bool isEscuro, Color baseTextColor) {
    _justController.text = comprasDoDia[index]['obs'];
    final bgColor = isEscuro ? const Color(0xFF121214) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Anotação do Item", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 0.5)),
        content: TextField(
          controller: _justController,
          autofocus: true,
          style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Ex: Comprar na distribuidora",
            hintStyle: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), fontSize: 13),
            filled: true,
            fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: accentColor, width: 1.0),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () {
              final String itemNome = comprasDoDia[index]['nome'];
              final String itemId = comprasDoDia[index]['id'];

              setState(() {
                comprasDoDia.removeWhere((element) => element['id'] == itemId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$itemNome removido da lista."), behavior: SnackBarBehavior.floating),
              );
            }, 
            child: Text("EXCLUIR", style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              setState(() => comprasDoDia[index]['obs'] = _justController.text.trim());
              Navigator.pop(context);
            }, 
            child: const Text("SALVAR", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    // Paleta Nexo Obsidian
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("LISTA DE COMPRAS", style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: comprasDoDia.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 64, color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                    const SizedBox(height: 16),
                    Text("Tudo comprado!", style: TextStyle(color: hintColor, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text("Sua lista de compras está vazia.", style: TextStyle(color: hintColor.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: comprasDoDia.length,
                itemBuilder: (context, index) {
                  final item = comprasDoDia[index];
                  bool isComprado = item['status'] == 'COMPRADO';

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    decoration: BoxDecoration(
                      color: isComprado ? (isEscuro ? accentColor.withOpacity(0.05) : accentColor.withOpacity(0.05)) : cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isComprado ? accentColor.withOpacity(0.3) : (isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                        width: isComprado ? 1.0 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: isComprado,
                          activeColor: accentColor,
                          checkColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          side: BorderSide(color: isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), width: 1.5),
                          onChanged: (val) {
                            setState(() => item['status'] = val! ? 'COMPRADO' : 'PENDENTE');
                          },
                        ),
                      ),
                      title: Text(
                        item['nome'], 
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          decoration: isComprado ? TextDecoration.lineThrough : TextDecoration.none,
                          color: isComprado ? hintColor : baseTextColor
                        ),
                      ),
                      subtitle: item['obs'].toString().isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                item['obs'], 
                                style: TextStyle(
                                  color: isComprado ? hintColor.withOpacity(0.5) : const Color(0xFFFF9100), 
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.edit_note_rounded, 
                          color: isComprado ? hintColor.withOpacity(0.3) : hintColor
                        ),
                        onPressed: () => _adicionarJustificativa(index, isEscuro, baseTextColor),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}