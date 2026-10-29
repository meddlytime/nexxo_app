import 'package:flutter/material.dart';

class PainelFinanceiroGerente extends StatefulWidget {
  const PainelFinanceiroGerente({super.key});

  @override
  State<PainelFinanceiroGerente> createState() => _PainelFinanceiroGerenteState();
}

class _PainelFinanceiroGerenteState extends State<PainelFinanceiroGerente> {
  static const Color accentColor = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Scaffold(
      backgroundColor: isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text("COSTS AND INVENTORY DASHBOARD", 
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: baseTextColor, size: 22),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("IMMOBILIZED VALUE", style: TextStyle(color: hintColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text("R\$ 14.250,80", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: -1.0)),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(child: _buildCustoCard("MONTH PURCHASES", "R\$ 2.400", const Color(0xFF2979FF), cardColor, isEscuro)),
                const SizedBox(width: 16),
                Expanded(child: _buildCustoCard("WASTE", "R\$ 450", Colors.redAccent.shade400, cardColor, isEscuro)),
              ],
            ),
            const SizedBox(height: 32),
            
            Text("COST DISTRIBUTION", style: TextStyle(color: hintColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 24),
            
            _buildItemCusto("File Mignon", "R\$ 4.200,00", 0.8, baseTextColor, isEscuro),
            _buildItemCusto("Pink Shrimp", "R\$ 2.100,00", 0.5, baseTextColor, isEscuro),
            _buildItemCusto("Brie Cheese", "R\$ 1.050,00", 0.3, baseTextColor, isEscuro),
            
            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: accentColor, size: 20),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Complete governance: Full access to operational costs and advanced reports unlocked.",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustoCard(String label, String valor, Color cor, Color cardColor, bool isEscuro) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: cor)),
        ],
      ),
    );
  }

  Widget _buildItemCusto(String nome, String valor, double progresso, Color baseTextColor, bool isEscuro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nome.toUpperCase(), style: TextStyle(color: baseTextColor, fontSize: 13, fontWeight: FontWeight.w900)),
              Text(valor, style: TextStyle(fontWeight: FontWeight.w900, color: baseTextColor, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progresso,
              backgroundColor: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              color: const Color(0xFF2979FF),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}