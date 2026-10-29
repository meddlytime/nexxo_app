import 'package:flutter/material.dart';

class GerenteAprovacaoPage extends StatefulWidget {
  const GerenteAprovacaoPage({super.key});

  @override
  State<GerenteAprovacaoPage> createState() => _GerenteAprovacaoPageState();
}

class _GerenteAprovacaoPageState extends State<GerenteAprovacaoPage> {
  final List<Map<String, dynamic>> _solicitacoesMock = [
    {
      "id": "doc_solicitacao_01",
      "item": "Tomate Cereja",
      "quemPediu": "Cozinha - João",
      "motivo": "Acabou no almoço",
    },
    {
      "id": "doc_solicitacao_02",
      "item": "Filtro de Café",
      "quemPediu": "Copa - Maria",
      "motivo": "Último pacote aberto hoje",
    }
  ];

  final Map<String, bool> _processingItems = {};
  static const Color accentColor = Color(0xFF2979FF); // Azul Cobalto do Gerente

  void _atualizarStatusSolicitacao(String documentId, String novoStatus, String nomeItem) async {
    setState(() => _processingItems[documentId] = true);
    await Future.delayed(const Duration(milliseconds: 800)); 

    if (!mounted) return;
    setState(() {
      _processingItems[documentId] = false;
      _solicitacoesMock.removeWhere((element) => element['id'] == documentId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(novoStatus == "APROVADO" ? "$nomeItem enviado para lista!" : "$nomeItem rejeitado."),
        backgroundColor: novoStatus == "APROVADO" ? const Color(0xFF00E676) : Colors.redAccent.shade400,
        behavior: SnackBarBehavior.floating,
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
        title: Text("APROVAÇÕES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: Column(
        children: [
          _buildBannerPremium(isEscuro), 
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _solicitacoesMock.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: hintColor.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text("Tudo aprovado!", style: TextStyle(color: hintColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      itemCount: _solicitacoesMock.length,
                      itemBuilder: (context, index) {
                        final item = _solicitacoesMock[index];
                        final String docId = item['id'];
                        final bool isLoading = _processingItems[docId] ?? false;

                        return _buildCardAprovacao(
                          documentId: docId,
                          item: item['item'],
                          quemPediu: item['quemPediu'],
                          motivo: item['motivo'],
                          isLoading: isLoading,
                          isEscuro: isEscuro,
                          baseTextColor: baseTextColor,
                          cardColor: cardColor,
                          hintColor: hintColor,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPremium(bool isEscuro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9100).withOpacity(0.05),
        border: Border(bottom: BorderSide(color: const Color(0xFFFF9100).withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded, color: const Color(0xFFFF9100).withOpacity(0.8), size: 14),
          const SizedBox(width: 8),
          Text("MÓDULO MULTI-LOJA ATIVO", 
              style: TextStyle(color: const Color(0xFFFF9100).withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildCardAprovacao({
    required String documentId,
    required String item, 
    required String quemPediu, 
    required String motivo,
    required bool isLoading,
    required bool isEscuro,
    required Color baseTextColor,
    required Color cardColor,
    required Color hintColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: baseTextColor)),
              Icon(Icons.timer_outlined, color: hintColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text("Solicitado por: $quemPediu", style: const TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text("\"$motivo\"", style: TextStyle(color: hintColor, fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => _atualizarStatusSolicitacao(documentId, "REJEITADO", item),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent.shade400.withOpacity(0.4), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("REJEITAR", style: TextStyle(color: Colors.redAccent.shade400, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _atualizarStatusSolicitacao(documentId, "APROVADO", item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text("APROVAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}