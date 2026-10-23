import 'package:flutter/material.dart';
import 'package:app_estoque/auth/login_page.dart';
import 'package:app_estoque/patrao/perfil_chefe_page.dart'; 
import 'package:app_estoque/comum/estoque_page.dart'; 
import 'package:app_estoque/comum/historico_page.dart';
import 'package:app_estoque/patrao/ajustes_page.dart';
import 'package:app_estoque/patrao/relatorios_page.dart';
import 'package:app_estoque/comum/lista_compras_patrao.dart';
import 'package:app_estoque/auth/plano_service.dart';
import 'package:app_estoque/comum/scanner_page.dart';

class DashboardPatrao extends StatefulWidget {
  const DashboardPatrao({super.key});

  @override
  State<DashboardPatrao> createState() => _DashboardPatraoState();
}

class _DashboardPatraoState extends State<DashboardPatrao> {
  int _selectedIndex = 0;
  String unidadeSelecionada = "Unidade Centro";
  final List<String> unidades = ["Unidade Centro", "Unidade Shopping", "Vila Gourmet (Geral)"];

  bool _isLoadingEmpresa = false; 
  
  final int _itensTotais = 42;
  final int _itensReporUrgente = 8; // Mudei para 8 para você ver o Vermelho em ação! (Teste mudar para 2 ou 0)
  final double _faturamentoMensal = 128450.00;
  final double _custoEstoque = 45200.00;
  final double _desperdicio = 1200.00;
  final String _margemBruta = "62%";

  static const Color accentColor = Color(0xFF00E676); // Verde Nexo

