import 'package:flutter/material.dart';
import 'package:app_estoque/comum/cadastro_itens_page.dart';

class SetupEstoquePage extends StatefulWidget {
  const SetupEstoquePage({super.key});

  @override
  State<SetupEstoquePage> createState() => _SetupEstoquePageState();
}

class _SetupEstoquePageState extends State<SetupEstoquePage> {
  final TextEditingController _novaCategoriaController = TextEditingController();

  final List<Map<String, dynamic>> _categorias = [
    {"nome": "Carnes", "icon": Icons.restaurant, "selecionado": false},
    {"nome": "Bebidas", "icon": Icons.local_bar, "selecionado": false},
    {"nome": "Hortifruti", "icon": Icons.eco, "selecionado": false},
    {"nome": "Limpeza", "icon": Icons.cleaning_services, "selecionado": false},
    {"nome": "Cereais", "icon": Icons.grain, "selecionado": false},
  ];

  static const Color accentColor = Color(0xFF00E676);

  @override
  void dispose() {
    _novaCategoriaController.dispose();
    super.dispose();
  }

  void _irParaCadastroItens() {
    final selecionadas = _categorias.where((c) => c['selecionado'] == true).map((c) => c['nome'] as String).toList();
    
    if (selecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione ao menos uma categoria."), backgroundColor: Colors.redAccent));
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => CadastroItensPage(categoriesSelecionadas: selecionadas)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Categorias do Estoque", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text("Selecione os setores que fazem parte do seu negócio.", style: TextStyle(color: isEscuro ? Colors.white54 : Colors.black54, fontSize: 14)),
            const SizedBox(height: 30),

            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
                ),
                itemCount: _categorias.length + 1,
                itemBuilder: (context, index) {
                  if (index == _categorias.length) return _buildCardAdd(isEscuro);
                  final cat = _categorias[index];
                  return _buildCategoryCard(index, cat, isEscuro, baseTextColor);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _irParaCadastroItens,
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text("CONTINUAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(int index, Map<String, dynamic> cat, bool isEscuro, Color baseTextColor) {
    bool sel = cat['selecionado'];
    return InkWell(
      onTap: () => setState(() => _categorias[index]['selecionado'] = !sel),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: sel ? accentColor.withOpacity(0.08) : (isEscuro ? const Color(0xFF121214) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? accentColor : (isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat['icon'], color: sel ? accentColor : (isEscuro ? Colors.white30 : Colors.black.withOpacity(0.3)), size: 30),
            const SizedBox(height: 10),
            Text(cat['nome'], style: TextStyle(color: sel ? accentColor : baseTextColor, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAdd(bool isEscuro) {
    return InkWell(
      onTap: _exibirModalAdicionar,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, // Fundo transparente
          borderRadius: BorderRadius.circular(20),
          // Borda sólida com baixa opacidade para criar o efeito de "slot vazio"
          border: Border.all(
            color: isEscuro ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15),
            style: BorderStyle.solid, 
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: isEscuro ? Colors.white54 : Colors.black54, size: 28),
            const SizedBox(height: 8),
            Text(
              "Personalizar", 
              style: TextStyle(
                color: isEscuro ? Colors.white54 : Colors.black54, 
                fontSize: 12, 
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exibirModalAdicionar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nova Categoria", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accentColor)),
            const SizedBox(height: 20),
            TextField(
              controller: _novaCategoriaController,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Ex: Padaria",
                filled: true,
                fillColor: Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  if (_novaCategoriaController.text.trim().isNotEmpty) {
                    setState(() => _categorias.add({"nome": _novaCategoriaController.text.trim(), "icon": Icons.category_rounded, "selecionado": true}));
                    _novaCategoriaController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text("ADICIONAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}