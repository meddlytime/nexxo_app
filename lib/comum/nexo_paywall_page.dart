import 'package:flutter/material.dart';
import 'nexo_recurso.dart'; // Import do enum acima

class NexoPaywallPage extends StatelessWidget {
  final NexoRecurso recurso;

  const NexoPaywallPage({
    super.key, 
    required this.recurso
  });

  static const Color accentColor = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);
    final borderColor = isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: baseTextColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Parte Superior: Identidade do Bloqueio
              Column(
                children: [
                  const SizedBox(height: 20),
                  // Badge do Plano Requerido
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.shade700.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orangeAccent.shade700.withOpacity(0.3)),
                    ),
                    child: Text(
                      "RECURSO PREMIUM RESTRITO",
                      style: TextStyle(color: Colors.orangeAccent.shade700, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Ícone Dinâmico do Recurso
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withOpacity(0.15)),
                    ),
                    child: Icon(recurso.icone, color: accentColor, size: 40),
                  ),
                  const SizedBox(height: 24),
                  
                  // Título Dinâmico
                  Text(
                    recurso.titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  
                  // Descrição Dinâmica
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      recurso.descricao,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: hintColor, fontWeight: FontWeight.w600, height: 1.5),
                    ),
                  ),
                ],
              ),

              // Parte Inferior: Caixa de Oferta e Ação de Compra
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("PLANO SUPERVISOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: hintColor, letterSpacing: 0.5)),
                            const SizedBox(height: 4),
                            Text("Upgrade de Unidade", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: baseTextColor)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("R\$ 49,90", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accentColor)),
                            Text("/mensal", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: hintColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botão de Ação Principal
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        // Fluxo de pagamento ou gatilho de checkout aqui
                      },
                      child: const Text("LIBERAR ACESSO IMEDIATO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    "Cancele ou altere de plano a qualquer momento.",
                    style: TextStyle(color: hintColor, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}