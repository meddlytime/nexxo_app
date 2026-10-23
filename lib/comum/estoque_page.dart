import 'package:flutter/material.dart';
import 'package:app_estoque/comum/scanner_page.dart';
import 'package:app_estoque/comum/estoque_repository.dart'; 

class EstoquePage extends StatefulWidget {
  final bool filtrarCriticos;
  
  const EstoquePage({super.key, this.filtrarCriticos = false});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _ThemeContextHelper {
  final ThemeData theme;
  final bool isEscuro;
  final Color baseTextColor;
  final Color cardColor;
  final Color bgColor;

  _ThemeContextHelper(this.theme)
      : isEscuro = theme.brightness == Brightness.dark,
        baseTextColor = theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF111111),
        bgColor = theme.brightness == Brightness.dark ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB),
        cardColor = theme.brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white;
}

class _EstoquePageState extends State<EstoquePage> {
  final EstoqueRepository _repository = EstoqueRepository(); 
  final String _unidadeId = "unidade_centro"; 

  List<String> categorias = ["Carnes", "Hortifrúti", "Bebidas", "Limpeza", "Grãos"];
  String categoryFiltroAtiva = "Todos";
  String _buscaQuery = "";
  List<Map<String, dynamic>> _produtosCacheados = [];

  final TextEditingController _novaCategoriaController = TextEditingController();
  final TextEditingController _pesquisaController = TextEditingController();

