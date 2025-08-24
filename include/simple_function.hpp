#pragma once

namespace simple_function {

/**
 * Simple addition function for integers
 * @param a First integer
 * @param b Second integer
 * @return Sum of a and b
 */
int addIntegers(int a, int b);

/**
 * Simple addition function for floating point numbers
 * @param a First double
 * @param b Second double
 * @return Sum of a and b
 */
double addDoubles(double a, double b);

/**
 * Add two numbers with template for generic types
 * @tparam T Numeric type
 * @param a First number
 * @param b Second number
 * @return Sum of a and b
 */
template <typename T>
T addGeneric(T a, T b) {
    return a + b;
}

} // namespace simple_function