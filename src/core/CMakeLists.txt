# Core C++ library
add_library(rand_core STATIC
    rand.cpp
)

target_include_directories(rand_core PUBLIC
    ${PROJECT_INCLUDE_DIR}
)
