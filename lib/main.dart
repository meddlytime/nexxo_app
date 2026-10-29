import 'package:flutter/material.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexxo/auth/login_page.dart';
import 'package:nexxo/staff/staff_home_page.dart';
import 'package:nexxo/owner/owner_dashboard_page.dart';
import 'package:nexxo/manager/manager_dashboard_page.dart';


final ValueNotifier<ThemeMode> temaGlobal = ValueNotifier(ThemeMode.dark);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    const Color nexoAccent = Color(0xFF00E676);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaGlobal,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Nexxo',
          debugShowCheckedModeBanner: false,
          
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF9F9FB), 
            primaryColor: nexoAccent,
            cardColor: Colors.white,
            dividerColor: const Color(0xFF111111).withValues(alpha: 0.05),
            hintColor: const Color(0xFF111111).withValues(alpha: 0.4),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF111111).withValues(alpha: 0.54)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: nexoAccent,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0A0B), // Fundo sólido absoluto contra "fantasmas"
            primaryColor: nexoAccent,
            cardColor: const Color(0xFF121214),
            dividerColor: Colors.white.withValues(alpha: 0.05),
            hintColor: Colors.white.withValues(alpha: 0.4),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white.withValues(alpha: 0.4)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: nexoAccent,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          
          themeMode: mode,
          home: const LoginPage(), 

          builder: (context, child) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child!,
            );
          },

          routes: {
            '/login': (context) => const LoginPage(),
            '/home_patrao': (context) => const DashboardPatrao(),
            '/home_gerente': (context) => const HomeGerente(),
            '/home_funcionario': (context) => const HomeFuncionario(podeVerHistorico: false),
          },
        );
      },
    );
  }
}