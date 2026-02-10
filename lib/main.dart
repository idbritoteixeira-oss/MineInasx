import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Importando as telas
import 'screens/splashscreen.dart';
import 'screens/initiation.dart';
import 'screens/started.dart';

// Instância global para evitar erros de inicialização no background
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeService();
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MineInasxApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'enx_mining_channel', 
    'INASX MINER SERVICE',
    description: 'WORKING',
    importance: Importance.low, 
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'enx_mining_channel',
      initialNotificationTitle: 'MINER INASX',
      initialNotificationContent: 'Waiting...',
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
  
  // Variáveis de estado da sessão
  String currentSeed = "0";
  String sessionBalance = "0.0000";
  bool isMiningActive = false; // NOVA TRAVA: Começa desativado

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Listener para capturar os dados vindos da interface
  service.on('updateData').listen((event) {
    if (event != null) {
      currentSeed = event['seed'] ?? "0";
      sessionBalance = event['balance'] ?? "0.0000";
      isMiningActive = true; // ATIVAÇÃO: Só vira true quando o started.dart enviar dados
    }
  });

  // Loop de atualização da notificação via Local Notifications
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      // SÓ EXIBE A NOTIFICAÇÃO SE A MINERAÇÃO TIVER SIDO INICIADA
      if (isMiningActive && await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'EARNINGS: $sessionBalance INX',
          'TICKET: $currentSeed',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'enx_mining_channel',
              'ENX MINING SERVICE',
              icon: 'front_loader', 
              ongoing: true,
              importance: Importance.low,
              priority: Priority.low,
              showWhen: false,
            ),
          ),
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
    );
  }
}
