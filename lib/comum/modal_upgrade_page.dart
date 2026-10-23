import 'package:flutter/material.dart';
import 'package:app_estoque/auth/plano_service.dart';
import 'package:app_estoque/auth/controle_plano.dart';
import 'package:app_estoque/comum/nexo_recurso.dart'; // NOVO IMPORT
import 'package:app_estoque/comum/nexo_paywall_page.dart'; // NOVO IMPORT

final ValueNotifier<bool> motorPrevisaoAtivo = ValueNotifier(true);

class ConfiguracaoPrevisaoPage extends StatefulWidget {
  const ConfiguracaoPrevisaoPage({super.key});

  @override
  State<ConfiguracaoPrevisaoPage> createState() => _ConfiguracaoPrevisaoPageState();
}

class _ConfiguracaoPrevisaoPageState extends State<ConfiguracaoPrevisaoPage> {
  static const Color accentColor = Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    planoService.addListener(_atualizarInterface);
    motorPrevisaoAtivo.addListener(_atualizarInterface);
  }

  @override
  void dispose() {
    planoService.removeListener(_atualizarInterface);
    motorPrevisaoAtivo.removeListener(_atualizarInterface);
    super.dispose();
  }

  void _atualizarInterface() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    final hintColor = isEscuro ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);
    final borderColor = isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    final tipoPlano = planoService.regras.tipo;
    final bool temAcessoAoRecurso = tipoPlano == TipoPlano.medio || tipoPlano == TipoPlano.premium;

    return Scaffold(
      backgroundColor: isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text("PREVISÃO DE DEMANDA", 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("STATUS DO MOTOR INTELIGENTE", style: TextStyle(color: hintColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: !temAcessoAoRecurso 
                      ? Colors.orangeAccent.shade700.withOpacity(0.3) 
                      : (motorPrevisaoAtivo.value ? accentColor.withOpacity(0.3) : borderColor)
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CÁLCULO DE COBERTURA", 
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 0.2)
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Analisa o histórico de baixas para prever escassez de insumos.",
                              style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      temAcessoAoRecurso 
                        ? Switch(
                            activeColor: accentColor,
                            activeTrackColor: accentColor.withOpacity(0.2),
                            inactiveThumbColor: hintColor,
                            value: motorPrevisaoAtivo.value,
                            onChanged: (v) {
                              motorPrevisaoAtivo.value = v;
                            },
                          )
                        : Icon(Icons.lock_rounded, color: Colors.orangeAccent.shade700, size: 22),
                    ],
                  ),
                  
                  if (!temAcessoAoRecurso) ...[
                    const SizedBox(height: 20),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      "O módulo de inteligência preditiva está disponível apenas a partir do Plano Supervisor (Médio).",
                      style: TextStyle(fontSize: 11, color: hintColor, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // 🚀 CHAMA O PAYWALL CENTRALIZADO
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NexoPaywallPage(recurso: NexoRecurso.previsaoDemanda)
                            ),
                          );
                        },
                        child: const Text("CONHECER PLANOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}