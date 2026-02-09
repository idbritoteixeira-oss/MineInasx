import 'dart:io';
import 'dart:async';
import 'dart:convert';

class InasxNetwork {
  final String serverIp;
  final int port;

  InasxNetwork({this.serverIp = '127.0.0.1', this.port = 8080});

  /// VALIDAÇÃO PARA initiation.dart
  /// Envia o comando LOGIN para o servidor central verificar no /urons/
  Future<String> verificarExistenciaId(String id) async {
    try {
      Socket socket = await Socket.connect(serverIp, port, timeout: const Duration(seconds: 5));

      // O SInasxServer espera: LOGIN|id|e1
      // Como na iniciação queremos apenas ver se existe, passamos um placeholder no e1
      String packet = "LOGIN|$id|CHECK_EXISTENCE\n";

      socket.write(packet);

      Completer<String> completer = Completer();
      socket.listen(
        (List<int> data) {
          String response = utf8.decode(data).trim();
          completer.complete(response);
        },
        onError: (error) => completer.complete("ERR_NET"),
        onDone: () => socket.destroy(),
      );

      return await completer.future.timeout(const Duration(seconds: 5));
    } catch (e) {
      return "OFFLINE";
    }
  }

  /// LÓGICA DE MINERAÇÃO (Para started.dart)
  Future<String> sendSubmitPop(String id, String actionHash, int seed) async {
    try {
      Socket socket = await Socket.connect(serverIp, port, timeout: const Duration(seconds: 5));
      String packet = "SUBMIT_POP|$id|$actionHash|$seed\n";
      socket.write(packet);

      Completer<String> completer = Completer();
      socket.listen(
        (List<int> data) {
          String response = utf8.decode(data).trim();
          completer.complete(response);
        },
        onError: (error) => completer.complete("ERR_NET"),
        onDone: () => socket.destroy(),
      );

      return await completer.future.timeout(const Duration(seconds: 3));
    } catch (e) {
      return "OFFLINE";
    }
  }
}
