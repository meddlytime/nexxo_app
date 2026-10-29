import 'package:flutter/material.dart';
import 'package:nexxo/auth/login_page.dart';

class CompartilharAcessoPage extends StatelessWidget {
  final String codigoLoja;
  final String nomeLoja;

  const CompartilharAcessoPage({
    super.key, 
    required this.codigoLoja, 
    required this.nomeLoja,
  });

  void _copiarTextoConvite(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Code copied successfully!"),
        backgroundColor: Color(0xFF2979FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;
    
    final Color bgColor = isEscuro ? const Color(0xFF0A0A0B) : const Color(0xFFF9F9FB);
    final Color baseTextColor = isEscuro ? Colors.white : const Color(0xFF111111);
    final Color subTextColor = isEscuro ? Colors.white54 : const Color(0xFF6E6E73);
    final Color cardColor = isEscuro ? const Color(0xFF121214) : Colors.white;
    const Color managerColor = Color(0xFF2979FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: baseTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: managerColor.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.share_rounded, size: 40, color: managerColor),
              ),
              const SizedBox(height: 32),
              Text(
                "Manager Access", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: baseTextColor, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Text(
                "Share the code below. The manager will have full operational access to ${nomeLoja.toUpperCase()}.",
                textAlign: TextAlign.center,
                style: TextStyle(color: subTextColor, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
              ),
              
              const SizedBox(height: 40),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: managerColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(codigoLoja, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: managerColor, letterSpacing: 6)),
                    const SizedBox(height: 8),
                    Text("MASTER ACCESS CODE", style: TextStyle(fontSize: 10, color: subTextColor, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: managerColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () => _copiarTextoConvite(context),
                  icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
                  label: const Text("COPY CODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
              
              const SizedBox(height: 25),
              
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false),
                child: Text("LOG OUT & AWAIT MANAGER", style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}