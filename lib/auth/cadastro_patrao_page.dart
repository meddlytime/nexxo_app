import 'package:flutter/material.dart';
import 'package:app_estoque/auth/boas_vindas_admin_page.dart';

class CadastroPatraoPage extends StatefulWidget {
  const CadastroPatraoPage({super.key});

  @override
  State<CadastroPatraoPage> createState() => _CadastroPatraoPageState();
}

class _CadastroPatraoPageState extends State<CadastroPatraoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeLojaController = TextEditingController();

  bool _isLoading = false;
  bool _senhaOculta = true;

  static const Color accentColor = Color(0xFF00E676);

  void _finalizarCadastro() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BoasVindasAdminPage(
            nomeLoja: _nomeLojaController.text.trim(),
            codigoLoja: "VILA-993", 
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final subTextColor = isEscuro ? Colors.white54 : const Color(0xFF6E6E73);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Configurar Restaurante", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
                Text("Preencha os dados da conta administrativa.", style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
                
                const SizedBox(height: 45),

                _buildTextField(label: "Seu Nome", hint: "Ex: João Silva", icon: Icons.person_outline, controller: _nomeController, isEscuro: isEscuro, baseTextColor: baseTextColor),
                const SizedBox(height: 20),
                _buildTextField(label: "E-mail Profissional", hint: "joao@restaurante.com", icon: Icons.email_outlined, controller: _emailController, isEscuro: isEscuro, baseTextColor: baseTextColor, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildTextField(label: "Senha Master", hint: "Mínimo 6 caracteres", icon: Icons.lock_outline_rounded, controller: _senhaController, isEscuro: isEscuro, baseTextColor: baseTextColor, isPassword: _senhaOculta, 
                    suffix: IconButton(icon: Icon(_senhaOculta ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: subTextColor), onPressed: () => setState(() => _senhaOculta = !_senhaOculta))),
                
                const SizedBox(height: 35),
                Text("Dados da Primeira Unidade", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: baseTextColor)),
                const SizedBox(height: 20),
                
                _buildTextField(label: "Nome do Restaurante", hint: "Ex: Vila Gourmet - Centro", icon: Icons.restaurant_rounded, controller: _nomeLojaController, isEscuro: isEscuro, baseTextColor: baseTextColor),
                
                const SizedBox(height: 45),

                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _finalizarCadastro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                      : const Text("CONCLUIR E ACESSAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, required String hint, required IconData icon, required TextEditingController controller, 
    required bool isEscuro, required Color baseTextColor, bool isPassword = false, Widget? suffix, TextInputType keyboardType = TextInputType.text,
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
          style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: accentColor.withOpacity(0.7), size: 20),
            suffixIcon: suffix,
            hintText: hint,
            hintStyle: TextStyle(color: isEscuro ? Colors.white30 : Colors.black26),
            filled: true,
            fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accentColor, width: 1.0)),
          ),
          validator: (v) => (v == null || v.isEmpty) ? "Campo obrigatório" : null,
        ),
      ],
    );
  }
}