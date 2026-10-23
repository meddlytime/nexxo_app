import 'package:flutter/material.dart';
import 'package:app_estoque/comum/scanner_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_estoque/comum/estoque_repository.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final EstoqueRepository _repository = EstoqueRepository();
  List<Map<String, dynamic>> _itensInventario = [];
  final Map<int, TextEditingController> _controllers = {};
  
  bool _isLoading = true;
  bool _isProcessando = false;

  // Diretriz estética Nexo Obsidian
  static const Color accentColor = Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _carregarEstoqueParaContagem();
  }

  void _carregarEstoqueParaContagem() {
    final estoqueLocal = _repository.obterEstoqueLocal();
    
    setState(() {
      _itensInventario = estoqueLocal.map((produto) {
        final double qtdAtual = double.tryParse(produto['qtd'].toString()) ?? 0.0;
        return {
          "id": produto['id'],
          "nome": produto['nome'],
          "categoria": produto['categoria'] ?? "Outros",
          "esperado": qtdAtual,
          "contado": qtdAtual, 
          "motivo": "Nenhum"
        };
      }).toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _atualizarContagem(int index, String valor) {
    final valorFormatado = valor.replaceAll(',', '.');
    final qtd = double.tryParse(valorFormatado) ?? 0.0;
    
    setState(() {
      _itensInventario[index]["contado"] = qtd;
    });
  }

  void _processarCodigoBipado(String codigo) {
    int index = _itensInventario.indexWhere((item) => item["id"] == codigo);
    if (index != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ITEM LOCALIZADO: ${_itensInventario[index]["nome"].toUpperCase()}"), 
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🚨 ITEM NÃO ENCONTRADO NESTE INVENTÁRIO!"), 
          backgroundColor: Colors.redAccent.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _concluirEEnviarAuditoria(List<Map<String, dynamic>> divergencias) async {
    setState(() => _isProcessando = true);
    
    try {
      final batch = FirebaseFirestore.instance.batch();
      final String unidadeId = "unidade_centro"; 

      for (var item in divergencias) {
        final docRef = FirebaseFirestore.instance
            .collection('unidades')
            .doc(unidadeId)
            .collection('produtos')
            .doc(item["id"]);
            
        batch.update(docRef, {'qtd': item["contado"]});
      }

      final auditRef = FirebaseFirestore.instance
          .collection('unidades')
          .doc(unidadeId)
          .collection('auditorias')
          .doc();
          
      batch.set(auditRef, {
        'data_fechamento': FieldValue.serverTimestamp(),
        'responsavel': 'Operador Logado', 
        'total_itens_conferidos': _itensInventario.length,
        'divergencias': divergencias.map((e) => {
          'id': e['id'],
          'nome': e['nome'],
          'esperado': e['esperado'],
          'contado': e['contado'],
          'diferenca': e['contado'] - e['esperado'], 
          'motivo': e['motivo']
        }).toList(),
      });

      await batch.commit();
      await _repository.sincronizarSrvParaLocal(unidadeId);

      if (!mounted) return;
      Navigator.pop(context); 
      Navigator.pop(context); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Balanço e Auditoria gravados com sucesso!"), 
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao sincronizar auditoria: $e"), 
          backgroundColor: Colors.redAccent.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessando = false);
    }
  }

  void _abrirModalRevisao() {
    final divergencias = _itensInventario.where((item) => item["contado"] != item["esperado"]).toList();

    if (divergencias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfeito! Nenhuma divergência encontrada no estoque."), 
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("JUSTIFICAR CONTA DE QUEBRAS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: divergencias.length,
              itemBuilder: (context, idx) {
                final item = divergencias[idx];
                final double dif = item["contado"] - item["esperado"];
                final bool isQuebra = dif < 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item["nome"].toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF111111))),
                      const SizedBox(height: 4),
                      Text(
                        "DIFERENÇA: ${dif > 0 ? '+' : ''}${dif.toStringAsFixed(1)} UN/KG", 
                        style: TextStyle(color: isQuebra ? Colors.redAccent.shade400 : Colors.orangeAccent.shade700, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: item["motivo"] == "Nenhum" ? "Erro de Digitação" : item["motivo"],
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF111111), fontSize: 13, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isQuebra ? Colors.redAccent.shade400 : accentColor, width: 1.0)),
                        ),
                        items: ["Erro de Digitação", "Produto Vencido", "Furto ou Avaria", "Desperdício de Production", "Sobra Não Contabilizada"]
                            .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (v) {
                          setDialogState(() {
                            item["motivo"] = v!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isProcessando ? null : () => Navigator.pop(ctx),
              child: Text("VOLTAR", style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: _isProcessando ? null : () => _concluirEEnviarAuditoria(divergencias),
              child: _isProcessando 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text("GRAVAR AUDITORIA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB),
        body: const Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    return Scaffold(
      backgroundColor: isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text("BALANÇO GERAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: baseTextColor),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner_rounded, color: isEscuro ? Colors.white.withOpacity(0.7) : Colors.black87, size: 22),
            onPressed: () async {
              final codigo = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ScannerPage())
              );
              if (codigo != null) _processarCodigoBipado(codigo);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Painel Informativo alinhado com o Nexo Obsidian
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
                    "Insira a quantidade física real encontrada. O motor calculará quebras e sobras de auditoria automaticamente ao fechar o lote.",
                    style: TextStyle(color: isEscuro ? Colors.white70 : Colors.black87, fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _itensInventario.isEmpty 
              ? Center(child: Text("Nenhum item localizado no lote.", style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.w700)))
              : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: _itensInventario.length,
              itemBuilder: (context, index) {
                final item = _itensInventario[index];
                final double esperado = item["esperado"];
                final double contado = item["contado"];
                final double diferenca = contado - esperado;

                String displayEsperado = esperado == esperado.toInt() ? esperado.toInt().toString() : esperado.toStringAsFixed(1);
                String displayContado = contado == contado.toInt() ? contado.toInt().toString() : contado.toStringAsFixed(1);
                String displayDiferenca = diferenca == diferenca.toInt() ? diferenca.toInt().toString() : diferenca.toStringAsFixed(1);

                _controllers[index] ??= TextEditingController(text: displayContado);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: diferenca != 0 
                          ? (diferenca < 0 ? Colors.redAccent.shade400.withOpacity(0.3) : Colors.orangeAccent.shade700.withOpacity(0.3))
                          : (isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["nome"].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: baseTextColor)),
                            const SizedBox(height: 6),
                            Text("SISTEMA: $displayEsperado UN/KG", style: TextStyle(color: theme.hintColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                      
                      if (diferenca != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: diferenca < 0 ? Colors.redAccent.shade400.withOpacity(0.1) : Colors.orangeAccent.shade700.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            diferenca < 0 ? "$displayDiferenca UN" : "+$displayDiferenca UN",
                            style: TextStyle(color: diferenca < 0 ? Colors.redAccent.shade400 : Colors.orangeAccent.shade700, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ),

                      SizedBox(
                        width: 85,
                        height: 45,
                        child: TextField(
                          controller: _controllers[index],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: baseTextColor, fontSize: 15, fontWeight: FontWeight.w900),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: diferenca != 0 ? (diferenca < 0 ? Colors.redAccent.shade400 : Colors.orangeAccent.shade700) : accentColor, width: 1.0)),
                          ),
                          onChanged: (v) => _atualizarContagem(index, v),
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor, 
                    elevation: 0, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  onPressed: _itensInventario.isEmpty ? null : _abrirModalRevisao,
                  child: const Text("CONCLUIR CONTAGEM DE LOTE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}