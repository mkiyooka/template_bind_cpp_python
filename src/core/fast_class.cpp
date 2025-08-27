#include "fast_class.hpp"
#include <cstddef>
#include <cstdint>
#include <stdexcept>
#include <vector>

namespace fast_class {

// 内部使用の個別関数
namespace {

// ハミング距離計算 - CPU組み込み命令版（最適化版）
int hammingDistanceBuiltin(uint64_t a, uint64_t b) noexcept {
#ifdef __GNUC__
    return __builtin_popcountll(a ^ b);
#elif defined(_MSC_VER)
    return static_cast<int>(__popcnt64(a ^ b));
#else
    // フォールバック: ビット計算版を使用
    uint64_t x = a ^ b;
    x = x - ((x >> 1U) & 0x5555555555555555ULL);
    x = (x & 0x3333333333333333ULL) + ((x >> 2U) & 0x3333333333333333ULL);
    x = (x + (x >> 4U)) & 0x0F0F0F0F0F0F0F0FULL;
    return static_cast<int>((x * 0x0101010101010101ULL) >> 56U);
#endif
}

} // namespace

// HammingDistanceCalculator クラスの実装

HammingDistanceCalculator::HammingDistanceCalculator(const std::vector<uint64_t> &a, const std::vector<uint64_t> &b)
    : a_data_(a),
      b_data_(b) {
    if (a.size() != b.size()) {
        throw std::invalid_argument("Vector sizes must match");
    }
}

int HammingDistanceCalculator::calculate() const {
    const size_t data_size = a_data_.size();
    int total_sum = 0;

    // ループアンローリングで4つずつ処理（最適化）
    const size_t unroll_size = data_size - (data_size % 4);
    size_t i = 0;

    for (; i < unroll_size; i += 4) {
        total_sum += hammingDistanceBuiltin(a_data_[i], b_data_[i]);
        total_sum += hammingDistanceBuiltin(a_data_[i + 1], b_data_[i + 1]);
        total_sum += hammingDistanceBuiltin(a_data_[i + 2], b_data_[i + 2]);
        total_sum += hammingDistanceBuiltin(a_data_[i + 3], b_data_[i + 3]);
    }

    // 残りの要素を処理
    for (; i < data_size; ++i) {
        total_sum += hammingDistanceBuiltin(a_data_[i], b_data_[i]);
    }

    return total_sum;
}

} // namespace fast_class
