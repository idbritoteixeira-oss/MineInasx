import 'enx_base.dart'; // Importa se precisar de dependências cruzadas, mas a lógica é matemática pura

class EnX_Low {
  
  // static uint64_t EnX1(uint64_t seed)
  static BigInt EnX1(BigInt seed) {
    // return (seed * 137 + 11) % 1000;
    return (seed * BigInt.from(137) + BigInt.from(11)) % BigInt.from(1000);
  }

  // static uint64_t EnX3(uint64_t seed)
  static BigInt EnX3(BigInt seed) {
    // return (EnX1(seed) * 827 + 97) % 1000000;
    return (EnX1(seed) * BigInt.from(827) + BigInt.from(97)) % BigInt.from(1000000);
  }

  // static uint64_t EnX6(uint64_t seed)
  static BigInt EnX6(BigInt seed) {
    // return (EnX3(seed) * 1000003ULL + 7) % 1000000000;
    // O sufixo ULL no C++ garante unsigned long long
    return (EnX3(seed) * BigInt.from(1000003) + BigInt.from(7)) % BigInt.from(1000000000);
  }

  // static uint64_t EnX9(uint64_t seed)
  static BigInt EnX9(BigInt seed) {
    // int128 intermediate = (int128)EnX6(seed) * 1234567 + 1;
    // return (uint64_t)(intermediate % 1000000000000ULL);
    
    BigInt enx6Val = EnX6(seed);
    BigInt intermediate = (enx6Val * BigInt.from(1234567) + BigInt.one);
    
    BigInt result = intermediate % BigInt.parse("1000000000000");
    
    // Cast final para uint64_t para segurança
    return result.toUnsigned(64);
  }
}
