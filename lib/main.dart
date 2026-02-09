import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Importando as telas conforme a nova hierarquia de pastas
import 'screens/splashscreen.dart';
import 'screens/initiation.dart';
import 'screens/started.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuração de orientação e estilo de sistema
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MineInasxApp());
}

class MineInasxApp extends StatelessWidget {
  const MineInasxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mine Inasx',
      debugShowCheckedModeBanner: false,
      
      // Tema Centralizado Oceanic Core do EnX OS
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF64FFDA),
        scaffoldBackgroundColor: const Color(0xFF020817),
        fontFamily: 'Courier', 
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        dividerColor: const Color(0xFF1D2A4E),
      ),

      // Sistema de Rotas Nomeadas para Navegação Fluida
      initialRoute: '/',
      routes: {
        '/': (context) => const EnXSplashScreen(),
        '/initiation': (context) => const InasxInitiation(),
      },
      
      // Tratamento dinâmico para rotas que levam argumentos (como o ID do minerador)
      onGenerateRoute: (settings) {
        if (settings.name == '/started') {
          final args = settings.arguments as String? ?? "ID_PENDING";
          return MaterialPageRoute(
            builder: (context) => InasxStarted(idInasx: args),
          );
        }
        return null;
      },
      
      // Rota de fallback caso algo falhe no multiverso de pastas
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const EnXSplashScreen(),
      ),
    );
  }
}
