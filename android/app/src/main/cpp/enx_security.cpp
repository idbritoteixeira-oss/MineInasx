#include <stdint.h>
#include <string>
#include <algorithm>
#include <vector>

extern "C" {

    uint64_t EnX1(uint64_t seed) {
        return (seed * 137 + 11) % 1000;
    }

    uint64_t EnX3(uint64_t seed) {
        return (EnX1(seed) * 827 + 97) % 1000000;
    }

    uint64_t EnX6(uint64_t seed) {
        return (EnX3(seed) * 1000003ULL + 7) % 1000000000;
    }

    uint64_t EnX9(uint64_t seed) {
        unsigned __int128 intermediate = (unsigned __int128)EnX6(seed) * 1234567 + 1;
        return (uint64_t)(intermediate % 1000000000000ULL);
    }

    void to_string_pad_native(uint64_t n, int width, char* out) {
        std::string s = "";
        if (n == 0) {
            s = "0";
        } else {
            uint64_t tempN = n;
            while (tempN > 0) {
                s += (char)('0' + (tempN % 10));
                tempN /= 10;
            }
        }
        while (s.length() < (size_t)width) s += '0';
        std::reverse(s.begin(), s.end());
        std::string final_s = s.substr(s.length() - width);
        for (size_t i = 0; i < final_s.length(); i++) out[i] = final_s[i];
        out[final_s.length()] = '\0';
    }

    void expandir_native(const char* base, int alvo, char* out) {
        std::string res = base;
        while (res.length() < (size_t)alvo) {
            uint64_t n = 0;
            for (char c : res) n += (uint64_t)(c * 31);
            uint64_t val = n * (res.length() + 1);
            char pad[4];
            to_string_pad_native(val, 3, pad);
            res += pad;
        }
        std::string final_res = res.substr(res.length() - alvo);
        for (size_t i = 0; i < final_res.length(); i++) out[i] = final_res[i];
        out[final_res.length()] = '\0';
    }

    uint64_t solve_inasx_ticket(uint64_t seed) {
        return EnX9(seed);
    }
}
