import 'dart:math'; // Apenas para utilitários se necessário, mas aqui faremos manual

class EnXBase {
  // Simula: std::string to_string_pad(int128 n, int width)
  static String to_string_pad(BigInt n, int width) {
    String s = "";
    
    if (n == BigInt.zero) {
      s = "0";
    } else {
      BigInt tempN = n;
      while (tempN > BigInt.zero) {
        // (char)('0' + (n % 10))
        BigInt digit = tempN % BigInt.from(10);
        s += digit.toString();
        tempN = tempN ~/ BigInt.from(10); // Divisão inteira
      }
    }

    // while (s.length() < width) s += '0';
    while (s.length < width) {
      s += '0';
    }

    // std::reverse(s.begin(), s.end());
    String reversed = s.split('').reversed.join('');

    // return s.substr(s.length() - width);
    if (reversed.length > width) {
      return reversed.substring(reversed.length - width);
    }
    return reversed;
  }

  // Simula: std::string expandir(std::string base, int alvo)
  static String expandir(String base, int alvo) {
    String res = base;
    while (res.length < alvo) {
      BigInt n = BigInt.zero;
      // for(char c : res) n += (c * 31);
      for (int i = 0; i < res.length; i++) {
        n += BigInt.from(res.codeUnitAt(i)) * BigInt.from(31);
      }
      
      // res += to_string_pad(n * (res.length() + 1), 3);
      BigInt val = n * BigInt.from(res.length + 1);
      res += to_string_pad(val, 3);
    }
    
    // return res.substr(res.length() - alvo);
    if (res.length > alvo) {
      return res.substring(res.length - alvo);
    }
    return res;
  }
}
