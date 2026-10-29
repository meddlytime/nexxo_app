import 'package:flutter/material.dart';

class PinAuthService {
  static Future<bool> validarPin(BuildContext context, {required List<Map<String, String>> funcionarios}) async {
    String pinDigitado = "";
    String setorSelecionado = "Kitchen";

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            const Color corVerdeNexo = Color(0xFF00E676);
            const Color corLaranjaAtivo = Color(0xFFFFA726);
            const Color corInativo = Color(0xFF333333);

            void pressionarTecla(String texto) {
              if (pinDigitado.length < 4) {
                setModalState(() => pinDigitado += texto);
              }
              if (pinDigitado.length == 4) {
                bool pinValido = funcionarios.any((f) => f["pin"] == pinDigitado);
                if (pinValido) {
                  Navigator.pop(context, true);
                } else {
                  setModalState(() => pinDigitado = ""); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("🚨 Incorrect PIN!", style: TextStyle(fontWeight: FontWeight.bold)),
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

            Widget buildSetorIcon(String nome, IconData icone) {
              bool ativo = setorSelecionado == nome;
              return GestureDetector(
                onTap: () => setModalState(() => setorSelecionado = nome),
                child: Column(
                  children: [
                    Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ativo ? corLaranjaAtivo : Colors.transparent,
                        border: Border.all(color: ativo ? corLaranjaAtivo : corInativo, width: 2),
                      ),
                      child: Icon(icone, color: ativo ? Colors.black : corInativo, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(nome, style: TextStyle(color: ativo ? Colors.white : corInativo, fontSize: 11, fontWeight: ativo ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              );
            }

            Widget buildTecla(String texto, {Widget? child, VoidCallback? customTap}) {
              return Expanded(
                child: InkWell(
                  onTap: customTap ?? () => pressionarTecla(texto),
                  child: Container(
                    height: 65,
                    alignment: Alignment.center,
                    child: child ?? Text(texto, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300)),
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 20),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const Text("DOWNTOWN UNIT", style: TextStyle(color: corVerdeNexo, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 25),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildSetorIcon("Kitchen", Icons.restaurant_rounded),
                          buildSetorIcon("Bar", Icons.local_bar_rounded),
                          buildSetorIcon("Pantry", Icons.local_cafe_rounded),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          bool preenchido = index < pinDigitado.length;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 25,
                            height: 2,
                            color: preenchido ? Colors.white : corInativo,
                          );
                        }),
                      ),
                      const SizedBox(height: 30),

                      Column(
                        children: [
                          Row(children: [buildTecla("1"), buildTecla("2"), buildTecla("3")]),
                          Row(children: [buildTecla("4"), buildTecla("5"), buildTecla("6")]),
                          Row(children: [buildTecla("7"), buildTecla("8"), buildTecla("9")]),
                          Row(children: [
                            buildTecla("", child: const Text("C", style: TextStyle(color: Colors.white, fontSize: 22)), customTap: () => setModalState(() => pinDigitado = "")),
                            buildTecla("0"),
                            buildTecla("", child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 22), customTap: apagarDigito),
                          ]),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Back to home", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return resultado ?? false;
  }
}