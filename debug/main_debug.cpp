#include "fast_class.hpp"
#include "simple_function.hpp"
#include <iostream>
#include <string>
#include <vector>

/**
 * Main debug program for multi-module testing and integration scenarios
 * This can be extended to test combinations of multiple modules
 */

static void testFastClassModule() {
    std::cout << "\n--- Testing Fast Class Module ---" << "\n";

    std::vector<uint64_t> a = {0x1234567890ABCDEF, 0xFFFFFFFFFFFFFFFF};
    std::vector<uint64_t> b = {0xFEDCBA0987654321, 0x0000000000000000};

    fast_class::HammingDistanceCalculator calculator(a, b);
    int result = calculator.calculate();

    std::cout << "Fast class test result: " << result << "\n";
}

static void testSimpleFunctionModule() {
    std::cout << "\n--- Testing Simple Function Module ---" << "\n";

    int int_result = simple_function::addIntegers(5, 3);
    std::cout << "addIntegers(5, 3) = " << int_result << "\n";

    double double_result = simple_function::addDoubles(5.5, 3.2);
    std::cout << "addDoubles(5.5, 3.2) = " << double_result << "\n";

    int generic_int = simple_function::addGeneric(10, 20);
    std::cout << "addGeneric<int>(10, 20) = " << generic_int << "\n";

    double generic_double = simple_function::addGeneric(7.7, 2.3);
    std::cout << "addGeneric<double>(7.7, 2.3) = " << generic_double << "\n";
}

static void testIntegrationScenarios() {
    std::cout << "\n--- Testing Integration Scenarios ---" << "\n";

    std::cout << "Integration: Using simple_function to generate test data for fast_class" << "\n";

    // Generate test values using simple_function
    auto val1 = static_cast<uint64_t>(simple_function::addIntegers(100, 200));
    auto val2 = static_cast<uint64_t>(simple_function::addIntegers(50, 150));

    std::cout << "Generated values: " << val1 << ", " << val2 << "\n";

    std::vector<uint64_t> a = {val1, val2};
    std::vector<uint64_t> b = {val2, val1};

    fast_class::HammingDistanceCalculator calculator(a, b);
    int hamming_result = calculator.calculate();

    std::cout << "Hamming distance of generated data: " << hamming_result << "\n";
}

int main(int argc, char *argv[]) {

    std::cout << "=== Multi-Module Debug Program ===" << "\n";

    if (argc > 1) {
        std::string arg = std::string(argv[1]); // NOLINT(cppcoreguidelines-pro-bounds-pointer-arithmetic)
        if (arg == "--fast-class") {
            testFastClassModule();
            return 0;
        }
        if (arg == "--simple-function") {
            testSimpleFunctionModule();
            return 0;
        }
        if (arg == "--integration") {
            testIntegrationScenarios();
            return 0;
        }
        if (arg == "--help") {
            std::string program_name = std::string(argv[0]); // NOLINT(cppcoreguidelines-pro-bounds-pointer-arithmetic)
            std::cout << "Usage: " << program_name << " [--fast-class|--simple-function|--integration|--help]"
                      << "\n";
            std::cout << "  --fast-class       Test fast class module only" << "\n";
            std::cout << "  --simple-function  Test simple function module only" << "\n";
            std::cout << "  --integration      Test integration scenarios" << "\n";
            std::cout << "  --help             Show this help message" << "\n";
            return 0;
        }
    }

    // Run all tests by default
    testFastClassModule();
    testSimpleFunctionModule();
    testIntegrationScenarios();

    std::cout << "\n=== Debug Complete ===" << "\n";
    return 0;
}
