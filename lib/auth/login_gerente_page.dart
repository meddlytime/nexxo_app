import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_estoque/gerente/dashboard_gerente_page.dart'; 

class LoginGerentePage extends StatefulWidget {
  const LoginGerentePage({super.key});

  @override
  State<LoginGerentePage> createState() => _LoginGerentePageState();
}

class _LoginGerentePageState extends State<LoginGerentePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _emailRecuperacaoController = TextEditingController();

  bool _isLoading = false;
  bool _senhaOculta = true;

  // 🔵 COR IDENTIDADE DO GERENTE (Azul Elétrico)
  static const Color gerenteColor = Color(0xFF2979FF);

  // --- FLUXO DE LOGIN ---
  void _processarLoginGerente() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulação de delay de rede
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 🔓 SEGURANÇA REMOVIDA: Acesso direto liberado para testes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeGerente()),
        (route) => false,
      );
    }
  }

  // --- FLUXO DE RECUPERAÇÃO DE SENHA ---
  void _abrirModalRecuperarSenha(bool isEscuro, Color bgColor, Color baseTextColor, Color subTextColor) {
    _emailRecuperacaoController.text = _emailController.text.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isEscuro ? const Color(0xFF121214) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(25, 20, 25, MediaQuery.of(context).viewInsets.bottom + 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4, 
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: subTextColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10))
                ),
              ),
              Text("Recuperar Acesso", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(
                "Insira o e-mail corporativo para enviarmos o link de redefinição de senha da gerência.", 
                style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4)
              ),
              const SizedBox(height: 25),
              
              _buildPremiumTextField(
                label: "E-mail cadastrado",
                controller: _emailRecuperacaoController,
                icon: Icons.email_outlined,
                isEscuro: isEscuro,
                baseTextColor: baseTextColor,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => null,
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gerenteColor, 
                    elevation: 0, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final email = _emailRecuperacaoController.text.trim();
                    if (email.isEmpty || !email.contains("@")) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Digite um e-mail válido.")));
                      return;
                    }
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Link enviado! Verifique a caixa de entrada."), backgroundColor: gerenteColor, behavior: SnackBarBehavior.floating),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro ao enviar. Verifique o e-mail."), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  child: const Text("ENVIAR REDEFINIÇÃO", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _emailRecuperacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    // Cores puristas alinhadas com o Design System
    final Color bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final Color baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final Color subTextColor = isEscuro ? Colors.white54 : const Color(0xFF6E6E73);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // 🏷️ CABEÇALHO LIMPO E IMPONENTE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: gerenteColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.badge_rounded, size: 28, color: gerenteColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Acesso\nGerente", 
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.w900, 
                      color: baseTextColor,
                      letterSpacing: -0.5,
                      height: 1.1
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Operação diária, equipe e aprovações de estoque.", 
                    style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.w500)
                  ),
                  
                  const SizedBox(height: 45),
                  
                  // 🔵 CAMPOS DE ENTRADA PREMIUM
                  _buildPremiumTextField(
                    label: "E-mail de Gerência", 
                    controller: _emailController, 
                    icon: Icons.email_outlined,
                    isEscuro: isEscuro,
                    baseTextColor: baseTextColor,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains("@")) ? "Insira um e-mail válido." : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildPremiumTextField(
                    label: "Senha de Acesso", 
                    controller: _senhaController, 
                    icon: Icons.lock_outline_rounded, 
                    isEscuro: isEscuro,
                    baseTextColor: baseTextColor,
                    isPassword: _senhaOculta,
                    suffix: IconButton(
                      icon: Icon(_senhaOculta ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: subTextColor),
                      onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? "Mínimo de 6 caracteres." : null,
                  ),

                  // 🔑 ESQUECEU A SENHA
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        foregroundColor: gerenteColor,
                      ),
                      onPressed: () => _abrirModalRecuperarSenha(isEscuro, bgColor, baseTextColor, subTextColor),
                      child: const Text(
                        "Esqueceu a senha?",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 🔵 BOTÃO DE LOGIN SÓLIDO
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gerenteColor,
                        disabledBackgroundColor: isEscuro ? Colors.white12 : Colors.black12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _processarLoginGerente,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24, width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "ACESSAR GERÊNCIA", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 CONSTRUTOR DE TEXTFIELD MINIMALISTA
  Widget _buildPremiumTextField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon, 
    required bool isEscuro,
    required Color baseTextColor,
    bool isPassword = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isEscuro ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: gerenteColor.withOpacity(0.7), size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: gerenteColor, width: 1.0)),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}