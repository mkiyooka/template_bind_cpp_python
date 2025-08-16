#pragma once

#include <random>

class Rand {
public:
    explicit Rand(unsigned int seed = 0)
        : mt(seed) {}
    void set_seed(unsigned int seed);
    double next();

private:
    std::mt19937 mt;
};
