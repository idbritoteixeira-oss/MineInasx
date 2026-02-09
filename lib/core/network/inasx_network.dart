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
      // Ajustado para garantir 5 segmentos (CMD|ID|E1|E2|E3)
      // LOGIN | ID | CHECK_EXISTENCE | empty | empty
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {'packet': "LOGIN|$id|CHECK_EXISTENCE|||"},
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
      // Ajustado para garantir 5 segmentos (CMD|ID|E1|E2|E3)
      // SUBMIT_POP | ID | HASH | SEED | empty
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {'packet': "SUBMIT_POP|$id|$actionHash|$seed||"},
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
