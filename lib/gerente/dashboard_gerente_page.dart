import 'package:flutter/material.dart';
import 'package:app_estoque/auth/plano_service.dart';
import 'package:app_estoque/comum/estoque_page.dart';
import 'package:app_estoque/gerente/gerente_aprovacao_page.dart';
import 'package:app_estoque/gerente/perfil_gerente_page.dart';
import 'package:app_estoque/gerente/painel_financeiro_gerente.dart';
import 'package:app_estoque/patrao/relatorios_page.dart';
import 'package:app_estoque/comum/modal_upgrade_page.dart';
import 'package:app_estoque/gerente/lista_compras_gerente.dart'; 
import 'relatorio_desperdicio.dart';

class HomeGerente extends StatefulWidget {
  const HomeGerente({super.key});

  @override
  State<HomeGerente> createState() => _HomeGerenteState();
}

class _HomeGerenteState extends State<HomeGerente> {
  int _selectedIndex = 0;
  bool _filtrarCriticosNoEstoque = false;
  final String unidadLocal = "Unidade Centro";
  static const Color accentColor = Color(0xFF2979FF); // Azul Cobalto do Gerente

  @override
  void initState() {
    super.initState();
    planoService.addListener(_escutarMudancaDePlano);
  }

  @override
  void dispose() {
    planoService.removeListener(_escutarMudancaDePlano);
    super.dispose();
  }

  void _escutarMudancaDePlano() {
    if (mounted) setState(() {});
  }

  int get _nivelFinanceiro => planoService.regras.possuiRelatoriosAvancados ? 2 : 1;

  void _navegarParaEstoqueCritico() {
    setState(() {
      _selectedIndex = 1; 
      _filtrarCriticosNoEstoque = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;

    final List<Widget> paginas = [
      ResumoOperacionalGerente(
        nivelFinanceiro: _nivelFinanceiro,
        onTapCritico: _navegarParaEstoqueCritico,
        unidadeAlocada: unidadLocal,
      ),
      EstoquePage(filtrarCriticos: _filtrarCriticosNoEstoque),
      const GerenteAprovacaoPage(),
      const PainelFinanceiroGerente(), 
      const PerfilGerentePage(),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: paginas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              if (index != 1) _filtrarCriticosNoEstoque = false;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardColor,
          selectedItemColor: accentColor,
          unselectedItemColor: isEscuro ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.speed_rounded)), label: "PAINEL"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.inventory_2_rounded)), label: "ESTOQUE"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.fact_check_rounded)), label: "APROVAR"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.payments_rounded)), label: "CAIXA"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded)), label: "PERFIL"),
          ],
        ),
      ),
    );
  }
}

class ResumoOperacionalGerente extends StatelessWidget {
  final int nivelFinanceiro;
  final VoidCallback onTapCritico;
  final String unidadeAlocada;

  const ResumoOperacionalGerente({
    super.key, 
    required this.nivelFinanceiro,
    required this.onTapCritico,
    required this.unidadeAlocada,
  });

