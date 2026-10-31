import 'package:flutter/material.dart';

class RelatoriosPage extends StatefulWidget {
  final String unidadeInicial;
  const RelatoriosPage({super.key, required this.unidadeInicial});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  late String unidadeFiltro;
  String periodoSelecionado = "This Month";

  static const Color accentColor = Color(0xFF00E676); 

  @override
  void initState() {
    super.initState();
    unidadeFiltro = widget.unidadeInicial;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "INTELLIGENCE", 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isEscuro ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isEscuro ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: unidadeFiltro,
                dropdownColor: cardColor,
                icon: const Icon(Icons.storefront_rounded, color: accentColor, size: 16),
                style: const TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                items: ["Central Unit", "Shopping Unit", "Vila Gourmet (General)"]
                    .map((u) => DropdownMenuItem(
                          value: u, 
                          child: Text(
                            u,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => unidadeFiltro = val!),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Data from: $unidadeFiltro", 
                  style: TextStyle(color: isEscuro ? Colors.white.withValues(alpha: 0.54) : Colors.black.withValues(alpha: 0.54), fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              _buildSeletorPeriodo(isEscuro, cardColor),
            ],
          ),
          const SizedBox(height: 30),
          
          Row(
            children: [
              Expanded(child: _buildCardFinanceiro("TOTAL CAPITAL", "R\$ 12.450", const Color(0xFF2979FF), Icons.account_balance_wallet_rounded, isEscuro)),
              const SizedBox(width: 15),
              Expanded(child: _buildCardFinanceiro("LOSS (DAMAGE)", "R\$ 840", Colors.redAccent.shade400, Icons.trending_down_rounded, isEscuro)),
            ],
          ),
          
          const SizedBox(height: 35),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTituloSecao("INVESTMENT BY CATEGORY", accentColor),
              _buildPlaceholderGrafico(isEscuro, cardColor),
            ],
          ),
          
          const SizedBox(height: 35),
          
          _buildTituloSecao("TOP WASTE ITEMS (7 DAYS)", Colors.redAccent.shade400),
          _buildItemRanking("Italian Tomato", "12kg spoiled", Colors.redAccent.shade400, Icons.restore_from_trash_rounded, isEscuro, baseTextColor, cardColor),
          _buildItemRanking("Argentine Picanha", "2.5kg losses", const Color(0xFFFF9100), Icons.restore_from_trash_rounded, isEscuro, baseTextColor, cardColor),
          _buildItemRanking("Crisp Lettuce", "4 un discarded", Colors.amber.shade500, Icons.restore_from_trash_rounded, isEscuro, baseTextColor, cardColor),
          
          const SizedBox(height: 35),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTituloSecao("RANKING: TOP SELLERS/OUTFLOWS", const Color(0xFF2979FF)),
              _buildItemRanking("180g Blend Burger", "412 un sold", Colors.amber, Icons.stars_rounded, isEscuro, baseTextColor, cardColor),
              _buildItemRanking("French Fries", "280 portions", Colors.amber.shade600, Icons.stars_rounded, isEscuro, baseTextColor, cardColor),
              _buildItemRanking("Canned Soda 350ml", "195 un", Colors.amber.shade400, Icons.stars_rounded, isEscuro, baseTextColor, cardColor),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSeletorPeriodo(bool isEscuro, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isEscuro ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: periodoSelecionado, 
          dropdownColor: cardColor, 
          icon: const Icon(Icons.calendar_today_rounded, size: 14, color: accentColor),
          style: const TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 12), 
          items: ["Today", "This Week", "This Month"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), 
          onChanged: (val) => setState(() => periodoSelecionado = val!),
        ),
      ),
    );
  }

  Widget _buildCardFinanceiro(String titulo, String valor, Color cor, IconData icone, bool isEscuro) {
    return Container(
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08), 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: cor.withValues(alpha: 0.2)),
      ), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icone, color: cor, size: 20)
          ), 
          const SizedBox(height: 20), 
          Text(
            titulo, 
            style: TextStyle(color: isEscuro ? Colors.white.withValues(alpha: 0.54) : Colors.black.withValues(alpha: 0.54), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ), 
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor, 
              style: TextStyle(color: cor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloSecao(String titulo, Color cor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4), 
      child: Text(
        titulo, 
        style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildItemRanking(String nome, String quantidade, Color cor, IconData icone, bool isEscuro, Color baseTextColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEscuro ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), 
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: cor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icone, color: cor, size: 20),
        ), 
        title: Text(
          nome, 
          style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ), 
        trailing: Text(
          quantidade, 
          style: TextStyle(color: cor, fontWeight: FontWeight.w800, fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildPlaceholderGrafico(bool isEscuro, Color cardColor) {
    return Container(
      height: 180, 
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: isEscuro ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ), 
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_rounded, color: isEscuro ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.12), size: 48),
            const SizedBox(height: 12),
            Text(
              "Real-Time Analytical Chart", 
              style: TextStyle(color: isEscuro ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.38), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}