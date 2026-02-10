import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Importações ajustadas para a nova estrutura de pastas
import '../core/network/inasx_network.dart';

class InasxInitiation extends StatefulWidget {
  const InasxInitiation({super.key});

  @override
  State<InasxInitiation> createState() => _InasxInitiationState();
}

class _InasxInitiationState extends State<InasxInitiation> {
  final TextEditingController _idController = TextEditingController();
  bool _isValidating = false;
  bool _rememberId = true; // Estado do Checkbox
  String _statusText = "Waiting for network connection...";

  @override
  void initState() {
    super.initState();
    _loadSavedId(); // Carrega o ID ao iniciar
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // Carrega o ID salvo no armazenamento local
  Future<void> _loadSavedId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('saved_id_inasx');
    if (savedId != null && savedId.isNotEmpty) {
      setState(() {
        _idController.text = savedId;
      });
    }
  }

  // Salva ou remove o ID do armazenamento local
  Future<void> _handleSaveId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberId) {
      await prefs.setString('saved_id_inasx', id);
    } else {
      await prefs.remove('saved_id_inasx');
    }
  }

  Future<void> _startMiningProtocol() async {
    final String id = _idController.text.trim();
    final network = InasxNetwork();
    
    setState(() {
      _isValidating = true;
      _statusText = "SEARCHING IN $id";
    });

    String response = await network.verificarExistenciaId(id);

    if (response.startsWith("LOGIN_OK")) {
      // Salva o ID antes de navegar se a opção estiver marcada
      await _handleSaveId(id);

      setState(() => _statusText = "ID VALIDATED. DOWNLOADING ENX CONTAINER...");
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() => _statusText = "ENX SYNCHRONIZED CONTAINERS.");
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushNamed(context, '/started', arguments: id);
      
    } else {
      setState(() {
        _isValidating = false;
        if (response == "OFFLINE") {
          _statusText = "ERROR: CENTRAL SERVER DOWN.";
          _showError("Connection to the EnX server failed.");
        } else if (response == "ID_NOT_FOUND") {
          _statusText = "ERROR: ID NOT FOUND.";
          _showError("Access Denied: ID does not exist.");
        } else {
          _statusText = "ERROR: UNEXPECTED RESPONSE.";
          _showError("Validation failed: $response");
        }
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        backgroundColor: const Color(0xFFE53935),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817), 
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A192F), Color(0xFF020817)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView( 
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.lan, size: 80, color: Color(0xFF64FFDA)),
                ),
                const SizedBox(height: 40),
                
                Text(
                  "Miner Identification",
                  style: TextStyle(
                    color: const Color(0xFF64FFDA).withOpacity(0.7),
                    fontSize: 10,
                    fontFamily: 'monospace',
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                TextField(
                  controller: _idController,
                  enabled: !_isValidating,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: "ENTER YOUR ID_INASX",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontFamily: 'monospace'),
                    filled: true,
                    fillColor: const Color(0xFF1D2A4E).withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1D2A4E)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF64FFDA), width: 0.5),
                    ),
                  ),
                ),
                
                // CAMPO "LEMBRAR ID"
                Row(
                  children: [
                    Theme(
                      data: ThemeData(unselectedWidgetColor: const Color(0xFF1D2A4E)),
                      child: Checkbox(
                        value: _rememberId,
                        activeColor: const Color(0xFF64FFDA),
                        checkColor: Colors.black,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberId = value ?? false;
                          });
                        },
                      ),
                    ),
                    const Text(
                      "REMEMBER ID",
                      style: TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isValidating ? null : () {
                      if (_idController.text.isNotEmpty) {
                        _startMiningProtocol();
                      } else {
                        _showError("ID required for mining.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64FFDA).withOpacity(0.1),
                      foregroundColor: const Color(0xFF64FFDA),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                        side: const BorderSide(color: Color(0xFF64FFDA), width: 0.5),
                      ),
                    ),
                    child: _isValidating 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF64FFDA)))
                      : const Text("START MINING", style: TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),

                const SizedBox(height: 80), 
                
                Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isValidating ? const Color(0xFF64FFDA) : Colors.white.withOpacity(0.1),
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
