import 'package:flutter/material.dart';
import 'package:app_estoque/auth/login_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_estoque/patrao/config_terminal_page.dart'; 
import 'package:app_estoque/patrao/dados_empresa_page.dart'; 
import 'package:app_estoque/auth/plano_service.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  // --- CONFIGURAÇÕES MAPEADAS ---
  bool _notificacoesEstoque = true;
  bool _notificacoesEquipe = false;
  bool _gerenteVeFinanceiro = true; 
  bool _gerentePodeComprar = false; 

  static const Color accentColor = Color(0xFF00E676); // Verde Nexo

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    // Paleta Nexo Obsidian Purista
    final Color bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final Color baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final Color cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final Color hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("CONFIGURAÇÕES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: baseTextColor, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // --- SEÇÃO: ESTABELECIMENTO ---
          _buildHeaderSessao("ESTABELECIMENTO", accentColor),
          _buildTile(
            icon: Icons.store_rounded,
            title: "Dados do Restaurante",
            subtitle: "Nome, CNPJ e Endereço fiscal",
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DadosEmpresaPage())),
          ),
          _buildTile(
            icon: Icons.qr_code_2_rounded,
            title: "Código da Unidade",
            subtitle: "VILA-882",
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            trailing: const Icon(Icons.copy_rounded, size: 16, color: accentColor),
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // --- SEÇÃO: TERMINAL DA EQUIPE ---
          _buildHeaderSessao("SISTEMA DE TERMINAL", const Color(0xFFFF9100)),
          _buildTile(
            icon: Icons.app_registration_rounded,
            title: "Personalizar Login",
            subtitle: "Gerencie os botões de acesso rápido da equipe",
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigTerminalPage())),
          ),

          const SizedBox(height: 32),

          // --- SEÇÃO: GOVERNANÇA ---
          _buildHeaderSessao("GOVERNANÇA E ACESSOS", const Color(0xFF2979FF)),
          _buildSwitchTile(
            icon: Icons.account_balance_wallet_rounded,
            title: "Gerente vê Financeiro",
            subtitle: "Exibir valor total do estoque para gerentes",
            value: _gerenteVeFinanceiro,
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onChanged: (val) => setState(() => _gerenteVeFinanceiro = val),
          ),
          _buildSwitchTile(
            icon: Icons.shopping_cart_checkout_rounded,
            title: "Autonomia de Compras",
            subtitle: "Permitir que gerentes editem listas de compras",
            value: _gerentePodeComprar,
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onChanged: (val) => setState(() => _gerentePodeComprar = val),
          ),

          const SizedBox(height: 32),

          // --- SEÇÃO: NOTIFICAÇÕES ---
          _buildHeaderSessao("ALERTAS INTELIGENTES", accentColor),
          _buildSwitchTile(
            icon: Icons.inventory_2_rounded,
            title: "Estoque Crítico",
            subtitle: "Push quando itens atingirem o mínimo",
            value: _notificacoesEstoque,
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onChanged: (val) => setState(() => _notificacoesEstoque = val),
          ),

          const SizedBox(height: 32),

          // --- SEÇÃO: SUPORTE ---
          _buildHeaderSessao("AJUDA", hintColor),
          _buildTile(
            icon: FontAwesomeIcons.whatsapp,
            title: "Suporte VIP",
            subtitle: "Consultoria técnica via WhatsApp",
            cardColor: cardColor,
            isEscuro: isEscuro,
            baseTextColor: baseTextColor,
            hintColor: hintColor,
            onTap: () {},
          ),

          const SizedBox(height: 48),

          // --- BOTÃO DE LOGOUT ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: TextButton.icon(
              onPressed: () async {
                await planoService.resetarPlanoAoDeslogar();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
              },
              icon: Icon(Icons.logout_rounded, color: Colors.redAccent.shade400, size: 20),
              label: Text("ENCERRAR SESSÃO", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              "NEXO SISTEMAS v1.2.0 — 2026", 
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
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03), shape: BoxShape.circle),
          child: Icon(icon, color: baseTextColor.withOpacity(0.7), size: 18),
        ),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: baseTextColor)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: hintColor, fontWeight: FontWeight.w500)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: hintColor.withOpacity(0.3), size: 20),
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
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03), shape: BoxShape.circle),
          child: Icon(icon, color: baseTextColor.withOpacity(0.7), size: 18),
        ),
        activeColor: accentColor,
        activeTrackColor: accentColor.withOpacity(0.2),
        inactiveTrackColor: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: baseTextColor)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: hintColor, fontWeight: FontWeight.w500)),
      ),
    );
  }
}