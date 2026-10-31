import 'package:flutter/material.dart';
import 'package:nexxo/auth/login_page.dart';

class PerfilGerentePage extends StatefulWidget {
  final String nomeGerenteInicial;
  final String emailGerenteInicial;
  final String nomeLoja;

  const PerfilGerentePage({
    super.key,
    this.nomeGerenteInicial = "Manager Carlos",
    this.emailGerenteInicial = "carlos.manager@mystore.com",
    this.nomeLoja = "My store",
  });

  @override
  State<PerfilGerentePage> createState() => _PerfilGerentePageState();
}

class _PerfilGerentePageState extends State<PerfilGerentePage> {
  static const Color accentColor = Color(0xFF00E676);

  late String _nomeGerente;
  late String _emailGerente;
  String _telefoneGerente = "(11) 99999-8888";
  late String _nomeLoja;

  bool _notificarMovimentacao = true;
  bool _notificarNovaEquipe = false;
  bool _notificarEstoqueCritico = true;

  final List<Map<String, String>> _funcionarios = [
    {"nome": "Ronaldo Kitchen", "cargo": "Shift Chef", "pin": "4812"},
    {"nome": "Amanda Silva", "cargo": "Cashier", "pin": "9182"},
    {"nome": "Marcos Souza", "cargo": "Inventory Assistant", "pin": "3341"},
  ];

  @override
  void initState() {
    super.initState();
    _nomeGerente = widget.nomeGerenteInicial;
    _emailGerente = widget.emailGerenteInicial;
    _nomeLoja = widget.nomeLoja;
  }

