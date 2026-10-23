import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'firebase_options.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports das páginas organizadas
import 'package:app_estoque/auth/login_page.dart';
import 'package:app_estoque/funcionario/home_funcionario.dart';
import 'package:app_estoque/gerente/dashboard_gerente_page.dart';
import 'package:app_estoque/gerente/gerente_aprovacao_page.dart';
import 'package:app_estoque/patrao/dashboard_patrao_page.dart';

// CONTROLADOR GLOBAL: Avisa o aplicativo inteiro instantaneamente quando o tema muda
final ValueNotifier<ThemeMode> temaGlobal = ValueNotifier(ThemeMode.dark);

void main() async {
  // 1. Garante a inicialização dos bindings nativos antes de códigos assíncronos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializa o Hive no diretório local nativo do dispositivo
  await Hive.initFlutter();
  
  // 3. Abre a caixa de persistência para cache local offline do estoque
  await Hive.openBox('estoque_cache');
  
  // 4. Inicializa o Firebase com as opções multiplataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // 🟢 MUDANÇA AQUI: ProviderScope adicionado
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verde Cirúrgico de Alta Precisão - Assinatura Nexo Obsidian
    const Color nexoAccent = Color(0xFF00E676);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaGlobal,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Vila Gourmet',
          debugShowCheckedModeBanner: false,
          
          // ----------------------------------------------------
          // ☀️ DESIGN CLARO (NEXO OBSIDIAN - HIGH CONTRAST LIGHT)
          // ----------------------------------------------------
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF9F9FB), // Fundo sólido limpo
            primaryColor: nexoAccent,
            cardColor: Colors.white,
            dividerColor: const Color(0xFF111111).withOpacity(0.05),
            hintColor: const Color(0xFF111111).withOpacity(0.4),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF111111).withOpacity(0.54)),
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
          
          // ----------------------------------------------------
          // 🌙 DESIGN ESCURO (NEXO OBSIDIAN - ABSOLUTE DARK)
          // ----------------------------------------------------
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0A0B), // Fundo sólido absoluto contra "fantasmas"
            primaryColor: nexoAccent,
            cardColor: const Color(0xFF121214),
            dividerColor: Colors.white.withOpacity(0.05),
            hintColor: Colors.white.withOpacity(0.4),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white.withOpacity(0.4)),
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

          // 🛠️ WRAPPER GLOBAL INTERCEPTADOR
          builder: (context, child) {
            return GestureDetector(
              // Fecha o teclado de forma inteligente ao clicar em qualquer ponto cego fora de inputs
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child!,
            );
          },

          // 🚀 MAPA DE ROTAS NOMEADAS
          routes: {
            '/login': (context) => const LoginPage(),
            '/home_patrao': (context) => const DashboardPatrao(),
            '/home_gerente': (context) => const GerenteAprovacaoPage(),
            '/home_funcionario': (context) => const HomeFuncionario(podeVerHistorico: false),
          },
        );
      },
    );
  }
}