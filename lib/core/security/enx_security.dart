import 'dart:math';

// ==========================================
// ENX_SECURITY.DART - PARIDADE TOTAL ENX OS
// ==========================================

class EnX_Low {
  static BigInt _u64(BigInt n) => n.toUnsigned(64);

  static BigInt EnX1(BigInt seed) {
    return _u64(_u64(seed * BigInt.from(137)) + BigInt.from(11)) % BigInt.from(1000);
  }

  static BigInt EnX3(BigInt seed) {
    return _u64(_u64(EnX1(seed) * BigInt.from(827)) + BigInt.from(97)) % BigInt.from(1000000);
  }

  static BigInt EnX6(BigInt seed) {
    return _u64(_u64(EnX3(seed) * BigInt.from(1000003)) + BigInt.from(7)) % BigInt.from(1000000000);
  }

  static BigInt EnX9(BigInt seed) {
    BigInt s = _u64(seed);
    BigInt e6 = _u64(EnX6(s));
    
    // Simula intermediate = (int128)e6 * 1234567 + 1
    BigInt intermediate = (e6 * BigInt.from(1234567)) + BigInt.one;
    
    // Retorna o módulo de 12 dígitos
    return _u64(intermediate % BigInt.parse("1000000000000"));
  }
}

class EnXBase {
  static String to_string_pad(BigInt n, int width) {
    String s = "";
    if (n == BigInt.zero) {
      s = "0";
    } else {
      BigInt tempN = n;
      while (tempN > BigInt.zero) {
        int digit = (tempN % BigInt.from(10)).toInt();
        s += digit.toString();
        tempN = tempN ~/ BigInt.from(10);
      }
    }

    while (s.length < width) s += '0';

    // Inverte e corta exatamente como o std::reverse + substr do C++
    String reversed = s.split('').reversed.join('');
    if (reversed.length > width) {
      return reversed.substring(reversed.length - width);
    }
    return reversed;
  }

  static String expandir(String base, int alvo) {
    String res = base;
    while (res.length < alvo) {
      BigInt n = BigInt.zero;
      for (int i = 0; i < res.length; i++) {
        n += BigInt.from(res.codeUnitAt(i) * 31);
      }
      BigInt val = n * BigInt.from(res.length + 1);
      res += to_string_pad(val, 3);
    }
    
    if (res.length > alvo) {
      return res.substring(res.length - alvo);
    }
    return res;
  }
}
