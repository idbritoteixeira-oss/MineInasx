import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io'; 
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';

// Importações oficiais do seu projeto
import '../../core/security/cryptography.dart'; 
import '../../core/network/inasx_network.dart';

class InasxStarted extends StatefulWidget {
  final String idInasx;
  const InasxStarted({super.key, this.idInasx = "10362457985469070687"});

  @override
  State<InasxStarted> createState() => _InasxStartedState();
}

class _InasxStartedState extends State<InasxStarted> {
  List<String> logs = [];
  final ScrollController _scrollController = ScrollController();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  
  final InasxNetwork _network = InasxNetwork(
    serverUrl: 'https://8b48ce67-8062-40e3-be2d-c28fd3ae4f01-00-117turwazmdmc.janeway.replit.dev'
  );
  
  double ramUsage = 0.12; 
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
      Timer(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.position.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  // LÓGICA IDENTICA AO SCRIPTWORKER.CPP
  void _startMiningProtocol() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addLog("--- [EnX OS PoP Worker] ---");
    _addLog("[INFO] ID: ${widget.idInasx}");
    _addLog("[STATUS] Iniciando participação...");
    
    while (mounted) {
      // 1. Sincroniza com o ciclo (time / 180) - Paridade absoluta com C++
      int cycleSeed = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ 180;
      
      _addLog("Iniciando Ciclo: $cycleSeed");
      
      // 2. Gera a Prova (Action Hash) usando EnX9
      BigInt idBig = BigInt.parse(widget.idInasx);
      BigInt seedBig = BigInt.from(cycleSeed);
      
      // XOR e Hash idêntico ao script
      BigInt actionRaw = EnXLow.enx9(idBig ^ seedBig);
      String actionHash = EnXBase.toStringPad(actionRaw, 12);
      
      setState(() {
        currentNonce = "0x${actionHash.toUpperCase()}";
        ramUsage = 0.65 + (Random().nextDouble() * 0.1); // Simula carga
      });

      // 3. Envio e Espera de Resposta
      _addLog("Quest: $actionHash");
      String response = await _network.sendSubmitPop(widget.idInasx, actionHash, cycleSeed);
      
      if (response.contains("POP_OK")) {
        double reward = 0.0;
        try {
          List<String> parts = response.split('|');
          reward = parts.length > 1 ? double.parse(parts[1]) : 0.09;
        } catch (_) { reward = 0.09; }

        setState(() {
          blocksValidated++;
          sessionInx += reward; 
          ramUsage = 0.12; 
        });
        _addLog("[SISTEMA] Recompensado: +$reward INX");
      } 
      else {
        _addLog("Resposta: $response");
        setState(() => ramUsage = 0.15);
      }

      // 4. Sincronizado com o ciclo: sleep(180)
      _addLog("Aguardando proximo ciclo (180s)...");
      await Future.delayed(const Duration(seconds: 180)); 
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Divider(color: Color(0xFF1D2A4E)),
              
              const Text("PERFORMANCE:", style: TextStyle(color: Color(0xFF64FFDA), fontSize: 10, fontWeight: FontWeight.bold)),
              _buildResourceBar("RAM ", ramUsage),
              _buildResourceBar("BATTERY", batteryLevel / 100), 
              
              const SizedBox(height: 15),
              
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2A4E).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFF1D2A4E)),
                ),
                child: Column(
                  children: [
                    _buildDataRow("INX OBTIDOS:", "${sessionInx.toStringAsFixed(4)}"),
                    const SizedBox(height: 4),
                    _buildDataRow("PARTICIPAÇÕES:", "$blocksValidated"),
                  ],
                ),
              ),

              const SizedBox(height: 15),
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
              
              Text(
                "HASH_PROOF: $currentNonce", 
                style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Courier')
              ),
            ],
          ),
        ),
      ),
    );
  }

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
