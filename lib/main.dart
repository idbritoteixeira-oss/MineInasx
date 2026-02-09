import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Importando as telas conforme a nova hierarquia de pastas
import 'screens/splashscreen.dart';
import 'screens/initiation.dart';
import 'screens/started.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o motor de segundo plano do EnX OS
  await initializeService();
  
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

// Configuração do Background Service para o Miner Inasx
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'enx_mining_channel', 
    'ENX MINING SERVICE',
    description: 'Este canal mantém a mineração PoP ativa.',
    importance: Importance.low, 
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'enx_mining_channel',
      initialNotificationTitle: 'ENX OS WORKER',
      initialNotificationContent: 'Sincronizando com a rede...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Loop de atualização da notificação - Corrigido para a nova API
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Correção aplicada aqui para eliminar o erro do "isn't defined"
        service.setForegroundNotificationInfo(
          title: "ENX OS - MINER ATIVO",
          content: "Ciclo PoP em execução...",
        );
      }
    }
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) => true;

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
        fontFamily: 'monospace', 
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontFamily: 'monospace'),
        ),
        dividerColor: const Color(0xFF1D2A4E),
      ),

      // Sistema de Rotas Nomeadas
      initialRoute: '/',
      routes: {
        '/': (context) => const EnXSplashScreen(),
        '/initiation': (context) => const InasxInitiation(),
      },
      
      onGenerateRoute: (settings) {
        if (settings.name == '/started') {
          final args = settings.arguments as String? ?? "ID_PENDING";
          return MaterialPageRoute(
            builder: (context) => InasxStarted(idInasx: args),
          );
        }
        return null;
      },
      
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const EnXSplashScreen(),
      ),
    );
  }
}
