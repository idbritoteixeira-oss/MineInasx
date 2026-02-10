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

  // Canal necessário para o Android reconhecer o serviço
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'enx_mining_channel', 
    'INASX MINER SERVICE',
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
      initialNotificationTitle: 'ENX OS',
      initialNotificationContent: 'Iniciando sistema...',
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
  
  // O onStart agora é apenas um container vazio para manter o serviço rodando.
  // Toda a lógica de notificação foi movida para o started.dart
  
  service.on('stopService').listen((event) {
    service.stopSelf();
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
