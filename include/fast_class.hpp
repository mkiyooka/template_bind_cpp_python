#pragma once

#include <cstdint>
#include <vector>

namespace fast_class {

class HammingDistanceCalculator {
public:
    HammingDistanceCalculator(const std::vector<uint64_t> &a, const std::vector<uint64_t> &b);
    int calculate() const;
    size_t size() const noexcept { return a_data_.size(); }

private:
    std::vector<uint64_t> a_data_;
    std::vector<uint64_t> b_data_;
};

} // namespace fast_class
