import 'package:flutter/material.dart';
import 'package:app_estoque/comum/setup_estoque_pagina.dart'; // Corrigido para bater com o padrão de arquivo

class ValidarConvitePage extends StatefulWidget {
  final String nomeChefe;
  const ValidarConvitePage({super.key, this.nomeChefe = "Fernando"});

  @override
  State<ValidarConvitePage> createState() => _ValidarConvitePageState();
}

class _ValidarConvitePageState extends State<ValidarConvitePage> {
  final _formKey = GlobalKey<FormState>();
  bool _validado = false;
  bool _isLoading = false;

  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nomeGerenteController = TextEditingController();

  // 🛰️ VARIÁVEIS PREPARADAS PARA ARMAZENAR RETORNO DO FIRESTORE
  String _idEmpresaVinculada = "";
  String _nomeLojaVinculada = "";

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeGerenteController.dispose();
    super.dispose();
  }

  // --- FAZ A BUSCA DO CÓDIGO DA LOJA NO FIREBASE ---
  void _verificarCodigoNoBanco() async {
    if (_codigoController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    // 🛰️ FLUXO DE BANCO DE DADOS:
    // var query = await FirebaseFirestore.instance.collection('empresas').where('codigoLoja', == _codigoController.text.trim().toUpperCase()).get();
    // if(query.docs.isNotEmpty) { _idEmpresaVinculada = query.docs.first.id; ... }
    
    await Future.delayed(const Duration(milliseconds: 700)); // Simulação de latência de rede

    setState(() {
      _isLoading = false;
      _validado = true; // Avança para a Etapa 2 (Nome do Gerente)
      _nomeLojaVinculada = "Vila Gourmet Centro"; // Exemplo de dado mockado retornado pelo banco
    });
  }

  // --- CRIA O PERFIL DO GERENTE DENTRO DA LOJA VINCULADA ---
  void _vincularGerenteEAvancar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 🛰️ FLUXO DE BANCO DE DADOS:
      // await FirebaseFirestore.instance.collection('empresas').doc(_idEmpresaVinculada).collection('funcionarios').add({
      //   'nome': _nomeGerenteController.text.trim(),
      //   'cargo': 'GERENTE',
      // });

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text(
            "${_nomeGerenteController.text.trim()} entrou para a equipe de $_nomeLojaVinculada!",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Substitui a tela atual levando as referências de dados vinculadas para o Setup
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const SetupEstoquePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isEscuro ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( 
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _validado ? Icons.badge_outlined : Icons.vpn_key_rounded, 
                    size: 65, 
                    color: _validado ? Colors.blueAccent : Colors.greenAccent
                  ),
                  const SizedBox(height: 25),
                  Text(
                    _validado ? "Identificação de Turno" : "Você foi convidado por ${widget.nomeChefe}!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: baseTextColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _validado 
                        ? "Código aceito para $_nomeLojaVinculada. Agora, informe seu nome para o painel."
                        : "Coloque seu código de acesso fornecido por ele para começar.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subTextColor, fontSize: 14, height: 1.4),
                  ),
                  
                  const SizedBox(height: 35), 

                  if (!_validado) ...[
                    // 🔑 ETAPA 1: VALIDAR CÓDIGO DO CONVITE
                    TextFormField(
                      controller: _codigoController,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters, // Força letras maiúsculas no teclado
                      style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 4),
                      decoration: InputDecoration(
                        hintText: "VILA-000",
                        hintStyle: TextStyle(color: theme.hintColor.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: isEscuro ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18), 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.greenAccent, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25), 
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          disabledBackgroundColor: isEscuro ? Colors.white12 : Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _isLoading ? null : _verificarCodigoNoBanco,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24, width: 24,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                              )
                            : const Text(
                                "VALIDAR CÓDIGO", 
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                      ),
                    ),
                  ] else ...[
                    // 👤 ETAPA 2: CONFIGURAR NOME DO GERENTE VINCULADO
                    TextFormField(
                      controller: _nomeGerenteController,
                      style: TextStyle(color: baseTextColor, fontSize: 14),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Por favor, digite seu nome" : null,
                      decoration: InputDecoration(
                        labelText: "Qual é o seu nome?",
                        labelStyle: TextStyle(color: theme.hintColor),
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.blueAccent, size: 20),
                        filled: true,
                        fillColor: isEscuro ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          disabledBackgroundColor: isEscuro ? Colors.white12 : Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _isLoading ? null : _vincularGerenteEAvancar,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24, width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                "CONCLUIR E CONFIGURAR", 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}