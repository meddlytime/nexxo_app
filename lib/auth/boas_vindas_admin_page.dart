import 'package:flutter/material.dart';
import 'package:app_estoque/comum/setup_estoque_pagina.dart'; 
import 'package:app_estoque/auth/compartilhar_acesso_page.dart'; 

class BoasVindasAdminPage extends StatelessWidget {
  final String nomeLoja;
  final String codigoLoja; 

  const BoasVindasAdminPage({
    super.key,
    required this.nomeLoja,
    required this.codigoLoja, 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    // Identidade Visual Nexo
    final Color bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final Color baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final Color subTextColor = isEscuro ? Colors.white54 : const Color(0xFF6E6E73);
    final Color cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    const Color accentColor = Color(0xFF00E676); // Verde Esmeralda Nexo

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView( 
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Icone de Sucesso Minimalista
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 48, color: accentColor),
              ),
              const SizedBox(height: 32),
              Text(
                "UNIDADE ATIVA:\n${nomeLoja.toUpperCase()}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5, height: 1.1),
              ),
              const SizedBox(height: 16),
              Text(
                "Sua unidade foi registrada com sucesso. Compartilhe o código abaixo com sua equipe.",
                textAlign: TextAlign.center,
                style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
              ),
              
              const SizedBox(height: 40),

              // Card do Código
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      codigoLoja,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "CÓDIGO DE ACESSO EXCLUSIVO", 
                      style: TextStyle(fontSize: 10, color: subTextColor, letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Botões de Ação
              _buildBotaoOpcao(
                context,
                label: "CONFIGURAR ESTOQUE",
                sub: "Definir categorias e estrutura inicial",
                icon: Icons.settings_rounded,
                cor: accentColor,
                textColor: Colors.black,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupEstoquePage())),
              ),
              const SizedBox(height: 14),
              _buildBotaoOpcao(
                context,
                label: "DELEGAR AO GERENTE",
                sub: "Enviar convite e código de acesso",
                icon: Icons.share_rounded,
                cor: cardColor,
                textColor: baseTextColor,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompartilharAcessoPage(codigoLoja: codigoLoja, nomeLoja: nomeLoja))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoOpcao(
    BuildContext context, {
    required String label, 
    required String sub, 
    required IconData icon, 
    required Color cor, 
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final bool isSecondary = cor == (isEscuro ? const Color(0xFF121214) : Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(16),
        border: isSecondary ? Border.all(color: theme.dividerColor) : null,
        boxShadow: isSecondary ? [] : [BoxShadow(color: cor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: textColor, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(sub, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.6))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: textColor.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}