  @override
  void initState() {
    super.initState();
    _buscarDadosIniciaisFirebase();
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

  Future<void> _buscarDadosIniciaisFirebase() async {
    setState(() => _isLoadingEmpresa = true);
    await Future.delayed(const Duration(milliseconds: 600)); 
    if (mounted) setState(() => _isLoadingEmpresa = false);
  }

  void _abrirModalAdmin(String tipo, bool isEscuro) {
    String nomeProduto = "";
    double quantidade = 0;
    Color corPrincipal = tipo == "ENTRADA" ? accentColor : const Color(0xFFFF9100);
    
    final bgColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tipo == "ENTRADA" ? Icons.add_box_rounded : Icons.indeterminate_check_box_rounded, color: corPrincipal),
                const SizedBox(width: 10),
                Text(tipo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: corPrincipal, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 25),
            _buildInputSimple(label: "Produto", hint: "Digite o nome do item...", isEscuro: isEscuro, focus: true, onChanged: (v) => nomeProduto = v),
            const SizedBox(height: 15),
            _buildInputSimple(label: "Quantidade", hint: "0", suffix: "un/kg", isNumber: true, isEscuro: isEscuro, focus: false, onChanged: (v) => quantidade = double.tryParse(v) ?? 0),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: corPrincipal, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (nomeProduto.trim().isNotEmpty && quantidade > 0) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$tipo em $unidadeSelecionada: $quantidade de $nomeProduto salvo no Firebase.")));
                  }
                },
                child: Text("CONFIRMAR AJUSTE", style: TextStyle(color: (tipo == "ENTRADA" && isEscuro) ? Colors.black : Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirCentralNotificacoes(bool isEscuro) {
    final bgColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final cardColor = isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03);
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ALERTAS E SOLICITAÇÕES", style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9100).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFFF9100).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.lock_reset_rounded, color: Color(0xFFFF9100), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ronaldo (Cozinha)", style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text("Solicita redefinição de PIN de turno.", style: TextStyle(color: isEscuro ? Colors.white54 : Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _mostrarDialogNovoPin("Ronaldo", isEscuro, baseTextColor);
                      },
                      child: const Text("GERAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogNovoPin(String funcionario, bool isEscuro, Color baseTextColor) {
    String novoPin = "";
    final bgColor = isEscuro ? const Color(0xFF121214) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Novo PIN para $funcionario", style: TextStyle(color: baseTextColor, fontSize: 16, fontWeight: FontWeight.w800)),
        content: TextField(
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Ex: 4321",
            filled: true,
            fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          onChanged: (v) => novoPin = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar", style: TextStyle(color: isEscuro ? Colors.white54 : Colors.black54))),
          TextButton(
            onPressed: () {
              if (novoPin.trim().length == 4) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN atualizado com sucesso!")));
              }
            },
            child: const Text("Enviar PIN", style: TextStyle(color: accentColor, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _abrirScannerSimulado() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerPage()));
  }

  Widget _buildInputSimple({required String label, required String hint, String? suffix, bool isNumber = false, required bool isEscuro, required bool focus, required Function(String) onChanged}) {
    return TextFormField(
      autofocus: focus,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        filled: true,
        fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accentColor, width: 1.0)),
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

    final List<Widget> paginas = [
      _buildInicio(isEscuro, baseTextColor, cardColor),
      const EstoquePage(), 
      const HistoricoPage(),
      const AjustesPage(),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: planoService.regras.possuiMultiLoja
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: unidadeSelecionada,
                      dropdownColor: cardColor,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: accentColor, size: 20),
                      style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                      items: unidades.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                      onChanged: (novo) => setState(() => unidadeSelecionada = novo!),
                    ),
                  ),
                )
              : Text("Unidade Principal", style: TextStyle(color: baseTextColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
          actions: [
            IconButton(onPressed: () => _abrirCentralNotificacoes(isEscuro), icon: Icon(Icons.notifications_none_rounded, color: isEscuro ? Colors.white70 : Colors.black87)),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilChefePage())), icon: const Icon(Icons.person_outline_rounded, color: accentColor)),
            IconButton(
              onPressed: () {
                planoService.resetarPlanoAoDeslogar();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
              }, 
              icon: Icon(Icons.logout_rounded, color: Colors.redAccent.shade400, size: 22)
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: paginas),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
          ),
          child: BottomNavigationBar(
            backgroundColor: cardColor,
            selectedItemColor: accentColor,
            unselectedItemColor: isEscuro ? Colors.white30 : Colors.black38,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Visão Geral"),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: "Estoque"),
              BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "Histórico"),
              BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Ajustes"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInicio(bool isEscuro, Color baseTextColor, Color cardColor) {
    // 🚥 LÓGICA DE SINALIZAÇÃO SEMÂNTICA (SEMÁFORO)
    Color corUrgencia;
    IconData iconeUrgencia;
    
    if (_itensReporUrgente == 0) {
      corUrgencia = accentColor; // Verde
      iconeUrgencia = Icons.check_circle_outline_rounded;
    } else if (_itensReporUrgente <= 4) {
      corUrgencia = const Color(0xFFFF9100); // Laranja (Atenção)
      iconeUrgencia = Icons.warning_amber_rounded;
    } else {
      corUrgencia = Colors.redAccent.shade400; // Vermelho (Crítico)
      iconeUrgencia = Icons.error_outline_rounded;
    }

    return _isLoadingEmpresa
        ? const Center(child: CircularProgressIndicator(color: accentColor))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PLANO ATIVO: ${planoService.regras.tagPlano}", 
                  style: TextStyle(color: planoService.regras.corPlano, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                ),
                const SizedBox(height: 4),
                Text("Visão Estratégica", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
                const SizedBox(height: 25),
                _buildPainelFinanceiroExecutivo(isEscuro, baseTextColor, cardColor),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildSummaryCard("Itens Totais", "$_itensTotais", Icons.inventory_2_rounded, const Color(0xFF2979FF), cardColor, isEscuro, baseTextColor, () {}),
                    const SizedBox(width: 15),
                    
                    // APLICANDO A COR E ÍCONE DINÂMICOS AQUI
                    _buildSummaryCard(
                      "Repor Urgente", 
                      _itensReporUrgente < 10 ? "0$_itensReporUrgente" : "$_itensReporUrgente", 
                      iconeUrgencia, 
                      corUrgencia, 
                      cardColor, 
                      isEscuro, 
                      baseTextColor, 
                      () => setState(() => _selectedIndex = 1)
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text("Ações Rápidas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: baseTextColor)),
                const SizedBox(height: 20),
                _buildAcoesRapidasPorPlano(isEscuro, baseTextColor, cardColor),
                const SizedBox(height: 30),
              ],
            ),
          );
  }

  Widget _buildAcoesRapidasPorPlano(bool isEscuro, Color baseTextColor, Color cardColor) {
    if (planoService.regras.possuiMultiLoja) {
      return Row(
        children: [
          Expanded(child: _buildQuickAction("Relatórios", Icons.bar_chart_rounded, const Color(0xFFB388FF), cardColor, isEscuro, baseTextColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelatoriosPage(unidadeInicial: unidadeSelecionada))))),
          const SizedBox(width: 15),
          Expanded(child: _buildQuickAction("L. Compras", Icons.shopping_cart_checkout_rounded, Colors.amber, cardColor, isEscuro, baseTextColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaComprasPatraoPage())))),
          const SizedBox(width: 15),
          Expanded(child: _buildQuickAction("Virar Básico", Icons.keyboard_arrow_down_rounded, Colors.grey, cardColor, isEscuro, baseTextColor, () => planoService.atualizarPlanoDoUsuario('basico'))),
        ],
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          children: [
            _buildQuickAction("Entrada", Icons.add_box_rounded, accentColor, cardColor, isEscuro, baseTextColor, () => _abrirModalAdmin("ENTRADA", isEscuro)),
            const SizedBox(width: 16),
            _buildQuickAction("Dar Baixa", Icons.indeterminate_check_box_rounded, const Color(0xFFFF9100), cardColor, isEscuro, baseTextColor, () => _abrirModalAdmin("BAIXA", isEscuro)),
            const SizedBox(width: 16),
            _buildQuickAction("Relatórios", Icons.bar_chart_rounded, const Color(0xFFB388FF), cardColor, isEscuro, baseTextColor, () {
              if (planoService.regras.possuiRelatorioReduzido) Navigator.push(context, MaterialPageRoute(builder: (_) => RelatoriosPage(unidadeInicial: unidadeSelecionada)));
            }),
            const SizedBox(width: 16),
            _buildQuickAction("L. Compras", Icons.shopping_cart_checkout_rounded, Colors.amber, cardColor, isEscuro, baseTextColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaComprasPatraoPage()))),
            const SizedBox(width: 16),
            _buildQuickAction("Scanner", Icons.qr_code_scanner_rounded, const Color(0xFF2979FF), cardColor, isEscuro, baseTextColor, _abrirScannerSimulado),
            const SizedBox(width: 16),
            _buildQuickAction("Virar Premium", Icons.stars_rounded, Colors.amber, cardColor, isEscuro, baseTextColor, () => planoService.atualizarPlanoDoUsuario('premium')),
          ],
        ),
      );
    }
  }

  Widget _buildPainelFinanceiroExecutivo(bool isEscuro, Color baseTextColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text("DESEMPENHO: ${unidadeSelecionada.toUpperCase()}", style: const TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
              const Icon(Icons.analytics_outlined, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text("R\$ ${_faturamentoMensal.toStringAsFixed(2).replaceAll('.', ',')}", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -1.0)),
          const SizedBox(height: 4),
          Text("Faturamento Bruto Mensal", style: TextStyle(color: isEscuro ? Colors.white54 : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          Divider(color: isEscuro ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1), height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricaItem("Custo Estoque", "R\$ 45.2k", const Color(0xFFFF9100), isEscuro),
              _buildMetricaItem("Desperdício", "R\$ 1.2k", Colors.redAccent.shade400, isEscuro),
              _buildMetricaItem("Margem Bruta", _margemBruta, const Color(0xFF2979FF), isEscuro),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricaItem(String label, String valor, Color cor, bool isEscuro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(valor, style: TextStyle(color: cor, fontSize: 16, fontWeight: FontWeight.w900)), 
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isEscuro ? Colors.white54 : Colors.black54, fontSize: 11, fontWeight: FontWeight.w600))
      ]
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, Color cardColor, bool isEscuro, Color baseTextColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor, 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16), 
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: baseTextColor, height: 1.0)), 
              const SizedBox(height: 6),
              Text(title, style: TextStyle(fontSize: 12, color: isEscuro ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w600))
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, Color cardColor, bool isEscuro, Color baseTextColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            height: 64, width: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(18), 
              border: Border.all(color: color.withOpacity(0.2))
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: isEscuro ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}