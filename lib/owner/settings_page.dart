import 'package:flutter/material.dart';
import 'package:nexxo/auth/login_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexxo/owner/config_terminal_page.dart'; 
import 'package:nexxo/owner/company_data_page.dart'; 
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AjustesPage extends StatefulWidget {
  final String codigoTerminal; 

  const AjustesPage({
    super.key, 
    this.codigoTerminal = "NEX-100", 
  });

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  bool _notificacoesEstoque = true;
  bool _gerenteVeFinanceiro = true; 
  bool _gerentePodeComprar = false; 
  bool _bloqueioAutomaticoTerminal = true;

  static const Color accentColor = Color(0xFF00E676); 

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    final Color bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final Color baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final Color cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final Color hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "SETTINGS", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: baseTextColor, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _buildHeaderSessao("ESTABLISHMENT", accentColor),
          _buildTile(
            icon: LucideIcons.store,
            title: "Restaurant Data",
            subtitle: "Name, CNPJ, and Tax Address",
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DadosEmpresaPage())),
          ),
          _buildTile(
            icon: LucideIcons.qrCode,
            title: "Terminal Code / Token",
            subtitle: "${widget.codigoTerminal} (Used to link new tablets)", // Código dinâmico a ser exibido aqui
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            trailing: const Icon(LucideIcons.copy, size: 16, color: accentColor),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Terminal code copied to clipboard!")),
              );
            },
          ),

          const SizedBox(height: 32),

          _buildHeaderSessao("OPERATION TERMINAL & PINs", const Color(0xFFFF9100)),
          _buildTile(
            icon: LucideIcons.users,
            title: "Team and PIN Management",
            subtitle: "Create managers, cooks, and define quick accesses",
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigTerminalPage())),
          ),
          _buildSwitchTile(
            icon: LucideIcons.lock,
            title: "Automatic Session Lock",
            subtitle: "Return to PIN screen after counter inactivity",
            value: _bloqueioAutomaticoTerminal,
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onChanged: (val) => setState(() => _bloqueioAutomaticoTerminal = val),
          ),

          const SizedBox(height: 32),

          _buildHeaderSessao("GOVERNANCE AND PERMISSIONS", const Color(0xFF2979FF)),
          _buildSwitchTile(
            icon: LucideIcons.badgeDollarSign,
            title: "Manager Sees Financials",
            subtitle: "Display total revenue and margins for the manager role",
            value: _gerenteVeFinanceiro,
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onChanged: (val) => setState(() => _gerenteVeFinanceiro = val),
          ),
          _buildSwitchTile(
            icon: LucideIcons.shoppingCart,
            title: "Purchasing Autonomy",
            subtitle: "Allow managers to create and edit stock orders",
            value: _gerentePodeComprar,
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onChanged: (val) => setState(() => _gerentePodeComprar = val),
          ),

          const SizedBox(height: 32),

          _buildHeaderSessao("INTELLIGENT ALERTS", accentColor),
          _buildSwitchTile(
            icon: LucideIcons.bellRing,
            title: "Critical Stock",
            subtitle: "Push notifications when items reach the minimum",
            value: _notificacoesEstoque,
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onChanged: (val) => setState(() => _notificacoesEstoque = val),
          ),

          const SizedBox(height: 32),

          _buildHeaderSessao("HELP & SUPPORT", hintColor),
          _buildTile(
            icon: FontAwesomeIcons.whatsapp,
            title: "VIP Technical Support",
            subtitle: "Direct service via dedicated channel",
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onTap: () {},
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginPage()), 
                  (route) => false,
                );
              },
              icon: Icon(LucideIcons.logOut, color: Colors.redAccent.shade400, size: 18),
              label: Text("LOG OUT", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              "NEXXO SYSTEMS MANAGEMENT © 2026", 
              style: TextStyle(color: hintColor.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSessao(String titulo, Color cor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        titulo, 
        style: TextStyle(color: cor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required Color cardColor,
    required bool isEscuro,
    required Color baseTextColor,
    required Color hintColor,
    Widget? trailing, 
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: baseTextColor.withOpacity(0.7), size: 18),
        ),
        title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: baseTextColor)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w500)),
        trailing: trailing ?? Icon(LucideIcons.chevronRight, color: hintColor.withOpacity(0.3), size: 16),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required bool value, 
    required Color cardColor,
    required bool isEscuro,
    required Color baseTextColor,
    required Color hintColor,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: baseTextColor.withOpacity(0.7), size: 18),
        ),
        activeColor: accentColor,
        activeTrackColor: accentColor.withOpacity(0.25),
        inactiveTrackColor: isEscuro ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
        title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: baseTextColor)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w500)),
      ),
    );
  }
}