  static const Color accentColor = Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _carregarDadosFisicos();
  }

  Future<void> _carregarDadosFisicos() async {
    setState(() {
      _produtosCacheados = _repository.obterEstoqueLocal();
    });
    
    await _repository.processarFilaOffline();
    await _repository.sincronizarSrvParaLocal(_unidadeId);
    
    if (mounted) {
      setState(() {
        _produtosCacheados = _repository.obterEstoqueLocal();
      });
    }
  }

  @override
  void dispose() {
    _novaCategoriaController.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }

  void _abrirCadastroProduto(_ThemeContextHelper ctx) {
    String nome = "";
    double quantidade = 0;
    double minimo = 0;
    String categoriaSelecionada = categorias.first;
    bool itemDuplicado = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ctx.theme.brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Novo Item no Estoque", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 0.5)),
                const SizedBox(height: 24),
                
                TextField(
                  style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputStyle(label: "Nome do Produto", theme: ctx.theme),
                  onChanged: (v) {
                    nome = v.trim();
                    final existe = _produtosCacheados.any((p) => p['nome'].toString().toLowerCase() == nome.toLowerCase());
                    setModalState(() {
                      itemDuplicado = existe;
                    });
                  },
                ),
                
                if (itemDuplicado) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFF9100).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9100), size: 18),
                        SizedBox(width: 10),
                        Expanded(child: Text("Item já cadastrado no inventário!", style: TextStyle(color: Color(0xFFFF9100), fontSize: 12, fontWeight: FontWeight.w800))),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: categoriaSelecionada,
                  dropdownColor: ctx.cardColor,
                  style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputStyle(label: "Categoria", theme: ctx.theme),
                  items: categorias.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                  onChanged: (v) => categoriaSelecionada = v ?? categorias.first,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: _inputStyle(label: "Qtd Inicial", theme: ctx.theme),
                        onChanged: (v) => quantidade = double.tryParse(v) ?? 0.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: _inputStyle(label: "Aviso Mínimo", theme: ctx.theme),
                        onChanged: (v) => minimo = double.tryParse(v) ?? 0.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: itemDuplicado ? ctx.theme.disabledColor : accentColor, 
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: itemDuplicado ? null : () async {
                      if (nome.isNotEmpty && quantidade >= 0 && minimo >= 0) {
                        await _repository.atualizarQuantidadeEstoque(
                          unidadeId: _unidadeId,
                          produtoId: "p_${DateTime.now().millisecondsSinceEpoch}", 
                          novaQuantidade: quantidade,
                        );
                        _carregarDadosFisicos();
                        Navigator.pop(context);
                      }
                    },
                    child: Text("CADASTRAR INSUMO", style: TextStyle(color: itemDuplicado ? Colors.white.withOpacity(0.54) : Colors.black, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  void _abrirEdicaoProduto(Map<String, dynamic> produto, _ThemeContextHelper ctx) {
    final nomeEditController = TextEditingController(text: produto['nome']);
    final qtdEditController = TextEditingController(text: produto['qtd'].toString());
    final minEditController = TextEditingController(text: produto['min'].toString());
    String categoriaSelecionada = produto['categoria'] ?? "Carnes";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ctx.theme.brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Editar Insumo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF2979FF), letterSpacing: 0.5)),
            const SizedBox(height: 24),
            TextField(
              controller: nomeEditController,
              enabled: false, 
              style: TextStyle(color: ctx.theme.hintColor, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: _inputStyle(label: "Nome do Produto", theme: ctx.theme),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: categoriaSelecionada,
              dropdownColor: ctx.cardColor,
              style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: _inputStyle(label: "Categoria", theme: ctx.theme),
              items: categorias.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
              onChanged: (v) => categoriaSelecionada = v ?? produto['categoria'],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtdEditController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: _inputStyle(label: "Qtd Atual", theme: ctx.theme),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: minEditController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: _inputStyle(label: "Alerta Mín.", theme: ctx.theme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2979FF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () async {
                  final double novaQtd = double.tryParse(qtdEditController.text) ?? double.parse(produto['qtd'].toString());
                  await _repository.atualizarQuantidadeEstoque(unidadeId: _unidadeId, produtoId: produto['id'], novaQuantidade: novaQtd);
                  _carregarDadosFisicos();
                  Navigator.pop(context);
                },
                child: const Text("SALVAR ALTERAÇÕES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _abrirGerenciadorCategorias(_ThemeContextHelper ctx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ctx.theme.brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Categorias", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: ctx.baseTextColor, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text("Crie ou remova divisões do estoque.", style: TextStyle(fontSize: 13, color: ctx.isEscuro ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.54), fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _novaCategoriaController,
                        style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: "Ex: Descartáveis",
                          hintStyle: TextStyle(color: ctx.isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), fontSize: 13),
                          filled: true,
                          fillColor: ctx.isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52, width: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor, elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        onPressed: () {
                          final nova = _novaCategoriaController.text.trim();
                          if (nova.isNotEmpty && !categorias.contains(nova)) {
                            setState(() => categorias.add(nova));
                            setModalState(() {}); 
                            _novaCategoriaController.clear();
                          }
                        },
                        child: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: ctx.isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: categorias.length,
                    itemBuilder: (context, idx) {
                      final cat = categorias[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.label_outline_rounded, color: ctx.isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), size: 20),
                        title: Text(cat, style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.shade400, size: 20),
                          onPressed: () {
                            setState(() {
                              categorias.remove(cat);
                              if (categoryFiltroAtiva == cat) categoryFiltroAtiva = "Todos";
                            });
                            setModalState(() {}); 
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _abrirModalBaixaDesperdicio(Map<String, dynamic> produto, _ThemeContextHelper ctx) {
    // 🛡️ Altere para "GERENTE" ou "PATRAO" para liberar a exibição financeira de custos
    final String perfilSimuladoNoApp = "FUNCIONARIO"; 
    final bool temPermissaoDeGestao = perfilSimuladoNoApp == "GERENTE" || perfilSimuladoNoApp == "PATRAO";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ctx.theme.brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => ModalBaixaEstoque(
        produtoNome: produto['nome'],
        precoCusto: double.tryParse(produto['preco'].toString()) ?? 0.0,
        categoria: produto['categoria'] ?? 'Outros',
        estoqueAtual: double.tryParse(produto['qtd'].toString()) ?? 0.0,
        podeVerCustos: temPermissaoDeGestao,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctx = _ThemeContextHelper(Theme.of(context));

    final List<Map<String, dynamic>> fonteDados = _produtosCacheados.isEmpty ? [
      {"id": "p01", "nome": "Picanha Argentina", "qtd": 4.0, "min": 10.0, "categoria": "Carnes", "preco": 90.00},
      {"id": "p02", "nome": "Tomate Italiano", "qtd": 12.0, "min": 8.0, "categoria": "Hortifrúti", "preco": 12.00},
      {"id": "p03", "nome": "Cerveja Artesanal IPA", "qtd": 45.0, "min": 20.0, "categoria": "Bebidas", "preco": 15.00},
      {"id": "p04", "nome": "Detergente Concentrado 5L", "qtd": 2.0, "min": 5.0, "categoria": "Limpeza", "preco": 25.00},
      {"id": "p05", "nome": "Feijão Carioca 1kg", "qtd": 5.0, "min": 15.0, "categoria": "Grãos", "preco": 8.50},
    ] : _produtosCacheados;

    final produtosFiltrados = fonteDados.where((p) {
      final bateCategoria = categoryFiltroAtiva == "Todos" || p['categoria'] == categoryFiltroAtiva;
      final double qtdVal = double.tryParse(p['qtd'].toString()) ?? 0.0;
      final double minVal = double.tryParse(p['min'].toString()) ?? 0.0;
      
      final bateCritico = !widget.filtrarCriticos || (qtdVal <= minVal);
      final batePesquisa = p['nome'].toString().toLowerCase().contains(_buscaQuery.toLowerCase());
      return bateCategoria && bateCritico && batePesquisa;
    }).toList();

    return Scaffold(
      backgroundColor: ctx.bgColor,
      appBar: AppBar(
        title: Text("Inventário", style: TextStyle(color: ctx.baseTextColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner_rounded, color: ctx.isEscuro ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.87), size: 22),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerPage())),
          ),
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: accentColor, size: 24),
            onPressed: () => _abrirCadastroProduto(ctx),
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: ctx.isEscuro ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.87), size: 22),
            onPressed: () => _abrirGerenciadorCategorias(ctx),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _pesquisaController,
              style: TextStyle(color: ctx.baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
              onChanged: (v) => setState(() => _buscaQuery = v),
              decoration: InputDecoration(
                hintText: "Buscar no estoque...",
                hintStyle: TextStyle(color: ctx.isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: ctx.isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), size: 20),
                filled: true,
                fillColor: ctx.isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _buildChipFiltro("Todos", ctx),
                ...categorias.map((cat) => _buildChipFiltro(cat, ctx)),
              ],
            ),
          ),
          
          Expanded(
            child: produtosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: ctx.isEscuro ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.12)),
                        const SizedBox(height: 16),
                        Text("Nenhum item localizado.", style: TextStyle(color: ctx.isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.38), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _carregarDadosFisicos, 
                    color: accentColor,
                    backgroundColor: ctx.cardColor,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
                      itemCount: produtosFiltrados.length,
                      itemBuilder: (context, index) {
                        final prod = produtosFiltrados[index];
                        final double qtdVal = double.tryParse(prod['qtd'].toString()) ?? 0.0;
                        final double minVal = double.tryParse(prod['min'].toString()) ?? 0.0;
                        final bool eCritico = qtdVal <= minVal;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _abrirEdicaoProduto(prod, ctx), 
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ctx.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: eCritico ? Colors.redAccent.shade400.withOpacity(0.4) : (ctx.isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(prod['nome'], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: ctx.baseTextColor, letterSpacing: 0.2)),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: eCritico ? Colors.redAccent.shade400.withOpacity(0.1) : (ctx.isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            (prod['categoria'] ?? "Carnes").toString().toUpperCase(),
                                            style: TextStyle(color: eCritico ? Colors.redAccent.shade400 : (ctx.isEscuro ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.54)), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text("${prod['qtd']} un", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: eCritico ? Colors.redAccent.shade400 : accentColor)),
                                          const SizedBox(height: 2),
                                          Text("Mín: ${prod['min']}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ctx.isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.38))),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.shade400.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent.shade400, size: 22),
                                          onPressed: () => _abrirModalBaixaDesperdicio(prod, ctx),
                                          tooltip: "Registrar Baixa / Desperdício",
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipFiltro(String nome, _ThemeContextHelper ctx) {
    final bool ativo = categoryFiltroAtiva == nome;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(nome, style: TextStyle(color: ativo ? Colors.black : (ctx.isEscuro ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.54)), fontSize: 12, fontWeight: FontWeight.w800)),
        selected: ativo,
        onSelected: (val) => setState(() => categoryFiltroAtiva = nome),
        selectedColor: accentColor,
        backgroundColor: ctx.isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
      ),
    );
  }

  InputDecoration _inputStyle({required String label, required ThemeData theme}) {
    final isEscuro = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.54), fontSize: 13, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accentColor, width: 1.0)),
    );
  }
}

