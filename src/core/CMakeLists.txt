# Core C++ library
add_library(rand_core STATIC
    rand.cpp
)

add_executable(debug_rand debug_main.cpp)
target_link_libraries(debug_rand PRIVATE rand_core)
target_include_directories(debug_rand PUBLIC ${PROJECT_INCLUDE_DIR})

target_include_directories(rand_core PUBLIC
    ${PROJECT_INCLUDE_DIR}
)