  static const Color accentColor = Color(0xFF2979FF);

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    final List<Map<String, dynamic>> viloesEstoque = [
      {"nome": "Picanha Argentina", "quebras": "14 un", "motivo": "Furto/Avaria", "tendencia": "Alta"},
      {"nome": "Tomate Italiano", "quebras": "8.5 kg", "motivo": "Produto Vencido", "tendencia": "Estável"},
      {"nome": "Cerveja IPA", "quebras": "6 un", "motivo": "Desperdício Salão", "tendencia": "Baixa"},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(baseTextColor, hintColor, isEscuro),
            const SizedBox(height: 40),
            
            if (nivelFinanceiro > 0) ...[
              _buildSecaoTitulo("INFORMAÇÕES FINANCEIRAS"),
              _buildKpiCardFinanceiro("VALOR TOTAL EM ESTOQUE", "R\$ 14.250,80", Icons.account_balance_wallet_rounded, accentColor, baseTextColor, isEscuro),
              if (nivelFinanceiro == 2) ...[
                const SizedBox(height: 12),
                _buildKpiCardFinanceiro("CUSTO DE PEDIDOS (MÊS)", "R\$ 3.120,00", Icons.trending_up_rounded, const Color(0xFFFF9100), baseTextColor, isEscuro),
              ],
              const SizedBox(height: 32),
            ],

            _buildSecaoTitulo("STATUS OPERACIONAL"),
            Row(
              children: [
                Expanded(child: _buildMiniCard("PEDIDOS PENDENTES", "08", Icons.pending_actions_rounded, const Color(0xFFFF9100), baseTextColor, hintColor, cardColor, isEscuro)),
                const SizedBox(width: 16),
                Expanded(child: _buildMiniCard("BAIXAS HOJE", "142", Icons.trending_down_rounded, Colors.redAccent.shade400, baseTextColor, hintColor, cardColor, isEscuro)),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildKpiCardGerenteCompacto(
              "ESTOQUE CRÍTICO", 
              "12 itens precisam de atenção", 
              Icons.warning_amber_rounded, 
              Colors.redAccent.shade400,
              baseTextColor, hintColor, onTap: onTapCritico,
            ),
            
            const SizedBox(height: 32),

            _buildSecaoTitulo("VILÕES DO DESPERDÍCIO (MÊS)"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viloesEstoque.length,
                itemBuilder: (context, idx) {
                  final item = viloesEstoque[idx];
                  return Padding(
                    padding: EdgeInsets.only(bottom: idx != viloesEstoque.length - 1 ? 16.0 : 0.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.redAccent.shade400.withOpacity(0.1),
                          child: Text("${idx + 1}", style: TextStyle(color: Colors.redAccent.shade400, fontSize: 12, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["nome"], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: baseTextColor)),
                              const SizedBox(height: 2),
                              Text("Motivo comum: ${item["motivo"]}", style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("-${item["quebras"]}", style: TextStyle(fontSize: 14, color: Colors.redAccent.shade400, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text(
                              item["tendencia"] == "Alta" ? "▲ Crítico" : item["tendencia"] == "Estável" ? "● Estável" : "▼ Reduzindo",
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.w900,
                                color: item["tendencia"] == "Alta" ? Colors.redAccent.shade400 : item["tendencia"] == "Estável" ? const Color(0xFFFF9100) : accentColor
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            _buildSecaoTitulo("GESTÃO E CONTROLE"),
            _buildBotaoAcaoGerente("GERENCIAR FUNCIONÁRIOS", Icons.group_add_rounded, baseTextColor, hintColor, cardColor, isEscuro, 
                onTap: () => _abrirGestaoEquipe(context, baseTextColor, hintColor, cardColor, isEscuro)),
            
            _buildBotaoAcaoGerente("LISTA DE COMPRAS CORPORATIVA", Icons.shopping_bag_rounded, baseTextColor, hintColor, cardColor, isEscuro, 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ListaComprasGerentePage()))),
            
            // BOTÃO ATUALIZADO: RELATÓRIO DE DESPERDÍCIO
            _buildBotaoAcaoGerente("RELATÓRIO DE DESPERDÍCIO", Icons.delete_outline_rounded, baseTextColor, hintColor, cardColor, isEscuro, 
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RelatorioDesperdicioGerentePage()));

                }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE SUPORTE ---

  Widget _buildHeader(Color textColor, Color hintColor, bool isEscuro) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(unidadeAlocada.toUpperCase(), style: const TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text("Painel Gerencial", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.person_rounded, color: accentColor, size: 24),
        ),
      ],
    );
  }

  Widget _buildSecaoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(titulo, style: const TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildKpiCardFinanceiro(String label, String valor, IconData icon, Color cor, Color baseTextColor, bool isEscuro) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: cor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: cor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildKpiCardGerenteCompacto(String label, String valor, IconData icon, Color cor, Color baseTextColor, Color hintColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: cor, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: cor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(valor, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: baseTextColor)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 20, color: hintColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(String label, String valor, IconData icon, Color cor, Color baseTextColor, Color hintColor, Color cardColor, bool isEscuro) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: cor, size: 20),
          ),
          const SizedBox(height: 20),
          Text(valor, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: hintColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildBotaoAcaoGerente(String label, IconData icon, Color baseTextColor, Color hintColor, Color cardColor, bool isEscuro, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cardColor,
          foregroundColor: baseTextColor,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
          ),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.2))),
            Icon(Icons.chevron_right_rounded, size: 20, color: hintColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _abrirGestaoEquipe(BuildContext context, Color baseTextColor, Color hintColor, Color cardColor, bool isEscuro) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isEscuro ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("EQUIPE DA UNIDADE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: baseTextColor, letterSpacing: 1.5)),
              const SizedBox(height: 24),
              _buildItemFuncionario("Carlos Oliveira", "Cozinha", baseTextColor, hintColor, cardColor, context),
              _buildItemFuncionario("Ana Souza", "Bar", baseTextColor, hintColor, cardColor, context),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.add_rounded, size: 20, color: Colors.black),
                  label: const Text("ADICIONAR COLABORADOR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemFuncionario(String nome, String setor, Color baseTextColor, Color hintColor, Color cardColor, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: accentColor.withOpacity(0.1), 
          child: Text(nome[0], style: const TextStyle(color: accentColor, fontWeight: FontWeight.w900))
        ),
        title: Text(nome, style: TextStyle(fontSize: 14, color: baseTextColor, fontWeight: FontWeight.w800)),
        subtitle: Text(setor, style: TextStyle(fontSize: 12, color: hintColor, fontWeight: FontWeight.w600)),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.shade400, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}