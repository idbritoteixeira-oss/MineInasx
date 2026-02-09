import 'package:http/http.dart' as http;
import 'dart:async';

class InasxNetwork {
  final String serverUrl;

  InasxNetwork({
    this.serverUrl = 'https://8b48ce67-8062-40e3-be2d-c28fd3ae4f01-00-117turwazmdmc.janeway.replit.dev',
  });

  /// VALIDAÇÃO PARA initiation.dart (Varredura de Uron)
  Future<String> verificarExistenciaId(String id) async {
    try {
      // Enviamos o placeholder CHECK_EXISTENCE no campo da senha
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {'packet': "LOGIN|$id|CHECK_EXISTENCE||"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.body.trim();
      }
      return "ERR_NET";
    } catch (e) {
      return "OFFLINE";
    }
  }

  /// LÓGICA DE MINERAÇÃO (Para started.dart - Ciclo PoP)
  Future<String> sendSubmitPop(String id, String actionHash, int seed) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {'packet': "SUBMIT_POP|$id|$actionHash|$seed|"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return response.body.trim();
      }
      return "ERR_NET";
    } catch (e) {
      return "OFFLINE";
    }
  }
}
