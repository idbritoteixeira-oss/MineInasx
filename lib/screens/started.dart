import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io'; 
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';

// Importações atualizadas conforme a nova hierarquia de pastas
import '../../core/security/cryptography.dart'; 
import '../../core/network/inasx_network.dart';

class InasxStarted extends StatefulWidget {
  final String idInasx;
  const InasxStarted({super.key, this.idInasx = "USER_DEFAULT_ID"});

  @override
  State<InasxStarted> createState() => _InasxStartedState();
}

class _InasxStartedState extends State<InasxStarted> {
  List<String> logs = [];
  final ScrollController _scrollController = ScrollController();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  
  // Instância de Rede conectada ao SInasxServer (Ajuste o IP se necessário)
  final InasxNetwork _network = InasxNetwork(serverIp: '127.0.0.1', port: 8080);
  
  double cpuUsage = 0.15; 
  int batteryLevel = 100;
  String currentNonce = "0";
  double sessionInx = 0.0000;
  int blocksValidated = 0;
  String deviceName = "Detectando hardware...";
  StreamSubscription? _batterySubscription;

  @override
  void initState() {
    super.initState();
    _initDeviceAndMining();
    _initBatteryMonitoring();
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _initBatteryMonitoring() {
    _batterySubscription = _battery.onBatteryStateChanged.listen((BatteryState state) async {
      final level = await _battery.batteryLevel;
      if (mounted) setState(() => batteryLevel = level);
    });
  }

  Future<void> _initDeviceAndMining() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = "${androidInfo.manufacturer} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
      } else {
        deviceName = "EnX Desktop Worker";
      }
    } catch (e) {
      deviceName = "Generic EnX Worker";
    }
    if (mounted) setState(() {});
    _startMiningProtocol();
  }

  void _addLog(String text) {
    if (mounted) {
      setState(() {
        logs.add("> $text");
        if (logs.length > 30) logs.removeAt(0);
      });
      // Scroll automático para o final do log
      Timer(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _startMiningProtocol() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addLog("Hardware: $deviceName");
    _addLog("Autenticação: ${widget.idInasx}");
    
    while (mounted) {
      // 1. Sincronia de Ciclo EnX OS (180s)
      int cycleSeed = DateTime.now().millisecondsSinceEpoch ~/ (180 * 1000);
      _addLog("Iniciando Ciclo: $cycleSeed");
      
      // 2. Geração da Prova EnX18 Real (Liberado pelo Initiation)
      _addLog("Gerando ActionHash via EnX1_9...");
      String actionHash = EnX18.generate(cycleSeed);
      
      // Simulação de esforço computacional visual
      for (int i = 0; i < 6; i++) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          setState(() {
            currentNonce = "0x" + actionHash.substring(0, 8).toUpperCase() + Random().nextInt(999).toString();
            cpuUsage = 0.85 + (Random().nextDouble() * 0.1);
          });
        }
      }
      
      // 3. Comunicação TCP Real com o SInasxServer
      _addLog("Transmitindo SUBMIT_POP...");
      String response = await _network.sendSubmitPop(widget.idInasx, actionHash, cycleSeed);
      
      _addLog("Servidor: $response");
      
      if (response == "POP_OK") {
        setState(() {
          blocksValidated++;
          sessionInx += 0.0125; 
          cpuUsage = 0.10; 
        });
        _addLog("Bloco validado com sucesso.");
      } else if (response == "OFFLINE") {
        _addLog("Erro: Servidor Central Offline.");
      } else {
        _addLog("Erro: Prova rejeitada ou Ciclo expirado.");
      }

      _addLog("Aguardando próximo Job...");
      await Future.delayed(const Duration(seconds: 15)); 
    }
  }

  @override
  Widget build(BuildContext context) {
    // Captura o ID vindo da Rota se não houver no construtor
    final String displayId = ModalRoute.of(context)?.settings.arguments as String? ?? widget.idInasx;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "[ $deviceName ]",
                style: const TextStyle(color: Color(0xFF64FFDA), fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                "ID: $displayId | Bateria: $batteryLevel% | ${DateTime.now().toString().substring(11, 19)}",
                style: const TextStyle(color: Colors.white70, fontFamily: 'Courier', fontSize: 10),
              ),
              const Divider(color: Color(0xFF1D2A4E)),
              
              const Text("MONITOR DE RECURSOS:", style: TextStyle(color: Color(0xFF64FFDA), fontSize: 10, fontWeight: FontWeight.bold)),
              _buildResourceBar("CPU", cpuUsage),
              _buildResourceBar("BATT", batteryLevel / 100), 
              
              const SizedBox(height: 15),
              
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2A4E).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFF1D2A4E)),
                ),
                child: Column(
                  children: [
                    _buildDataRow("GANHOS DA SESSÃO:", "${sessionInx.toStringAsFixed(4)} INX"),
                    const SizedBox(height: 4),
                    _buildDataRow("BLOCOS VALIDADOS:", "$blocksValidated"),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              const Text("LOG DE OPERAÇÕES:", style: TextStyle(color: Color(0xFF64FFDA), fontSize: 10, fontWeight: FontWeight.bold)),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A192F).withOpacity(0.3),
                    border: Border.all(color: const Color(0xFF1D2A4E)),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        logs[index],
                        style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "HASH ATUAL: ${currentNonce.length > 18 ? currentNonce.substring(0, 18) : currentNonce}...", 
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Courier')
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets Auxiliares permanecem os mesmos para manter a estética EnX
  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64FFDA), fontSize: 9, fontFamily: 'Courier')),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
      ],
    );
  }

  Widget _buildResourceBar(String label, double percent) {
    int bars = (percent * 20).clamp(0, 20).toInt();
    String barText = "[" + ("|" * bars).padRight(20, " ") + "]";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "$barText $label",
        style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 10),
      ),
    );
  }
}
