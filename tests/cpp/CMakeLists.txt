# C++ tests
add_executable(test_hamming 
    test_hamming.cpp
)

target_link_libraries(test_hamming PRIVATE cxx_core)
add_test(NAME test_hamming COMMAND test_hamming)
