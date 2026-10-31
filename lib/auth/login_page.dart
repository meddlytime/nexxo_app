import 'package:flutter/material.dart';
import 'package:nexxo/auth/login_owner_page.dart';
import 'package:nexxo/auth/login_manager_page.dart';
import 'package:nexxo/auth/pin_auth_service.dart';
import 'package:nexxo/auth/register_owner_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEscuro = theme.brightness == Brightness.dark;

    final Color bgColor = isEscuro ? const Color(0xFF121214) : const Color(0xFFF6F6F9);
    final Color baseTextColor = isEscuro ? const Color(0xFFE5E5E5) : const Color(0xFF111111);
    final Color subTextColor = isEscuro ? Colors.white54 : const Color(0xFF6E6E73);
    final Color cardColor = isEscuro ? const Color(0xFF1C1C1F) : Colors.white;
    final Color borderColor = isEscuro ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isEscuro ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 1.0),
                      ),
                      child: Icon(Icons.blur_on_rounded, size: 54, color: theme.primaryColor),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "NEXXO",
                      style: TextStyle(
                        fontSize: 42, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 2.5, 
                        color: baseTextColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "S Y S T E M S  M A N A G E M E N T",
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.w600, 
                        letterSpacing: 4, 
                        color: subTextColor
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),

                _buildPremiumPortalButton(
                  label: "Owner Access",
                  icon: Icons.analytics_outlined,
                  accentColor: const Color(0xFF00E676),
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: baseTextColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginAdmPage())),
                ),

                _buildPremiumPortalButton(
                  label: "Local Manager Access",
                  icon: Icons.badge_outlined,
                  accentColor: const Color(0xFF2979FF),
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: baseTextColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginGerentePage())),
                ),

                _buildPremiumPortalButton(
                  label: "Team Terminal",
                  icon: Icons.layers_outlined,
                  accentColor: const Color(0xFFFF9100),
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: baseTextColor,
                  onTap: () async {
                    final mockFuncionarios = [
                      {"nome": "Kitchen", "pin": "0000"},
                      {"nome": "Bar", "pin": "0000"},
                      {"nome": "Cashier", "pin": "0000"}
                    ];

                    bool autorizado = await PinAuthService.validarPin(context, funcionarios: mockFuncionarios);

                    if (autorizado && context.mounted) {
                      Navigator.pushNamed(context, '/home_funcionario');
                    }
                  },
                ),
                
                const SizedBox(height: 40),
                
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const CadastroPatraoPage())
                    ),
                    style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
                    child: RichText(
                      text: TextSpan(
                        text: "New here? ",
                        style: TextStyle(color: subTextColor, fontSize: 13),
                        children: [
                          TextSpan(
                            text: "Register your restaurant.",
                            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Nexxo Systems Management © 2026",
                    style: TextStyle(color: subTextColor.withOpacity(0.4), fontSize: 11, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPortalButton({
    required String label,
    required IconData icon,
    required Color accentColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: accentColor.withOpacity(0.06),
          highlightColor: accentColor.withOpacity(0.02),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: accentColor.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.15), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}