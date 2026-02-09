import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:system_info2/system_info2.dart';

// NOVOS IMPORTS DE SEGURANÇA (Substituindo cryptography.dart)
import '../../core/security/enx1_9.dart';
import '../../core/security/enx_base.dart';
import '../../core/network/inasx_network.dart';

class InasxStarted extends StatefulWidget {
  final String idInasx;
  const InasxStarted({super.key, required this.idInasx});

  @override
  State<InasxStarted> createState() => _InasxStartedState();
}

class _InasxStartedState extends State<InasxStarted> {
  // Controle de Interface
  List<String> logs = [];
  final ScrollController _scrollController = ScrollController();
  
  // Hardware
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  Timer? _ramTimer;
  StreamSubscription? _batterySubscription;
  
  // Rede
  final InasxNetwork _network = InasxNetwork(
    serverUrl: 'https://8b48ce67-8062-40e3-be2d-c28fd3ae4f01-00-117turwazmdmc.janeway.replit.dev'
  );

  // Estado da Mineração
  double ramUsage = 0.0;
  int batteryLevel = 100;
  String currentNonce = "0"; // Hash limpo, sem 0x
  double sessionInx = 0.0000;
  int blocksValidated = 0;
  String deviceName = "Detectando...";

  @override
  void initState() {
    super.initState();
    _initSystem();
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    _ramTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _initSystem() async {
    // 1. Hardware Info
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await deviceInfo.androidInfo;
        deviceName = "${info.manufacturer} ${info.model}";
      } else {
        deviceName = "EnX Desktop Node";
      }
    } catch (_) { deviceName = "Unknown Worker"; }

    // 2. RAM Monitor (Real Hardware)
    _ramTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        try {
          int total = SysInfo.getTotalPhysicalMemory();
          int free = SysInfo.getFreePhysicalMemory();
          setState(() => ramUsage = (total - free) / total);
        } catch (_) { 
          setState(() => ramUsage = 0.12); // Fallback seguro
        }
      }
    });

    // 3. Battery Monitor
    _batterySubscription = _battery.onBatteryStateChanged.listen((_) async {
      int level = await _battery.batteryLevel;
      if (mounted) setState(() => batteryLevel = level);
    });

    if (mounted) setState(() {});
    
    // Inicia o Loop de Mineração
    _workerLoop();
  }

  void _addLog(String text) {
    if (!mounted) return;
    setState(() {
      logs.add("> $text");
      if (logs.length > 40) logs.removeAt(0);
    });
    // Auto-scroll suave
    Timer(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // --- LÓGICA ESPELHADA DO WORKER.CPP ---
  void _workerLoop() async {
    await Future.delayed(const Duration(seconds: 1)); // Boot delay
    
    _addLog("--- [EnX OS PoP Worker] ---");
    _addLog("[INFO] ID: ${widget.idInasx}");
    _addLog("[STATUS] Iniciando participação...");

    while (mounted) {
      // 1. Sincroniza com ciclo de 180s (uint64_t cycle_seed = time / 180)
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int cycleSeed = timestamp ~/ 180;

      _addLog("Iniciando Ciclo: $cycleSeed");

      // 2. Gera a Prova (Action Hash)
      // std::stoull(my_id) ^ cycle_seed
      
      // PARIDADE C++: Converter string ID para BigInt Unsigned 64-bit
      BigInt idVal = BigInt.parse(widget.idInasx).toUnsigned(64);
      BigInt seedVal = BigInt.from(cycleSeed).toUnsigned(64);

      // XOR Operation (uint64_t ^ uint64_t)
      BigInt argument = (idVal ^ seedVal).toUnsigned(64);

      // uint64_t action_raw = EnX_Low::EnX9(...)
      BigInt actionRaw = EnX_Low.EnX9(argument);

      // std::string action_hash = EnXBase::to_string_pad(...)
      String actionHash = EnXBase.to_string_pad(actionRaw, 12);

      // Atualiza UI sem adicionar "0x" (Worker C++ não usa 0x na visualização padrão)
      setState(() => currentNonce = actionHash);

      // 3. Envio (Socket simulation via HTTP)
      _addLog("Quest: $actionHash");
      
      // Envia exatamente o que o C++ envia: ID, HASH, SEED
      String response = await _network.sendSubmitPop(widget.idInasx, actionHash, cycleSeed);

      if (response.contains("POP_OK")) {
        // Extrai recompensa se disponível no formato POP_OK|0.09
        double reward = 0.09;
        try {
           var parts = response.split('|');
           if (parts.length > 1) reward = double.parse(parts[1]);
        } catch (_) {}

        setState(() {
          blocksValidated++;
          sessionInx += reward;
        });
        _addLog("[SISTEMA] Recompensado");
      } else {
        _addLog("Resposta: $response");
      }

      // 4. Sleep(180) - Aguarda o próximo ciclo
      // O Worker C++ dorme 180s fixos após a tentativa.
      _addLog("Aguardando proximo ciclo (180s)...");
      await Future.delayed(const Duration(seconds: 180));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mantendo o layout Dark/Hacker original
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Hardware
              Text("[ $deviceName ]", style: const TextStyle(color: Color(0xFF64FFDA), fontFamily: 'Courier', fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24),
              
              const SizedBox(height: 5),
              _buildBar("RAM ", ramUsage),
              _buildBar("BAT ", batteryLevel / 100.0),

              const SizedBox(height: 20),
              
              // Stats Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1D2A4E)),
                  color: const Color(0xFF0A192F)
                ),
                child: Column(
                  children: [
                    _row("INX OBTIDOS:", sessionInx.toStringAsFixed(4)),
                    const SizedBox(height: 5),
                    _row("PARTICIPAÇÕES:", blocksValidated.toString()),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Console Logs
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white10)
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: logs.length,
                    itemBuilder: (c, i) => Text(logs[i], style: const TextStyle(color: Colors.green, fontFamily: 'Courier', fontSize: 11)),
                  ),
                ),
              ),

              // Footer Hash
              const SizedBox(height: 10),
              Text(
                "ID_ACTIVE: ${widget.idInasx} | HASH: $currentNonce",
                style: const TextStyle(color: Colors.white30, fontFamily: 'Courier', fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, double pct) {
    int slots = (pct * 20).toInt().clamp(0, 20);
    String bar = "|" * slots;
    return Text("$bar $label", style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 10));
  }

  Widget _row(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Color(0xFF64FFDA), fontFamily: 'Courier', fontSize: 11)),
        Text(v, style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
