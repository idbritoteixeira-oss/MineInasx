import 'dart:math';

class EnX_Low {
  // Mantendo a nomenclatura EnX_Low para paridade total com o C++
  static BigInt EnX1(BigInt seed) => 
      (seed * BigInt.from(137) + BigInt.from(11)) % BigInt.from(1000);

  static BigInt EnX3(BigInt seed) => 
      (EnX1(seed) * BigInt.from(827) + BigInt.from(97)) % BigInt.from(1000000);

  static BigInt EnX6(BigInt seed) => 
      (EnX3(seed) * BigInt.from(1000003) + BigInt.from(7)) % BigInt.from(1000000000);

  static BigInt EnX9(BigInt seed) {
    // Simulação do __int128: (EnX6 * 1234567 + 1) % 10^12
    BigInt s6 = EnX6(seed);
    BigInt multiplier = BigInt.from(1234567);
    BigInt divisor = BigInt.from(1000000000000);
    return (s6 * multiplier + BigInt.one) % divisor;
  }
}

class EnX18 {
  static String generate(BigInt seed) {
    // O EnX18 expande o EnX9 para 36 caracteres
    String raw = EnX_Low.EnX9(seed).toString();
    return EnXBase.expandir(raw, 36);
  }
}

class EnXBase {
  // Implementação idêntica ao EnXBase do C++
  static String to_string_pad(BigInt n, int width) {
    String s = n.toString();
    if (s.length > width) {
      return s.substring(s.length - width);
    }
    return s.padLeft(width, '0');
  }

  static String expandir(String base, int alvo) {
    String res = base;
    while (res.length < alvo) {
      BigInt n = BigInt.zero;
      for (int i = 0; i < res.length; i++) {
        // Multiplicador de 31 conforme o algoritmo EnX
        n += BigInt.from(res.codeUnitAt(i) * 31);
      }
      
      // Cálculo: n * (tamanho atual + 1)
      BigInt calc = n * BigInt.from(res.length + 1);
      
      // No C++, o buffer concatena 3 dígitos por vez
      String pad = to_string_pad(calc, 3);
      res += pad;
    }
    
    // Retorna os últimos 'alvo' caracteres conforme a hierarquia EnX OS
    if (res.length > alvo) {
      return res.substring(res.length - alvo);
    }
    return res;
  }
}
