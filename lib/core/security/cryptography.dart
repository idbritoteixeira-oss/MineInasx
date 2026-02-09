import 'dart:math';

class EnXLow {
  // Lógica (seed * 137 + 11) % 1000
  static int enx1(int seed) => (seed * 137 + 11) % 1000;

  // Lógica (EnX1 * 827 + 97) % 1000000
  static int enx3(int seed) => (enx1(seed) * 827 + 97) % 1000000;

  // Lógica (EnX3 * 1000003 + 7) % 1000000000
  static int enx6(int seed) => (enx3(seed) * 1000003 + 7) % 1000000000;

  // Lógica EnX9 usando BigInt para evitar overflow do __int128
  static BigInt enx9(int seed) {
    BigInt s6 = BigInt.from(enx6(seed));
    BigInt multiplier = BigInt.from(1234567);
    BigInt divisor = BigInt.from(1000000000000);
    return (s6 * multiplier + BigInt.one) % divisor;
  }
}

class EnX18 {
  static String generate(int seed) {
    String raw = EnXLow.enx9(seed).toString();
    return EnXBase.expandir(raw, 36);
  }
}

class EnXBase {
  static String expandir(String base, int alvo) {
    String res = base;
    while (res.length < alvo) {
      BigInt n = BigInt.zero;
      for (int i = 0; i < res.length; i++) {
        n += BigInt.from(res.codeUnitAt(i) * 31);
      }
      // Simula o to_string_pad(n * (len + 1), 3)
      String pad = (n * BigInt.from(res.length + 1)).toString();
      res += pad.padLeft(3, '0').substring(max(0, pad.length - 3));
    }
    return res.substring(res.length - alvo);
  }
}
