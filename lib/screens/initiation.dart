import 'package:flutter/material.dart';
import 'dart:async';

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
  String _statusText = "AGUARDANDO CONEXÃO COM A REDE...";

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // Lógica de Prova de Existência conectada ao SInasxServer no Replit
  Future<void> _startMiningProtocol() async {
    final String id = _idController.text.trim();
    
    // ATUALIZAÇÃO: Configuração para o servidor hospedado no Replit
    // Não utilizamos porta 8080 aqui pois o Replit gerencia o tráfego via HTTPS (443)
    final network = InasxNetwork(
      serverUrl: 'https://8b48ce67-8062-40e3-be2d-c28fd3ae4f01-00-117turwazmdmc.janeway.replit.dev'
    );
    
    setState(() {
      _isValidating = true;
      _statusText = "PESQUISANDO EM /URONS/$id.NAS...";
    });

    // Chamada ao Servidor Central via protocolo HTTP/HTTPS
    String response = await network.verificarExistenciaId(id);

    if (response.startsWith("LOGIN_OK")) {
      setState(() => _statusText = "ID VALIDADO. BAIXANDO CONTÊINER ENX...");
      
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() => _statusText = "CONTÊINER ENX SINCRONIZADOS.");
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushNamed(context, '/started', arguments: id);
      
    } else {
      setState(() {
        _isValidating = false;
        if (response == "OFFLINE") {
          _statusText = "ERRO: SERVIDOR CENTRAL FORA DE LINHA.";
          _showError("Falha na conexão com o servidor EnX.");
        } else {
          _statusText = "ERRO: ID NÃO LOCALIZADO NO MULTIVERSO.";
          _showError("Acesso Negado: Uron inexistente.");
        }
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Courier', fontSize: 12)),
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
                ),
                const SizedBox(height: 40),
                
                Text(
                  "IDENTIFICAÇÃO DE MINERADOR",
                  style: TextStyle(
                    color: const Color(0xFF64FFDA).withOpacity(0.7),
                    fontSize: 10,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                TextField(
                  controller: _idController,
                  enabled: !_isValidating,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Courier'),
                  decoration: InputDecoration(
                    hintText: "INSIRA SEU ID_INASX",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
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
                
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isValidating ? null : () {
                      if (_idController.text.isNotEmpty) {
                        _startMiningProtocol();
                      } else {
                        _showError("ID necessário para minerar");
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
                      : const Text("INICIAR PROCESSO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),

                const SizedBox(height: 100), 
                
                Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isValidating ? const Color(0xFF64FFDA) : Colors.white.withOpacity(0.1),
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontFamily: 'Courier',
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
