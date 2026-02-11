import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';

typedef NativeEnX9 = Uint64 Function(Uint64 seed);
typedef DartEnX9 = int Function(int seed);

typedef NativeToStringPad = Void Function(Uint64 n, Int32 width, Pointer<Utf8> out);
typedef NativeExpandir = Void Function(Pointer<Utf8> base, Int32 alvo, Pointer<Utf8> out);

class EnXSecurity {
  static final DynamicLibrary _lib = Platform.isAndroid
      ? DynamicLibrary.open('libenx_security.so')
      : DynamicLibrary.process();

  static final DartEnX9 _enx9 = _lib
      .lookup<NativeFunction<NativeEnX9>>('EnX9')
      .asFunction();

  static String solveTicketNative(String idInasx, int seed) {
    try {
      BigInt idVal = BigInt.parse(idInasx).toUnsigned(64);
      BigInt seedVal = BigInt.from(seed).toUnsigned(64);
      
      // Realiza o XOR idêntico ao que o servidor espera
      int argument = (idVal ^ seedVal).toUnsigned(64).toInt();
      
      // Chama o EnX9 dentro do binário .so
      int result = _enx9(argument);
      
      // Retorna o hash formatado (12 dígitos como no started.dart original)
      return result.toString().padLeft(12, '0');
    } catch (e) {
      return "000000000000";
    }
  }

  static String expandirCaminho(String base, int alvo) {
    final nativeExpandir = _lib
        .lookup<NativeFunction<NativeExpandir>>('expandir_native')
        .asFunction<void Function(Pointer<Utf8>, int, Pointer<Utf8>)>();

    final Pointer<Utf8> basePtr = base.toNativeUtf8();
    final Pointer<Utf8> outPtr = calloc<Uint8>(alvo + 1).cast<Utf8>();

    try {
      nativeExpandir(basePtr, alvo, outPtr);
      return outPtr.toDartString();
    } finally {
      malloc.free(basePtr);
      malloc.free(outPtr);
    }
  }
}
