import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app_estoque/auth/plano_service.dart';
import 'package:app_estoque/comum/modal_upgrade_page.dart';

class RelatoriosPage extends StatefulWidget {
  final String unidadeInicial;
  const RelatoriosPage({super.key, required this.unidadeInicial});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  late String unidadeFiltro;
  String periodoSelecionado = "Este Mês";

  static const Color accentColor = Color(0xFF00E676); // Verde Nexo

  @override
  void initState() {
    super.initState();
    unidadeFiltro = widget.unidadeInicial;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    // Paleta Nexo Obsidian
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;

    // Captura as regras do cérebro global de planos
    final regras = planoService.regras;
    final bool eBasico = !regras.possuiRelatoriosAvancados;
    final bool ePremium = regras.possuiTopSaidasConsolidado;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("INTELIGÊNCIA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // SELETOR DE UNIDADE: Só permite trocar se possuir Multi-Loja (Premium)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: unidadeFiltro,
                dropdownColor: cardColor,
                disabledHint: Text(unidadeFiltro, style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.54), fontSize: 12, fontWeight: FontWeight.w800)),
                icon: Icon(Icons.storefront_rounded, color: regras.possuiMultiLoja ? accentColor : (isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)), size: 16),
                style: const TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                items: regras.possuiMultiLoja 
                    ? ["Unidade Centro", "Unidade Shopping", "Vila Gourmet (Geral)"].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList()
                    : null,
                onChanged: (val) => setState(() => unidadeFiltro = val!),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Dados de: $unidadeFiltro", style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.54), fontSize: 13, fontWeight: FontWeight.w600)),
              _buildSeletorPeriodo(isEscuro, cardColor),
            ],
          ),
          const SizedBox(height: 30),
          
          // --- BLOCO 1: PAINEL FINANCEIRO ---
          _travarSeForBasico(
            eBasico: eBasico,
            funcionalidade: "Painel Financeiro",
            isEscuro: isEscuro,
            child: Row(
              children: [
                Expanded(child: _buildCardFinanceiro("CAPITAL TOTAL", "R\$ 12.450", const Color(0xFF2979FF), Icons.account_balance_wallet_rounded, isEscuro)),
                const SizedBox(width: 15),
                Expanded(child: _buildCardFinanceiro("PREJUÍZO (PERDA)", "R\$ 840", Colors.redAccent.shade400, Icons.trending_down_rounded, isEscuro)),
              ],
            ),
          ),
          
          const SizedBox(height: 35),
          
          // --- BLOCO 2: GRÁFICOS ANALÍTICOS ---
          _travarSeForBasico(
            eBasico: eBasico,
            funcionalidade: "Gráficos de Categoria",
            isEscuro: isEscuro,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTituloSecao("INVESTIMENTO POR CATEGORIA", accentColor),
                _buildPlaceholderGrafico(isEscuro, cardColor),
              ],
            ),
          ),
          
          const SizedBox(height: 35),
          
          // --- BLOCO 3: TOP DESPERDÍCIO (ISCA OPERACIONAL LIBERADA) ---
          _buildTituloSecao("TOP ITENS EM DESPERDÍCIO (7 DIAS)", Colors.redAccent.shade400),
          _buildItemRanking("Tomate Italiano", "12kg estragados", Colors.redAccent.shade400, Icons.restore_from_trash_rounded, isEscuro, baseTextColor, cardColor),
          _buildItemRanking("Picanha Argentina", "2.5kg perdas", const Color(0xFFFF9100), Icons.restore_from_trash_rounded, isEscuro, baseTextColor, cardColor),
          _buildItemRanking("Alface Crespa", "4 un descartadas", Colors.amber.shade500, Icons.restore_from_trash_rounded, isEscuro, baseTextColor, cardColor),
          
          const SizedBox(height: 35),
          
          // --- BLOCO 4: CAMPEÕES DE SAÍDA (EXCLUSIVO PREMIUM) ---
          _travarSeForBasico(
            eBasico: !ePremium, 
            funcionalidade: "Ranking de Mais Vendidos",
            isEscuro: isEscuro,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTituloSecao("RANKING: CAMPEÕES DE SAÍDA", const Color(0xFF2979FF)),
                _buildItemRanking("Hambúrguer Blend 180g", "412 un vendidas", Colors.amber, Icons.stars_rounded, isEscuro, baseTextColor, cardColor),
                _buildItemRanking("Batata Frita Palito", "280 porções", Colors.amber.shade600, Icons.stars_rounded, isEscuro, baseTextColor, cardColor),
                _buildItemRanking("Refrigerante Lata 350ml", "195 un", Colors.amber.shade400, Icons.stars_rounded, isEscuro, baseTextColor, cardColor),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- COMPONENTE DE PAYWALL EMBUTIDO ---
  Widget _travarSeForBasico({required bool eBasico, required String funcionalidade, required bool isEscuro, required Widget child}) {
    if (!eBasico) return child;

    const Color premiumColor = Color(0xFFB388FF); // Roxo Premium para o Upgrade

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.15,
          child: AbsorbPointer(child: child),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: premiumColor.withOpacity(0.15),
            foregroundColor: premiumColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: premiumColor.withOpacity(0.5), width: 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          icon: const Icon(Icons.lock_outline_rounded, size: 16),
          label: Text("Liberar $funcionalidade", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ConfiguracaoPrevisaoPage()));
          },
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSeletorPeriodo(bool isEscuro, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: periodoSelecionado, 
          dropdownColor: cardColor, 
          icon: const Icon(Icons.calendar_today_rounded, size: 14, color: accentColor),
          style: const TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 12), 
          items: ["Hoje", "Esta Semana", "Este Mês"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), 
          onChanged: (val) => setState(() => periodoSelecionado = val!),
        ),
      ),
    );
  }

  Widget _buildCardFinanceiro(String titulo, String valor, Color cor, IconData icone, bool isEscuro) {
    return Container(
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08), 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: cor.withOpacity(0.2)),
      ), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icone, color: cor, size: 20)
          ), 
          const SizedBox(height: 20), 
          Text(titulo, style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.54) : Colors.black.withOpacity(0.54), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)), 
          const SizedBox(height: 4),
          Text(valor, style: TextStyle(color: cor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
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
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), 
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: cor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icone, color: cor, size: 20),
        ), 
        title: Text(nome, style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700)), 
        trailing: Text(quantidade, style: TextStyle(color: cor, fontWeight: FontWeight.w800, fontSize: 13)),
      ),
    );
  }

  Widget _buildPlaceholderGrafico(bool isEscuro, Color cardColor) {
    return Container(
      height: 180, 
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ), 
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_rounded, color: isEscuro ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.12), size: 48),
            const SizedBox(height: 12),
            Text(
              "Gráfico Analítico em Tempo Real", 
              style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.38), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}