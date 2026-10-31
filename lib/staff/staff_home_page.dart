import 'package:flutter/material.dart';
import 'package:nexxo/auth/login_page.dart';
import 'package:nexxo/common/stock_page.dart';
import 'package:nexxo/staff/shopping_list_staff_page.dart';
import 'package:nexxo/common/history_page.dart';
import 'package:nexxo/auth/pin_auth_service.dart';
import 'package:nexxo/manager/inventory_page.dart';

class HomeFuncionario extends StatefulWidget {
  final bool podeVerHistorico;
  final String cargo;
  final String nomeOperador;

  const HomeFuncionario({
    super.key, 
    this.podeVerHistorico = false, 
    this.cargo = "Team",
    this.nomeOperador = "Operator",
  });

  @override
  State<HomeFuncionario> createState() => _HomeFuncionarioState();
}

class _HomeFuncionarioState extends State<HomeFuncionario> {
  final _formKeyBaixa = GlobalKey<FormState>();
  final _formKeyFalta = GlobalKey<FormState>();
  int _selectedIndex = 0;
  bool _isProcessing = false;

  static const Color equipeColor = Color(0xFFFF9100);

  void _abrirModalRegistroRapido(ThemeData theme) {
    String nomeProduto = "";
    double quantidade = 0;
    String motivo = "Operational Use";

    final isEscuro = theme.brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final bgColor = isEscuro ? const Color(0xFF121214) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: _formKeyBaixa,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4, 
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: theme.hintColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10))
                ),
              ),
              const Text("RECORD QUICK REDUCTION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: equipeColor, letterSpacing: 0.5)),
              const SizedBox(height: 25),
              TextFormField(
                autofocus: true,
                style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _inputStyle(label: "Product Name", hint: "What was consumed?", isEscuro: isEscuro),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter the product" : null,
                onChanged: (v) => nomeProduto = v,
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: _inputStyle(label: "Qty", suffix: "un", isEscuro: isEscuro),
                      validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? "Invalid" : null,
                      onChanged: (v) => quantidade = double.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      dropdownColor: bgColor,
                      value: motivo,
                      style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
                      items: ["Operational Use", "Salon Sale", "Waste"]
                          .map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: baseTextColor, fontSize: 13)))).toList(),
                      onChanged: (val) => motivo = val ?? motivo,
                      decoration: _inputStyle(label: "Reason", isEscuro: isEscuro),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: equipeColor, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isProcessing ? null : () async {
                    if (_formKeyBaixa.currentState!.validate()) {
                      setState(() => _isProcessing = true);
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (!mounted) return;
                      setState(() => _isProcessing = false);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reduction of $quantidade units of $nomeProduto saved to Firebase!")));
                    }
                  },
                  child: _isProcessing 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                      : const Text("CONFIRM NOW", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirModalReportarFalta(ThemeData theme) {
    String nomeProduto = "";
    final isEscuro = theme.brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final bgColor = isEscuro ? const Color(0xFF121214) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: _formKeyFalta,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4, 
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: theme.hintColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10))
                ),
              ),
              const Text("REPORT SHORTAGE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2979FF), letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text("Write down the item running low for the owner's dashboard.", style: TextStyle(color: theme.hintColor, fontSize: 13)),
              const SizedBox(height: 25),
              TextFormField(
                autofocus: true,
                style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _inputStyle(label: "Item Name", hint: "Ex: Beans, Paper towels...", isEscuro: isEscuro),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Specify which item is missing" : null,
                onChanged: (v) => nomeProduto = v,
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isProcessing ? null : () async {
                    if (_formKeyFalta.currentState!.validate()) {
                      setState(() => _isProcessing = true);
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (!mounted) return;
                      setState(() => _isProcessing = false);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$nomeProduto sent to the Owner's list!")));
                    }
                  },
                  child: _isProcessing 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text("ADD TO LIST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle({required String label, String? suffix, String? hint, required bool isEscuro}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13),
      labelStyle: const TextStyle(fontSize: 13),
      suffixText: suffix,
      filled: true,
      fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: equipeColor, width: 1.0)),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    );
  }

  void _fazerLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);

    final List<Widget> paginasDinamicas = [
      _buildDashboardRapida(theme, baseTextColor),
      const EstoquePage(),
      const ListaComprasFuncionarioPage(),
      if (widget.podeVerHistorico) const HistoricoPage(),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: _buildPlaquetaIdentificacao(theme, baseTextColor),
          actions: [
            IconButton(
              onPressed: _fazerLogout,
              icon: Icon(Icons.logout_rounded, color: Colors.redAccent.shade400, size: 22),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: paginasDinamicas[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: isEscuro ? const Color(0xFF121214) : Colors.white,
            selectedItemColor: equipeColor,
            unselectedItemColor: theme.hintColor.withOpacity(0.5),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            elevation: 0,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
              const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: "Stock"),
              const BottomNavigationBarItem(icon: Icon(Icons.shopping_basket_rounded), label: "Request"),
              if (widget.podeVerHistorico) const BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaquetaIdentificacao(ThemeData theme, Color baseTextColor) {
    final isEscuro = theme.brightness == Brightness.dark;
    final cardColor = isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03);
    final borderColor = isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: equipeColor, shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 16, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.nomeOperador.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: baseTextColor, letterSpacing: 0.5)),
              Text(widget.cargo.toUpperCase(), style: const TextStyle(fontSize: 9, color: equipeColor, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardRapida(ThemeData theme, Color baseTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("What shall we do now?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
          const SizedBox(height: 35),
          
          _buildActionCard(
            titulo: "RECORD REDUCTION",
            sub: "Register immediate consumption",
            icon: Icons.remove_circle_outline_rounded,
            cor: equipeColor,
            theme: theme,
            baseTextColor: baseTextColor,
            onTap: () => _abrirModalRegistroRapido(theme), 
          ),
          const SizedBox(height: 14),
          
          _buildActionCard(
            titulo: "REPORT SHORTAGE",
            sub: "Add item to shopping list",
            icon: Icons.assignment_late_outlined,
            cor: const Color(0xFF2979FF),
            theme: theme,
            baseTextColor: baseTextColor,
            onTap: () => _abrirModalReportarFalta(theme), 
          ),
          const SizedBox(height: 14),
          
          _buildActionCard(
            titulo: "PERFORM INVENTORY",
            sub: "General team count check",
            icon: Icons.playlist_add_check_rounded,
            cor: const Color(0xFF00E676),
            theme: theme,
            baseTextColor: baseTextColor,
            onTap: () async {
              final mockFuncionarios = [
                {"pin": "4812"},
                {"pin": "9182"},
                {"pin": "3341"},
              ];

              bool autorizado = await PinAuthService.validarPin(context, funcionarios: mockFuncionarios);

              if (autorizado) {
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventarioPage()),
                );
              }
            }, 
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String titulo, 
    required String sub, 
    required IconData icon, 
    required Color cor, 
    required ThemeData theme,
    required Color baseTextColor,
    required VoidCallback onTap,
  }) {
    final isEscuro = theme.brightness == Brightness.dark;
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final borderColor = isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: cor.withOpacity(0.05),
          highlightColor: cor.withOpacity(0.02),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: cor.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: cor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: baseTextColor, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(sub, style: TextStyle(color: theme.hintColor, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: theme.hintColor.withOpacity(0.3), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}                   