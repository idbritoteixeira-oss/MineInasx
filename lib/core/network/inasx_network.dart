import 'package:http/http.dart' as http;
import 'dart:async';

class InasxNetwork {
  final String serverUrl;

  InasxNetwork({
    this.serverUrl = 'https://8b48ce67-8062-40e3-be2d-c28fd3ae4f01-00-117turwazmdmc.janeway.replit.dev',
  });

  Future<String> verificarExistenciaId(String id) async {
    try {
      String packet = "LOGIN|$id|CHECK_EXISTENCE|0|0"; 

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "text/plain"},
        body: packet, 
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.body.trim();
      }
      return "ERR_NET";
    } catch (e) {
      return "OFFLINE";
    }
  }

  Future<String> sendSubmitPop(String id, String actionHash, int seed) async {
    try {
      String packet = "SUBMIT_POP|$id|$actionHash|$seed|0";

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "text/plain"},
        body: packet,
      ).timeout(const Duration(seconds: 8)); 

      if (response.statusCode == 200) {
        return response.body.trim();
      }
      return "ERR_NET";
    } catch (e) {
      return "OFFLINE";
    }
  }
}
