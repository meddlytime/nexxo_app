import 'package:flutter/material.dart';

class DadosEmpresaPage extends StatefulWidget {
  const DadosEmpresaPage({super.key});

  @override
  State<DadosEmpresaPage> createState() => _DadosEmpresaPageState();
}

class _DadosEmpresaPageState extends State<DadosEmpresaPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nomeController = TextEditingController(text: "Vila Gourmet Matriz");
  final _cnpjController = TextEditingController(text: "12.345.678/0001-99");
  final _enderecoController = TextEditingController(text: "Av. Principal, 1050 - Centro");

  static const Color accentColor = Color(0xFF00E676); // Verde Nexo

  void _salvarDadosEmpresa() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dados do estabelecimento atualizados com sucesso!"),
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  InputDecoration _inputStyle({required String label, required IconData icon, required bool isEscuro}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: accentColor, size: 20),
      filled: true,
      fillColor: isEscuro ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentColor, width: 1.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("CONFIGURAÇÕES DO ESTABELECIMENTO", 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Identificação Corporativa", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5)),
                Text("Estes dados são vitais para a emissão de notas e relatórios oficiais.", style: TextStyle(fontSize: 14, color: hintColor, fontWeight: FontWeight.w500)),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _nomeController,
                  style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputStyle(label: "Nome Fantasia", icon: Icons.storefront_rounded, isEscuro: isEscuro),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Insira o nome do estabelecimento" : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _cnpjController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputStyle(label: "CNPJ", icon: Icons.business_center_rounded, isEscuro: isEscuro),
                  validator: (v) => (v == null || v.trim().length < 14) ? "Insira um CNPJ válido" : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _enderecoController,
                  style: TextStyle(color: baseTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputStyle(label: "Endereço Completo", icon: Icons.location_on_rounded, isEscuro: isEscuro),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "O endereço é obrigatório" : null,
                ),
                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _salvarDadosEmpresa,
                    child: const Text("SALVAR ALTERAÇÕES", 
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}