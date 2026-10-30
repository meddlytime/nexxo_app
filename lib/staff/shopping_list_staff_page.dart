import 'package:flutter/material.dart';

class ListaComprasFuncionarioPage extends StatefulWidget {
  const ListaComprasFuncionarioPage({super.key});

  @override
  State<ListaComprasFuncionarioPage> createState() => _ListaComprasFuncionarioPageState();
}

class _ListaComprasFuncionarioPageState extends State<ListaComprasFuncionarioPage> {

  static const Color accentColor = Color(0xFF00E676);

  final List<Map<String, dynamic>> _itensParaSolicitar = [
    {"id": "doc_leite", "nome": "Whole Milk", "qtd": 2.0, "min": 10.0, "solicitado": false},
    {"id": "doc_manteiga", "nome": "Butter 500g", "qtd": 1.0, "min": 5.0, "solicitado": false},
    {"id": "doc_lixo", "nome": "Trash Bag 100L", "qtd": 0.0, "min": 3.0, "solicitado": false},
  ];

  final Map<String, bool> _processingItems = {}; 

  void _solicitarItemNoFirebase(int index, Map<String, dynamic> item) async {
    final String itemId = item['id'];
    
    setState(() => _processingItems[itemId] = true);

    await Future.delayed(const Duration(milliseconds: 600)); 

    if (!mounted) return;
    setState(() {
      _itensParaSolicitar[index]['solicitado'] = true;
      _processingItems[itemId] = false;
    });

    _notificarEnvio(item['nome']);
  }

  void _notificarEnvio(String produto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${produto.toUpperCase()} SENT TO MANAGEMENT", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5, fontSize: 12)),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
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
    final borderColor = isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("RESTOCK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: baseTextColor, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: Column(
        children: [

          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: accentColor, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "These items have reached the minimum stock threshold. Confirm the request so Management can purchase them.",
                    style: TextStyle(color: isEscuro ? Colors.white70 : Colors.black87, fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: _itensParaSolicitar.length,
              itemBuilder: (context, index) {
                final item = _itensParaSolicitar[index];
                final bool jaSolicitado = item['solicitado'];
                final String itemId = item['id'];
                final bool isItemLoading = _processingItems[itemId] ?? false;

                String displayQtd = item['qtd'] == item['qtd'].toInt() ? item['qtd'].toInt().toString() : item['qtd'].toStringAsFixed(1);
                String displayMin = item['min'] == item['min'].toInt() ? item['min'].toInt().toString() : item['min'].toStringAsFixed(1);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: jaSolicitado ? accentColor.withOpacity(0.4) : borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nome'].toString().toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: jaSolicitado ? hintColor : baseTextColor,
                                decoration: jaSolicitado ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "STOCK: $displayQtd / MIN: $displayMin",
                                style: TextStyle(color: hintColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: (jaSolicitado || isItemLoading) ? null : () => _solicitarItemNoFirebase(index, item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            disabledBackgroundColor: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isItemLoading
                              ? const SizedBox(
                                  height: 16, width: 16,
                                  child: CircularProgressIndicator(color: accentColor, strokeWidth: 2),
                                )
                              : Text(
                                  jaSolicitado ? "SENT" : "REQUEST",
                                  style: TextStyle(
                                    color: jaSolicitado ? hintColor : Colors.black,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    fontSize: 11
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                "Requested items will instantly appear on the Owner's Checklist.",
                textAlign: TextAlign.center,
                style: TextStyle(color: hintColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}