import 'dart:math';

class EnXLow {
  // Uso de BigInt em todos os níveis para evitar overflow e garantir paridade com C++
  static BigInt enx1(BigInt seed) => 
      (seed * BigInt.from(137) + BigInt.from(11)) % BigInt.from(1000);

  static BigInt enx3(BigInt seed) => 
      (enx1(seed) * BigInt.from(827) + BigInt.from(97)) % BigInt.from(1000000);

  static BigInt enx6(BigInt seed) => 
      (enx3(seed) * BigInt.from(1000003) + BigInt.from(7)) % BigInt.from(1000000000);

  static BigInt enx9(BigInt seed) {
    BigInt s6 = enx6(seed);
    BigInt multiplier = BigInt.from(1234567);
    BigInt divisor = BigInt.from(1000000000000);
    return (s6 * multiplier + BigInt.one) % divisor;
  }
}

class EnX18 {
  static String generate(BigInt seed) {
    String raw = EnXLow.enx9(seed).toString();
    return EnXBase.expandir(raw, 36);
  }
}

class EnXBase {
  // Função para garantir o preenchimento de zeros à esquerda (to_string_pad)
  static String toStringPad(BigInt n, int width) {
    return n.toString().padLeft(width, '0');
  }

  static String expandir(String base, int alvo) {
    String res = base;
    while (res.length < alvo) {
      BigInt n = BigInt.zero;
      for (int i = 0; i < res.length; i++) {
        n += BigInt.from(res.codeUnitAt(i) * 31);
      }
      
      // Multiplicação idêntica ao EnX OS: n * (res.length + 1)
      BigInt calc = n * BigInt.from(res.length + 1);
      String pad = toStringPad(calc, 3);
      
      // Pega apenas os últimos 3 caracteres conforme a lógica original
      res += pad.substring(pad.length - 3);
    }
    return res.substring(res.length - alvo);
  }
}
