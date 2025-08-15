#include "rand.hpp"

void Rand::set_seed(unsigned int seed) { mt.seed(seed); }
double Rand::next() {
    std::uniform_real_distribution<double> dist(0.0, 1.0);
    return dist(mt);
}

auto func(int a, double b) -> double {
    for (auto i = 0; i < 10; ++i) {
        std::cout << "a: " << a << ", b: " << b << std::endl;
    }
    return a + b;
}
