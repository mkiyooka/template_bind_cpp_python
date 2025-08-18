#include "rand.hpp"
#include <iostream>

int main() {
    Rand rand_gen(123);
    for (int i = 0; i < 5; ++i) {
        std::cout << "Random number: " << rand_gen.next() << std::endl;
    }
    return 0;
}
