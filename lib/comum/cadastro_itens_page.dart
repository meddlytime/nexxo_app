import 'package:flutter/material.dart';
import 'package:app_estoque/patrao/dashboard_patrao_page.dart';

class CadastroItensPage extends StatefulWidget {
  final List<String> categoriesSelecionadas;

  const CadastroItensPage({super.key, required this.categoriesSelecionadas});

  @override
  State<CadastroItensPage> createState() => _CadastroItensPageState();
}

class _CadastroItensPageState extends State<CadastroItensPage> {
  final Map<String, List<Map<String, dynamic>>> _itensPorCategoria = {};
  bool _isSaving = false;

  static const Color accentColor = Color(0xFF00E676); // Verde Nexo

  @override
  void initState() {
    super.initState();
    for (var cat in widget.categoriesSelecionadas) {
      _itensPorCategoria[cat] = [];
    }
  }

  void _salvarInventarioNoFirebase() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPatrao()),
      (route) => false,
    );
  }

  void _abrirModalNovoItem(String categoria, bool isEscuro) {
    final modalFormKey = GlobalKey<FormState>();
    String nome = "";
    double qtd = 0;
    double min = 0;
    double precoCusto = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isEscuro ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: modalFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Novo em $categoria", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accentColor)),
              const SizedBox(height: 25),
              _buildInput(label: "Nome do Produto", hint: "Ex: Picanha", isEscuro: isEscuro, onChanged: (v) => nome = v),
              const SizedBox(height: 15),
              _buildInput(label: "Custo Unitário", hint: "0.00", prefix: "R\$ ", isNumber: true, isEscuro: isEscuro, onChanged: (v) => precoCusto = double.tryParse(v.replaceAll(',', '.')) ?? 0),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildInput(label: "Qtd Inicial", hint: "0", isNumber: true, isEscuro: isEscuro, onChanged: (v) => qtd = double.tryParse(v) ?? 0)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput(label: "Aviso Mín.", hint: "0", isNumber: true, isEscuro: isEscuro, onChanged: (v) => min = double.tryParse(v) ?? 0)),
                ],
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    if (modalFormKey.currentState!.validate()) {
                      setState(() {
                        _itensPorCategoria[categoria]!.add({"nome": nome.trim(), "qtd": qtd, "min": min, "custo": precoCusto});
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("ADICIONAR ITEM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final textColor = isEscuro ? Colors.white : const Color(0xFF111111);

    return DefaultTabController(
      length: widget.categoriesSelecionadas.length,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          automaticallyImplyLeading: false,
          title: Text("Estoque Inicial", style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 20, letterSpacing: -0.5)),
          actions: [
            if (!_isSaving)
              TextButton(
                onPressed: _salvarInventarioNoFirebase,
                child: const Text("CONCLUIR", style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            const SizedBox(width: 10),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: accentColor,
            labelColor: accentColor,
            unselectedLabelColor: isEscuro ? Colors.white24 : Colors.black26,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: widget.categoriesSelecionadas.map((cat) => Tab(text: cat.toUpperCase())).toList(),
          ),
        ),
        body: _isSaving 
            ? const Center(child: CircularProgressIndicator(color: accentColor))
            : TabBarView(
                children: widget.categoriesSelecionadas.map((cat) {
                  final itens = _itensPorCategoria[cat]!;
                  if (itens.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: isEscuro ? Colors.white10 : Colors.black12),
                          const SizedBox(height: 16),
                          Text("Nenhum item em $cat.\nToque no + para começar.", textAlign: TextAlign.center, style: TextStyle(color: isEscuro ? Colors.white30 : Colors.black38, fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: itens.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Text(itens[index]['nome'], style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: Text("Custo: R\$ ${itens[index]['custo'].toStringAsFixed(2)}", style: TextStyle(color: isEscuro ? Colors.white38 : Colors.black38, fontSize: 12)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${itens[index]['qtd']}", style: const TextStyle(color: accentColor, fontSize: 20, fontWeight: FontWeight.w900)),
                            const Text("UN", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
        floatingActionButton: _isSaving ? null : Builder(builder: (context) => FloatingActionButton(
          backgroundColor: accentColor,
          elevation: 4,
          onPressed: () => _abrirModalNovoItem(widget.categoriesSelecionadas[DefaultTabController.of(context).index], isEscuro),
          child: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
        )),
      ),
    );
  }

  Widget _buildInput({required String label, required String hint, bool isNumber = false, String? prefix, required bool isEscuro, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: const TextStyle(color: accentColor, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentColor, width: 1.0)),
          ),
          validator: (v) => (v == null || v.isEmpty) ? "Obrigatório" : null,
        ),
      ],
    );
  }
}