import 'package:flutter/material.dart';

class PinAuthService {
  static Future<bool> validarPin(BuildContext context, {required List<Map<String, String>> funcionarios}) async {
    String pinDigitado = "";
    String setorSelecionado = "Cozinha"; // Estado inicial baseado na imagem

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0A), // Fundo preto profundo da imagem
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            
            // Cores baseadas na imagem
            const Color corVerdeNexo = Color(0xFF00E676);
            const Color corLaranjaAtivo = Color(0xFFFFA726);
            const Color corInativo = Color(0xFF333333);

            void pressionarTecla(String texto) {
              if (pinDigitado.length < 4) {
                setModalState(() => pinDigitado += texto);
              }
              if (pinDigitado.length == 4) {
                // Valida se existe o PIN na lista de funcionários
                bool pinValido = funcionarios.any((f) => f["pin"] == pinDigitado);
                if (pinValido) {
                  Navigator.pop(context, true);
                } else {
                  setModalState(() => pinDigitado = ""); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("🚨 PIN Incorreto!", style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }

            void apagarDigito() {
              if (pinDigitado.isNotEmpty) {
                setModalState(() => pinDigitado = pinDigitado.substring(0, pinDigitado.length - 1));
              }
            }

            // Widget para os botões de Setor (Cozinha, Bar, Copa)
            Widget buildSetorIcon(String nome, IconData icone) {
              bool ativo = setorSelecionado == nome;
              return GestureDetector(
                onTap: () => setModalState(() => setorSelecionado = nome),
                child: Column(
                  children: [
                    Container(
                      width: 65, height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ativo ? corLaranjaAtivo : Colors.transparent,
                        border: Border.all(color: ativo ? corLaranjaAtivo : corInativo, width: 2),
                      ),
                      child: Icon(icone, color: ativo ? Colors.black : corInativo, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(nome, style: TextStyle(color: ativo ? Colors.white : corInativo, fontSize: 12, fontWeight: ativo ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              );
            }

            // Widget para as teclas numéricas
            Widget buildTecla(String texto, {Widget? child, VoidCallback? customTap}) {
              return Expanded(
                child: InkWell(
                  onTap: customTap ?? () => pressionarTecla(texto),
                  child: Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: child ?? Text(texto, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300)),
                  ),
                ),
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Título Unidade
                  const Text("UNIDADE CENTRO", style: TextStyle(color: corVerdeNexo, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 50),
                  
                  // Seleção de Setores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildSetorIcon("Cozinha", Icons.restaurant_rounded),
                      buildSetorIcon("Bar", Icons.local_bar_rounded),
                      buildSetorIcon("Copa", Icons.local_cafe_rounded),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Indicadores de Traço (Baseados na imagem)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      bool preenchido = index < pinDigitado.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 30,
                        height: 2,
                        color: preenchido ? Colors.white : corInativo,
                      );
                    }),
                  ),
                  const SizedBox(height: 60),

                  // Teclado Numérico
                  Column(
                    children: [
                      Row(children: [buildTecla("1"), buildTecla("2"), buildTecla("3")]),
                      Row(children: [buildTecla("4"), buildTecla("5"), buildTecla("6")]),
                      Row(children: [buildTecla("7"), buildTecla("8"), buildTecla("9")]),
                      Row(children: [
                        buildTecla("", child: const Text("C", style: TextStyle(color: Colors.white, fontSize: 24)), customTap: () => setModalState(() => pinDigitado = "")),
                        buildTecla("0"),
                        buildTecla("", child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 24), customTap: apagarDigito),
                      ]),
                    ],
                  ),
                  
                  const Spacer(),
                  // Botão Voltar
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Voltar ao início", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );

    return resultado ?? false;
  }
}