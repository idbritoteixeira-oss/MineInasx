import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';

typedef NativeEnX9 = Uint64 Function(Uint64 seed);
typedef DartEnX9 = int Function(int seed);

typedef NativeExpandir = Void Function(Pointer<Utf8> base, Int32 alvo, Pointer<Utf8> out);
typedef DartExpandir = void Function(Pointer<Utf8> base, int alvo, Pointer<Utf8> out);

class EnXSecurity {
  static final DynamicLibrary _lib = Platform.isAndroid
      ? DynamicLibrary.open('libenx_security.so')
      : DynamicLibrary.process();

  static final DartEnX9 _enx9 = _lib
      .lookup<NativeFunction<NativeEnX9>>('solve_inasx_ticket')
      .asFunction();

  static String solveTicketNative(String idInasx, int seed) {
    try {
      // Usamos BigInt para evitar qualquer perda de precisão com IDs gigantes
      final BigInt idVal = BigInt.parse(idInasx);
      final BigInt seedVal = BigInt.from(seed);
      
      // Realiza o XOR e força o resultado a caber em 64 bits (máscara 0xFFFFFFFFFFFFFFFF)
      // Isso garante que o valor seja idêntico ao uint64_t do servidor e do C++
      final BigInt xorResult = (idVal ^ seedVal).toUnsigned(64);
      
      // Converte para o padrão de bits de 64 bits que o C++ espera
      final int argument = xorResult.toSigned(64).toInt();
      
      // Chama o motor nativo EnX9
      final int result = _enx9(argument);
      
      // Retorna com os 12 dígitos cravados
      return result.toString().padLeft(12, '0');
    } catch (e) {
      return "000000000000";
    }
  }

  static String expandirCaminho(String base, int alvo) {
    final DartExpandir nativeExpandir = _lib
        .lookup<NativeFunction<NativeExpandir>>('expandir_native')
        .asFunction();

    final Pointer<Utf8> basePtr = base.toNativeUtf8();
    final Pointer<Utf8> outPtr = calloc<Uint8>(alvo + 1).cast<Utf8>();

    try {
      nativeExpandir(basePtr, alvo, outPtr);
      return outPtr.toDartString();
    } catch (e) {
      return base;
    } finally {
      malloc.free(basePtr);
      malloc.free(outPtr);
    }
  }
}
