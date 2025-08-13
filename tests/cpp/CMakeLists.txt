# C++ tests
add_executable(test_rand 
    test_rand.cpp
)

# includes are inherited from rand_core
target_link_libraries(test_rand PRIVATE rand_core)

# Register test with CTest
add_test(NAME test_rand COMMAND test_rand)

# Optional: set test properties
set_tests_properties(test_rand PROPERTIES
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
