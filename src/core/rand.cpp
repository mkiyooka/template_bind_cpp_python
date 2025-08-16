#include "rand.hpp"

void Rand::set_seed(unsigned int seed) { mt.seed(seed); }
double Rand::next() {
    std::uniform_real_distribution<double> dist(0.0, 1.0);
    return dist(mt);
}
