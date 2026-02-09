import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class InasxNetwork {
  // Remova a barra final da URL para evitar erro de concatenação
  final String serverUrl;

  InasxNetwork({
    this.serverUrl = 'https://8b48ce67-8062-40e3-be2d-c28fd3ae4f01-00-117turwazmdmc.janeway.replit.dev',
  });

  /// VALIDAÇÃO PARA initiation.dart
  Future<String> verificarExistenciaId(String id) async {
    try {
      // O Replit/SInasxServer via HTTP geralmente recebe via POST ou Query Params
      // Vou simular o envio do seu pacote LOGIN via Body
      final response = await http.post(
        Uri.parse('$serverUrl/login'),
        body: {'packet': "LOGIN|$id|CHECK_EXISTENCE"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.body.trim();
      }
      return "ERR_NET";
    } catch (e) {
      return "OFFLINE";
    }
  }

  /// LÓGICA DE MINERAÇÃO (Para started.dart)
  Future<String> sendSubmitPop(String id, String actionHash, int seed) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/submit'),
        body: {'packet': "SUBMIT_POP|$id|$actionHash|$seed"},
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
