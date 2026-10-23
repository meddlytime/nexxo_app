import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:app_estoque/patrao/dashboard_patrao_page.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);
final senhaOcultaProvider = StateProvider<bool>((ref) => true);

class LoginAdmPage extends ConsumerStatefulWidget {
  const LoginAdmPage({super.key});

  @override
  ConsumerState<LoginAdmPage> createState() => _LoginAdmPageState();
}

class _LoginAdmPageState extends ConsumerState<LoginAdmPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _emailRecuperacaoController = TextEditingController();

  static const Color adminColor = Color(0xFF00E676);

  // --- FLUXO DE LOGIN ---
  void _processarLogin() async {
    if (_formKey.currentState!.validate()) {
      // 🟢 CORRIGIDO: Usando Riverpod para ativar o loading
      ref.read(isLoadingProvider.notifier).state = true;

      // await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _senhaController.text);
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      
      // 🟢 CORRIGIDO: Usando Riverpod para desativar o loading
      ref.read(isLoadingProvider.notifier).state = false;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPatrao()),
        (route) => false,
      );
    }
  }

  void _abrirModalRecuperarSenhaAdmin(bool isEscuro, Color bgColor, Color baseTextColor, Color subTextColor) {
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
                "Insira o e-mail do proprietário para enviarmos o link de redefinição de senha corporativa.", 
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
                    backgroundColor: adminColor, 
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
                        SnackBar(content: Text("Link enviado para $email"), backgroundColor: adminColor, behavior: SnackBarBehavior.floating),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro ao enviar. Verifique o e-mail."), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  child: const Text("ENVIAR REDEFINIÇÃO", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black, letterSpacing: 0.5)),
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
    // 🟢 CORRIGIDO: A tela agora escuta os provedores
    final isLoading = ref.watch(isLoadingProvider);
    final senhaOculta = ref.watch(senhaOcultaProvider);

    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: adminColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.analytics_rounded, size: 28, color: adminColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Acesso\nProprietário", 
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
                    "Visão global, faturamento e controle de licenças.", 
                    style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 45),
                  
                  _buildPremiumTextField(
                    label: "E-mail Corporativo", 
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
                    isPassword: senhaOculta, // 🟢 CORRIGIDO: Usando a variável do Riverpod
                    suffix: IconButton(
                      icon: Icon(senhaOculta ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: subTextColor),
                      onPressed: () {
                        // 🟢 CORRIGIDO: Invertendo o valor no cofre em vez de usar setState
                        ref.read(senhaOcultaProvider.notifier).state = !senhaOculta;
                      },
                    ),
                    validator: (v) => (v == null || v.length < 6) ? "Mínimo de 6 caracteres." : null,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        foregroundColor: adminColor,
                      ),
                      onPressed: () => _abrirModalRecuperarSenhaAdmin(isEscuro, bgColor, baseTextColor, subTextColor),
                      child: const Text(
                        "Esqueceu a senha?",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: adminColor,
                        disabledBackgroundColor: isEscuro ? Colors.white12 : Colors.black12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _processarLogin, // 🟢 CORRIGIDO
                      child: isLoading // 🟢 CORRIGIDO
                          ? const SizedBox(
                              height: 24, width: 24,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                            )
                          : const Text(
                              "ENTRAR NO PAINEL", 
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
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
            prefixIcon: Icon(icon, color: adminColor.withOpacity(0.7), size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: adminColor, width: 1.0)),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}