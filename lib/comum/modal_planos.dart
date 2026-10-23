import 'package:flutter/material.dart';
import 'package:app_estoque/auth/plano_service.dart';
import 'package:app_estoque/auth/controle_plano.dart';

class ModalPlanosPage extends StatelessWidget {
  const ModalPlanosPage({super.key});

  static const Color accentColor = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final planoAtual = planoService.regras.tipo;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("ESCOLHA SEU NÍVEL DE GESTÃO", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: 1.5)),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: baseTextColor, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Text("Evolua a gestão do seu restaurante conforme seu negócio cresce.",
              textAlign: TextAlign.center,
              style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 40),

          _buildCardPlano(
            context: context,
            titulo: "PLANO BÁSICO",
            preco: "Gratuito",
            cor: const Color(0xFF607D8B),
            isAtual: planoAtual == TipoPlano.basico,
            recursos: ["Acesso exclusivo do Proprietário", "Controle de 1 unidade", "Relatórios simplificados", "Histórico de 7 dias"],
            onMudarPlano: () => planoService.atualizarPlanoDoUsuario('basico'),
          ),

          _buildCardPlano(
            context: context,
            titulo: "PLANO MÉDIO GESTOR",
            preco: "R\$ 99,90",
            cor: const Color(0xFFB388FF),
            isAtual: planoAtual == TipoPlano.medio,
            recursos: ["Conta de Gerente Adicional", "Gestão avançada de perdas", "Até 10 colaboradores", "Auditoria completa"],
            onMudarPlano: () => planoService.atualizarPlanoDoUsuario('medio'),
          ),

          _buildCardPlano(
            context: context,
            titulo: "PREMIUM CORPORATIVO",
            preco: "R\$ 199,90",
            cor: accentColor,
            isAtual: planoAtual == TipoPlano.premium,
            recursos: ["Multi-Loja ativo", "Colaboradores ilimitados", "Reset de PIN em tempo real", "Relatórios consolidados"],
            onMudarPlano: () => planoService.atualizarPlanoDoUsuario('premium'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCardPlano({
    required BuildContext context,
    required String titulo,
    required String preco,
    required Color cor,
    required bool isAtual,
    required List<String> recursos,
    required VoidCallback onMudarPlano,
  }) {
    final isEscuro = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isEscuro ? const Color(0xFF121214) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAtual ? cor : (isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)), width: isAtual ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                if (isAtual)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(6)),
                    child: const Text("PLANO ATIVO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(preco, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isEscuro ? Colors.white : Colors.black)),
            const SizedBox(height: 24),
            ...recursos.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, color: cor, size: 18),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r, style: TextStyle(color: isEscuro ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600))),
                ],
              ),
            )),
            const SizedBox(height: 24),
            if (!isAtual)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    onMudarPlano();
                    Navigator.pop(context);
                  },
                  child: const Text("ASSINAR ESTE PLANO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}