import 'package:flutter/material.dart';
import 'package:nexxo/manager/staff_details_page.dart';

class PerfilChefePage extends StatefulWidget {
  const PerfilChefePage({super.key});

  @override
  State<PerfilChefePage> createState() => _PerfilChefePageState();
}

class _PerfilChefePageState extends State<PerfilChefePage> {
  final _formKeyDados = GlobalKey<FormState>();
  
  late TextEditingController _nomeController;
  late TextEditingController _cnpjController;
  String _nivelSelecionado = 'Operational';

  static const Color accentColor = Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: "Vila Gourmet");
    _cnpjController = TextEditingController(text: "12.345.678/0001-90");
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  void _salvarDadosDoEstabelecimento() {
    if (_formKeyDados.currentState!.validate()) {
      setState(() {
        _nomeController.text = _nomeController.text.trim();
        _cnpjController.text = _cnpjController.text.trim();
      });
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Data successfully updated!"),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
      ));
    }
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
        title: Text("ADMINISTRATIVE MANAGEMENT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: baseTextColor, letterSpacing: 1.5)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            _buildAvatarHeader(baseTextColor, hintColor),
            
            const SizedBox(height: 40),

            _buildSectionTitle("ACTIVE UNIT", accentColor),
            _buildProfileOption(
              Icons.storefront_rounded, "Establishment Data", _nomeController.text, 
              cardColor, isEscuro, baseTextColor, hintColor, 
              onTap: () => _modalDadosRestaurante(baseTextColor, hintColor)
            ),
            _buildProfileOption(
              Icons.badge_rounded, "Manage Employees", "Active Managers and Operators", 
              cardColor, isEscuro, baseTextColor, hintColor, 
              onTap: () => _modalGerenciarEquipe(baseTextColor, cardColor, hintColor)
            ),

            const SizedBox(height: 32),

            _buildSectionTitle("REPORTS AND SECURITY", const Color(0xFF2979FF)),
            _buildProfileOption(
              Icons.file_download_outlined, "Export Reports", "Monthly Movements PDF", 
              cardColor, isEscuro, baseTextColor, hintColor, 
              onTap: _modalExportarRelatorios
            ),

            const SizedBox(height: 48),

            _buildLogoutButton(isEscuro),
            
            const SizedBox(height: 32),
            Center(
              child: Text(
                "NEXXO SYSTEMS MANAGEMENT © 2026", 
                style: TextStyle(color: hintColor.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarHeader(Color baseTextColor, Color hintColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
          child: const CircleAvatar(
            radius: 48,
            backgroundColor: accentColor,
            child: Icon(Icons.person_rounded, size: 50, color: Colors.black),
          ),
        ),
        const SizedBox(height: 20),
        Text("Fernando Lopes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: baseTextColor)),
        Text("OWNER", style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color cor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 16),
        child: Text(
          title,
          style: TextStyle(color: cor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, Color cardColor, bool isEscuro, Color baseTextColor, Color hintColor, {Color? corIcone, required VoidCallback onTap}) {
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
        leading: Icon(icon, color: corIcone ?? hintColor, size: 22),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: baseTextColor)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: hintColor, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded, color: hintColor.withOpacity(0.3), size: 20),
      ),
    );
  }

  Widget _buildLogoutButton(bool isEscuro) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: _confirmarLogout,
        icon: Icon(Icons.power_settings_new_rounded, color: Colors.redAccent.shade400, size: 18),
        label: Text("LOG OUT", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.redAccent.withOpacity(0.3), width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _modalDadosRestaurante(Color baseTextColor, Color hintColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: _formKeyDados,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("EDIT HEADQUARTERS INFORMATION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                decoration: _inputDecorationStyle("Establishment Name", Icons.storefront_rounded),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Field cannot be empty" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cnpjController,
                style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                decoration: _inputDecorationStyle("Corporate CNPJ", Icons.business_center_rounded),
                validator: (v) => (v == null || v.trim().length < 14) ? "Invalid CNPJ" : null,
              ),
              const SizedBox(height: 32),
              _buildBotaoAcao("SAVE CHANGES", accentColor, _salvarDadosDoEstabelecimento),
            ],
          ),
        ),
      ),
    );
  }

  void _modalGerenciarEquipe(Color baseTextColor, Color cardColor, Color hintColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ACTIVE EMPLOYEES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
            const SizedBox(height: 24),
            _buildCardFuncionario("Carlos Oliveira", "Kitchen", "Operational", "VG-001", baseTextColor, cardColor, hintColor),
            _buildCardFuncionario("Ana Souza", "General Manager", "Administrator", "VG-002", baseTextColor, cardColor, hintColor),
            const SizedBox(height: 24),
            _buildBotaoAcao("ADD NEW ACCESS", accentColor.withOpacity(0.1), () {
              Navigator.pop(context);
              _modalNovoFuncionario(baseTextColor, hintColor);
            }, isOutlined: true),
          ],
        ),
      ),
    );
  }

  void _modalNovoFuncionario(Color baseTextColor, Color hintColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("REGISTER ACCESS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
              const SizedBox(height: 24),
              _buildFieldSimples("Full Name", Icons.person_outline_rounded, baseTextColor, hintColor),
              const SizedBox(height: 16),
              _buildFieldSimples("Role / Function", Icons.work_outline_rounded, baseTextColor, hintColor),
              const SizedBox(height: 32),
              Text("SYSTEM PERMISSION LEVEL", style: TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              _buildOpcaoAcesso(setModalState, "Operational", "Stock entries and reductions only.", baseTextColor, hintColor),
              _buildOpcaoAcesso(setModalState, "Manager", "Approves requests and edits alerts.", baseTextColor, hintColor),
              _buildOpcaoAcesso(setModalState, "Administrator", "Full access (Financial and Team).", baseTextColor, hintColor),
              const SizedBox(height: 32),
              _buildBotaoAcao("GENERATE ACCESS CODE", accentColor, () {
                Navigator.pop(context);
                _mostrarAviso("New access successfully created!");
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFuncionario(String nome, String cargo, String acesso, String codigo, Color baseTextColor, Color cardColor, Color hintColor) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetalhesFuncionarioPage(nome: nome, cargo: cargo, acesso: acesso, codigo: codigo, idDocumento: '')));
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: accentColor.withOpacity(0.1),
          child: Text(nome[0], style: const TextStyle(color: accentColor, fontWeight: FontWeight.w900)),
        ),
        title: Text(nome, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: baseTextColor)),
        subtitle: Text("$cargo • $acesso", style: TextStyle(fontSize: 12, color: hintColor, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: hintColor.withOpacity(0.3)),
      ),
    );
  }

  InputDecoration _inputDecorationStyle(String label, IconData icon) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: accentColor.withOpacity(0.8), size: 20),
      filled: true,
      fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: accentColor, width: 1.0)),
    );
  }

  Widget _buildFieldSimples(String label, IconData icon, Color baseTextColor, Color hintColor) {
    return TextField(
      style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: _inputDecorationStyle(label, icon),
    );
  }

  Widget _buildOpcaoAcesso(StateSetter setModalState, String titulo, String desc, Color baseTextColor, Color hintColor) {
    return RadioListTile<String>(
      value: titulo,
      groupValue: _nivelSelecionado,
      activeColor: accentColor,
      contentPadding: EdgeInsets.zero,
      title: Text(titulo, style: TextStyle(fontSize: 14, color: baseTextColor, fontWeight: FontWeight.w800)),
      subtitle: Text(desc, style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w500)),
      onChanged: (value) => setModalState(() => _nivelSelecionado = value!),
    );
  }

  Widget _buildBotaoAcao(String texto, Color cor, VoidCallback acao, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: accentColor.withOpacity(0.5), width: 1.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: acao,
              child: Text(texto, style: const TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cor, 
                elevation: 0, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: acao,
              child: Text(texto, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
            ),
    );
  }

  void _modalExportarRelatorios() {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isEscuro ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: accentColor, size: 48),
            SizedBox(height: 16),
            Text("Export Module", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text("This feature generates the monthly PDF report.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _confirmarLogout() {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isEscuro ? const Color(0xFF121214) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Do you want to log out?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Text("You will need your access code to log back in.", style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("CANCEL", style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w800))
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text("LOG OUT NOW", style: TextStyle(color: Colors.redAccent.shade400, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _mostrarAviso(String msg) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isEscuro ? Colors.white : Colors.black)), 
      backgroundColor: isEscuro ? const Color(0xFF2A2A2D) : const Color(0xFFE5E5E5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}