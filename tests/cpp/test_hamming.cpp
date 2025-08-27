#include <cstdint>
#include <iostream>
#include <vector>

#include "fast_class.hpp"

int main() noexcept {
    try {
        // テストデータ
        const std::vector<uint64_t> a = {0x1234567890ABCDEF, 0xFFFFFFFFFFFFFFFF, 0x0000000000000000};
        const std::vector<uint64_t> b = {0xFEDCBA0987654321, 0x0000000000000000, 0xFFFFFFFFFFFFFFFF};

        const fast_class::HammingDistanceCalculator calculator(a, b);
        const int result = calculator.calculate();

        // 期待値: 36 + 64 + 64 = 164
        if (result == 164) {
            std::cout << "PASS\n";
            return 0;
        }
        std::cout << "FAIL: expected 164, got " << result << '\n';
        return 1;
    } catch (...) {
        std::cout << "EXCEPTION: Unexpected error occurred\n";
        return 1;
    }
}