// --- MODAL DE BAIXA E DESPERDÍCIO INTELIGENTE ---
class ModalBaixaEstoque extends StatefulWidget {
  final String produtoNome;
  final double precoCusto;
  final String categoria;
  final double estoqueAtual;
  final bool podeVerCustos;

  const ModalBaixaEstoque({
    super.key,
    required this.produtoNome,
    required this.precoCusto,
    required this.categoria,
    required this.estoqueAtual,
    required this.podeVerCustos, 
  });

  @override
  State<ModalBaixaEstoque> createState() => _ModalBaixaEstoqueState();
}

class _ModalBaixaEstoqueState extends State<ModalBaixaEstoque> {
  final TextEditingController _qtdController = TextEditingController();
  String _motivoSelecionado = "Quebra / Preparo";
  
  final bool _isPlanoPremium = true;
  final bool _alertaAtivadoPeloPatrao = true;
  final double _reguaCorteCritica = 100.00; 

  final List<String> _motivos = [
    "Quebra / Preparo",
    "Produto Vencido",
    "Avaria / Estragado",
    "Uso Interno / Teste"
  ];

  double _quantidadeInserida = 0.0;

  @override
  void initState() {
    super.initState();
    _qtdController.addListener(() {
      setState(() {
        _quantidadeInserida = double.tryParse(_qtdController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _qtdController.dispose();
    super.dispose();
  }

  double get _prejuizoCalculado => _quantidadeInserida * widget.precoCusto;
  bool get _isGravidadeCritica => _prejuizoCalculado >= _reguaCorteCritica;

  Color get _corAtivaDaInterface {
    if (!widget.podeVerCustos) {
      return const Color(0xFF2979FF); 
    }
    return _isGravidadeCritica ? Colors.redAccent.shade400 : const Color(0xFF2979FF); 
  }

  void _processarBaixa() async {
    if (_quantidadeInserida <= 0 || _quantidadeInserida > widget.estoqueAtual) {
      _mostrarAviso("Quantidade inválida ou superior ao estoque atual.");
      return;
    }

    if (_isPlanoPremium && _alertaAtivadoPeloPatrao && _isGravidadeCritica) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🚨 ALERTA CRÍTICO: Notificação enviada ao celular da Gestão!"),
          backgroundColor: Colors.redAccent.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Estoque atualizado e enviado para auditoria."),
        backgroundColor: Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("REGISTRAR BAIXA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
              if (widget.podeVerCustos) _buildBadgeGravidade(),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.produtoNome.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: baseTextColor)),
          const SizedBox(height: 24),

          TextField(
            controller: _qtdController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w700),
            decoration: _inputDecorationStyle("Quantidade a reduzir (Estoque: ${widget.estoqueAtual})"),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _motivoSelecionado,
                dropdownColor: cardColor,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: baseTextColor),
                style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w700, fontSize: 14),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _motivoSelecionado = newValue);
                },
                items: _motivos.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
              ),
            ),
          ),
          
          if (widget.podeVerCustos) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isGravidadeCritica ? Colors.redAccent.shade400.withOpacity(0.05) : const Color(0xFF2979FF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isGravidadeCritica ? Colors.redAccent.shade400.withOpacity(0.2) : const Color(0xFF2979FF).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PREJUÍZO ESTIMADO", style: TextStyle(fontSize: 10, color: hintColor, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text("R\$ ${_prejuizoCalculado.toStringAsFixed(2)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _isGravidadeCritica ? Colors.redAccent.shade400 : baseTextColor)),
                    ],
                  ),
                  Icon(
                    _isGravidadeCritica ? Icons.gavel_rounded : Icons.trending_down_rounded, 
                    color: _isGravidadeCritica ? Colors.redAccent.shade400 : const Color(0xFF2979FF), 
                    size: 28
                  )
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _corAtivaDaInterface, 
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _processarBaixa,
              child: const Text("CONFIRMAR BAIXA NO ESTOQUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGravidade() {
    final Color corBadge = _isGravidadeCritica ? Colors.redAccent.shade400 : const Color(0xFF00E676);
    final String textoBadge = _isGravidadeCritica ? "GRAVIDADE: CRÍTICA" : "GRAVIDADE: NORMAL";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: corBadge.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: corBadge.withOpacity(0.3))
      ),
      child: Text(
        textoBadge,
        style: TextStyle(color: corBadge, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5),
      ),
    );
  }

  InputDecoration _inputDecorationStyle(String label) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _corAtivaDaInterface, width: 1.0)),
    );
  }

  void _mostrarAviso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.orangeAccent.shade700, behavior: SnackBarBehavior.floating));
  }
}