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
      // CMD|ID|E1|E2|E3 - Formato estrito para stringstream C++
      // Adicionamos um caractere final ou garantimos os pipes para evitar truncamento
      String packet = "LOGIN|$id|CHECK_EXISTENCE|0|0"; 
      
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {'packet': packet},
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
  /// Agora preparado para receber "POP_OK|VALOR" ou "ERR_LOW_BALANCE"
  Future<String> sendSubmitPop(String id, String actionHash, int seed) async {
    try {
      // CMD|ID|E1|E2|E3
      // e1 = hash, e2 = seed, e3 = 0 (padding)
      String packet = "SUBMIT_POP|$id|$actionHash|$seed|0";

      final response = await http.post(
        Uri.parse(serverUrl),
        body: {'packet': packet},
      ).timeout(const Duration(seconds: 8)); // Aumentado para estabilidade em rede móvel

      if (response.statusCode == 200) {
        // Retorna a string bruta: "POP_OK|0.030000", "ERR_LOW_BALANCE", etc.
        return response.body.trim();
      }
      return "ERR_NET";
    } catch (e) {
      return "OFFLINE";
    }
  }
}
