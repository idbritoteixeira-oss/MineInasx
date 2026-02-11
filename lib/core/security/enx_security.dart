import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';

typedef NativeEnX9 = Uint64 Function(Uint64 seed);
typedef DartEnX9 = int Function(int seed);

// Definição para a função de expansão de strings (Dwellers/Caminhos)
typedef NativeExpandir = Void Function(Pointer<Utf8> base, Int32 alvo, Pointer<Utf8> out);
typedef DartExpandir = void Function(Pointer<Utf8> base, int alvo, Pointer<Utf8> out);

class EnXSecurity {
  static final DynamicLibrary _lib = Platform.isAndroid
      ? DynamicLibrary.open('libenx_security.so')
      : DynamicLibrary.process();

  // Mapeia para o nome unificado no C++: solve_inasx_ticket
  static final DartEnX9 _enx9 = _lib
      .lookup<NativeFunction<NativeEnX9>>('solve_inasx_ticket')
      .asFunction();

  static String solveTicketNative(String idInasx, int seed) {
    try {
      BigInt idVal = BigInt.parse(idInasx).toUnsigned(64);
      BigInt seedVal = BigInt.from(seed).toUnsigned(64);
      
      // Realiza o XOR de 64 bits para o argumento
      int argument = (idVal ^ seedVal).toUnsigned(64).toInt();
      
      // Executa o EnX9 nativo
      int result = _enx9(argument);
      
      // Retorna com padding de 12 (Padrão Inasx PoP)
      return result.toString().padLeft(12, '0');
    } catch (e) {
      return "000000000000";
    }
  }

  /// Expande caminhos de banco de dados (Dwellers/Nation/Market)
  static String expandirCaminho(String base, int alvo) {
    final DartExpandir nativeExpandir = _lib
        .lookup<NativeFunction<NativeExpandir>>('expandir_native')
        .asFunction();

    final Pointer<Utf8> basePtr = base.toNativeUtf8();
    // Aloca buffer para a string de saída + null terminator
    final Pointer<Utf8> outPtr = calloc<Uint8>(alvo + 1).cast<Utf8>();

    try {
      nativeExpandir(basePtr, alvo, outPtr);
      return outPtr.toDartString();
    } catch (e) {
      return base; // Fallback para a base em caso de erro
    } finally {
      // Limpeza de memória obrigatória para não vazar RAM no Motorola
      malloc.free(basePtr);
      malloc.free(outPtr);
    }
  }
}
