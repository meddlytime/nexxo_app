import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:nexxo/auth/welcome_admin_page.dart';

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

  double _forcaSenha = 0.0;
  String _mensagemRegra = "Enter a secure password";
  Color _corBarra = Colors.grey;

  bool _temTamanhoMinimo = false;
  bool _temMaiuscula = false;
  bool _temMinuscula = false;
  bool _temNumero = false;
  bool _temEspecial = false;
  bool _eSenhaObvia = false;

  static const Color accentColor = Color(0xFF00E676);

  String _gerarCodigoLoja(String nome) {
    if (nome.trim().isEmpty) return "NEX-100";
    
    String limpo = nome.trim().replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (limpo.isEmpty) return "NEX-100";
    
    String prefixo;
    Random random = Random();
    
    if (limpo.length <= 3) {
      prefixo = limpo;
    } else {
  
      bool usarPrimeiras = random.nextBool();
      
      if (usarPrimeiras) {
        prefixo = limpo.substring(0, 3); 
      } else {
        prefixo = limpo.substring(limpo.length - 3); 
      }
    }
    
    int numeroAleatorio = random.nextInt(900) + 100;
    
    return "$prefixo-$numeroAleatorio";
  }

  bool _isSenhaObviaOuFraca(String senha) {
    if (senha.isEmpty) return false;
    final s = senha.toLowerCase();
    
    final blacklisted = ['12345678', '123456789', '1234567890', 'password', 'senha123', 'admin123', '11111111'];
    if (blacklisted.contains(s)) return true;

    if (RegExp(r'^(.)\1+$').hasMatch(s)) return true;

    if (s.contains('123456') || s.contains('654321') || s.contains('012345') || s.contains('789101')) return true;

    return false;
  }

  void _avaliarSenha(String senha) {
    setState(() {
      _temTamanhoMinimo = senha.length >= 8;
      _temMaiuscula = senha.contains(RegExp(r'[A-Z]'));
      _temMinuscula = senha.contains(RegExp(r'[a-z]'));
      _temNumero = senha.contains(RegExp(r'[0-9]'));
      _temEspecial = senha.contains(RegExp(r'[!@#\$&*~_.,\-\+=?]'));
      _eSenhaObvia = _isSenhaObviaOuFraca(senha);

      if (_eSenhaObvia) {
        _forcaSenha = 0.2;
        _mensagemRegra = "Common password or obvious sequence!";
        _corBarra = Colors.redAccent;
        return;
      }

      int pontuacao = 0;
      if (_temTamanhoMinimo) pontuacao++;
      if (_temMaiuscula) pontuacao++;
      if (_temMinuscula) pontuacao++;
      if (_temNumero) pontuacao++;
      if (_temEspecial) pontuacao++;

      _forcaSenha = pontuacao / 5.0;

      if (senha.isEmpty) {
        _mensagemRegra = "Fill in security requirements";
        _corBarra = Colors.grey;
      } else if (pontuacao <= 2) {
        _mensagemRegra = "Weak password";
        _corBarra = Colors.redAccent;
      } else if (pontuacao <= 4) {
        _mensagemRegra = "Medium password";
        _corBarra = Colors.orangeAccent;
      } else {
        _mensagemRegra = "Strong and secure password!";
        _corBarra = accentColor;
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _nomeLojaController.dispose();
    super.dispose();
  }

  void _finalizarCadastro() async {
    final senha = _senhaController.text;
    
    if (_eSenhaObvia || senha.length < 8 || !_temMaiuscula || !_temMinuscula || !_temNumero || !_temEspecial) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The password does not meet all required security criteria."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _isLoading = false);

      final String nomeLojaDigitado = _nomeLojaController.text.trim();
      final String codigoLojaGerado = _gerarCodigoLoja(nomeLojaDigitado);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeAdminPage(
            nomeLoja: nomeLojaDigitado,
            codigoLoja: codigoLojaGerado, 
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

    final bool temTextoNaSenha = _senhaController.text.isNotEmpty;

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
                Text("Configure Restaurant", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
                Text("Fill in the administrative account details.", style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
                
                const SizedBox(height: 45),

                _buildTextField(
                  label: "Your Full Name", 
                  hint: "Ex: John Smith", 
                  icon: Icons.person_outline, 
                  controller: _nomeController, 
                  isEscuro: isEscuro, 
                  baseTextColor: baseTextColor
                ),
                const SizedBox(height: 20),
                
                _buildTextField(
                  label: "Your Professional Email", 
                  hint: "john@restaurant.com", 
                  icon: Icons.email_outlined, 
                  controller: _emailController, 
                  isEscuro: isEscuro, 
                  baseTextColor: baseTextColor, 
                  keyboardType: TextInputType.emailAddress
                ),
                const SizedBox(height: 20),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your Access Password", style: TextStyle(color: isEscuro ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _senhaOculta,
                      maxLength: 64,
                      onChanged: _avaliarSenha,
                      style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: accentColor.withOpacity(0.7), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_senhaOculta ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: subTextColor), 
                          onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
                        ),
                        hintText: "Enter a secure password",
                        hintStyle: TextStyle(color: isEscuro ? Colors.white30 : Colors.black26),
                        counterText: "",
                        filled: true,
                        fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _corBarra, width: 1.0)),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 8) return "Minimum 8 characters required.";
                        if (_eSenhaObvia) return "Avoid common passwords or sequences.";
                        return null;
                      },
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: temTextoNaSenha
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCompactItem("Minimum of 8 characters", _temTamanhoMinimo, isEscuro),
                                  const SizedBox(height: 4),
                                  _buildCompactItem("Uppercase letter (A-Z)", _temMaiuscula, isEscuro),
                                  const SizedBox(height: 4),
                                  _buildCompactItem("Lowercase letter (a-z)", _temMinuscula, isEscuro),
                                  const SizedBox(height: 4),
                                  _buildCompactItem("Number (0-9)", _temNumero, isEscuro),
                                  const SizedBox(height: 4),
                                  _buildCompactItem("Special character (!@#...)", _temEspecial, isEscuro),
                                  const SizedBox(height: 4),
                                  _buildCompactItem("No obvious sequences (ex: 123456)", !_eSenhaObvia, isEscuro),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 12),
                    
                    LinearProgressIndicator(
                      value: _forcaSenha,
                      backgroundColor: isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      color: _corBarra,
                      minHeight: 4,
                    ),
                    const SizedBox(height: 6),

                    Text(
                      _mensagemRegra,
                      style: TextStyle(color: _corBarra, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                
                const SizedBox(height: 35),
                Text("First Unit Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: baseTextColor)),
                const SizedBox(height: 20),
                
                _buildTextField(
                  label: "Restaurant Name", 
                  hint: "Ex: Downtown Bistro", 
                  icon: Icons.restaurant_rounded, 
                  controller: _nomeLojaController, 
                  isEscuro: isEscuro, 
                  baseTextColor: baseTextColor
                ),
                
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
                      : const Text("COMPLETE & ACCESS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactItem(String texto, bool atendido, bool isEscuro) {
    final Color corAtiva = accentColor;
    final Color corInativa = isEscuro ? Colors.white38 : Colors.black38;
    final Color corAtual = atendido ? corAtiva : corInativa;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          atendido ? Icons.check_rounded : Icons.remove_rounded,
          size: 13,
          color: corAtual,
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
            color: corAtual,
            fontSize: 11,
            fontWeight: atendido ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentColor, width: 1.0)),
          ),
          validator: (v) => (v == null || v.isEmpty) ? "Required field" : null,
        ),
      ],
    );
  }
}