  void _abrirModalEditarDados(ThemeData theme, Color baseTextColor, Color cardColor, Color hintColor, bool isEscuro) {
    final nomeController = TextEditingController(text: _nomeGerente);
    final emailController = TextEditingController(text: _emailGerente);
    final telefoneController = TextEditingController(text: _telefoneGerente);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final double paddingBottom = MediaQuery.of(context).padding.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset > 0 ? bottomInset + 24 : paddingBottom + 24),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("EDIT INFORMATION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5), overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 8),
                  Text("These changes will be synchronized with your main record.", style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: nomeController,
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Full Name", isEscuro: isEscuro, hintColor: hintColor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Corporate Email", isEscuro: isEscuro, hintColor: hintColor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Phone", isEscuro: isEscuro, hintColor: hintColor),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, 
                        elevation: 0, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                      onPressed: () {
                        setState(() {
                          _nomeGerente = nomeController.text.trim();
                          _emailGerente = emailController.text.trim();
                          _telefoneGerente = telefoneController.text.trim();
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Data synchronized with Cloud Firestore!"), backgroundColor: accentColor, behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _abrirModalNotificacoes(ThemeData theme, Color baseTextColor, Color cardColor, Color hintColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ALERT CONFIGURATION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5), overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 8),
                Text("Manage which events trigger push notifications in your center.", style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                _buildSwitchTile("History Movements", "Notify team entries or reductions.", _notificarMovimentacao, (v) {
                  setModalState(() => _notificarMovimentacao = v);
                  setState(() {});
                }, baseTextColor, hintColor, theme),
                Divider(color: theme.dividerColor.withValues(alpha: 0.05), height: 1),
                _buildSwitchTile("Local Team Alerts", "Warn when new pins are activated.", _notificarNovaEquipe, (v) {
                  setModalState(() => _notificarNovaEquipe = v);
                  setState(() {});
                }, baseTextColor, hintColor, theme),
                Divider(color: theme.dividerColor.withValues(alpha: 0.05), height: 1),
                _buildSwitchTile("Critical Stock Variances", "Immediate warning if an input reaches the minimum threshold.", _notificarEstoqueCritico, (v) {
                  setModalState(() => _notificarEstoqueCritico = v);
                  setState(() {});
                }, baseTextColor, hintColor, theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String sub, bool value, ValueChanged<bool> onChanged, Color baseTextColor, Color hintColor, ThemeData theme) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: baseTextColor), overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(sub, style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600)),
      activeColor: accentColor,
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final hintColor = isEscuro ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4);
    final borderColor = isEscuro ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("MY PROFILE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: baseTextColor, letterSpacing: -0.5), overflow: TextOverflow.ellipsis, maxLines: 1),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: accentColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded, size: 45, color: accentColor),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 2)
                        ),
                        child: Icon(Icons.camera_alt_rounded, size: 14, color: baseTextColor),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(_nomeGerente.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5), overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 4),
                const Text("CORPORATE MANAGER (FULL ACCESS)", style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5), overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 4),
                Text("CENTRAL UNIT - ${_nomeLoja.toUpperCase()}", style: TextStyle(color: hintColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5), overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3))
                  ),
                  child: const Text(
                    "UNLIMITED CORPORATE",
                    style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          _buildTituloSecao("ACCOUNT"),
          _buildOptionTile(Icons.person_outline_rounded, "EDIT DATA", "Name, email, and phone", cardColor, borderColor, hintColor, baseTextColor, 
            onTap: () => _abrirModalEditarDados(theme, baseTextColor, cardColor, hintColor, isEscuro)),
          _buildOptionTile(Icons.lock_outline_rounded, "CHANGE PASSWORD", "Keep your credential secure", cardColor, borderColor, hintColor, baseTextColor, onTap: () {}),
          
          const SizedBox(height: 24),
          _buildTituloSecao("UNIT PERMISSIONS"),
          _buildOptionTile(Icons.notifications_none_rounded, "NOTIFICATIONS", "Stock, team, and flow alerts", cardColor, borderColor, hintColor, baseTextColor, 
            onTap: () => _abrirModalNotificacoes(theme, baseTextColor, cardColor, hintColor)),
          
          _buildOptionTile(
            Icons.people_alt_outlined, 
            "MANAGE TEAM", 
            "${_funcionarios.length} operators under your management", 
            cardColor, borderColor, hintColor, baseTextColor,
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, color: accentColor, size: 16),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => _buildSubTelaFuncionarios(theme, baseTextColor, cardColor, bgColor, borderColor, hintColor, isEscuro)));
            }
          ),

          _buildOptionTile(
            Icons.account_balance_wallet_outlined, 
            "FINANCIAL MODULE", 
            "Full Access (Costs, COGS, and Inventory)",
            cardColor, borderColor, hintColor, baseTextColor,
            trailing: const Icon(Icons.verified_user_rounded, color: accentColor, size: 20),
            onTap: () {}
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: Icon(Icons.power_settings_new_rounded, color: Colors.redAccent.shade400, size: 20),
              label: Text("LOG OUT", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.shade400.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.redAccent.shade400.withValues(alpha: 0.2))),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSubTelaFuncionarios(ThemeData theme, Color baseTextColor, Color cardColor, Color bgColor, Color borderColor, Color hintColor, bool isEscuro) {
    return StatefulBuilder(
      builder: (context, setSubState) {
        void dispararAdicao() {
          String nome = "";
          String cargo = "Kitchen";

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("REGISTER OPERATOR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5), overflow: TextOverflow.ellipsis, maxLines: 1),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Full Name", isEscuro: isEscuro, hintColor: hintColor),
                    onChanged: (v) => nome = v,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: cargo,
                    dropdownColor: cardColor,
                    style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: _inputStyleField(label: "Department", isEscuro: isEscuro, hintColor: hintColor),
                    items: ["Kitchen", "Cashier", "Inventory", "Service"].map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => cargo = v ?? "Kitchen",
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), 
                  child: Text("CANCEL", style: TextStyle(color: hintColor, fontWeight: FontWeight.w900, fontSize: 11))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    if (nome.trim().isNotEmpty) {
                      setState(() => _funcionarios.add({"nome": nome, "cargo": cargo, "pin": (1000 + _funcionarios.length * 9).toString()}));
                      setSubState(() {});
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("SAVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text("LOCAL TEAM", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5), overflow: TextOverflow.ellipsis, maxLines: 1),
            backgroundColor: Colors.transparent, 
            elevation: 0,
            iconTheme: IconThemeData(color: baseTextColor),
            actions: [
              IconButton(icon: const Icon(Icons.person_add_alt_1_rounded, color: accentColor), onPressed: dispararAdicao),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            itemCount: _funcionarios.length,
            itemBuilder: (ctx, index) {
              final func = _funcionarios[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor, 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor)
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: accentColor.withValues(alpha: 0.1), child: const Icon(Icons.badge_outlined, color: accentColor, size: 20)),
                  title: Text(func["nome"]!.toUpperCase(), style: TextStyle(color: baseTextColor, fontSize: 13, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis, maxLines: 1),
                  subtitle: Text("${func["cargo"]} • PIN: ${func["pin"]}", style: TextStyle(color: hintColor, fontSize: 11, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, maxLines: 1),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.shade400, size: 22),
                    onPressed: () {
                      setState(() => _funcionarios.removeAt(index));
                      setSubState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTituloSecao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        titulo, 
        style: const TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon, 
    String title, 
    String sub, 
    Color cardColor, 
    Color borderColor,
    Color hintColor,
    Color baseTextColor, 
    {Widget? trailing, required VoidCallback onTap}
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: hintColor, size: 22),
        title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 0.2), overflow: TextOverflow.ellipsis, maxLines: 1),
        subtitle: Text(sub, style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, maxLines: 1),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: hintColor.withValues(alpha: 0.5), size: 20),
        onTap: onTap,
      ),
    );
  }

  InputDecoration _inputStyleField({required String label, required bool isEscuro, required Color hintColor}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: hintColor, fontSize: 13, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: isEscuro ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accentColor, width: 1.0)),
    );
  }
}