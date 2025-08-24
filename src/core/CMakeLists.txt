# Core C++ library
add_library(cxx_core STATIC
    fast_class.cpp
    simple_function.cpp
)

target_include_directories(cxx_core PUBLIC
    ${PROJECT_INCLUDE_DIR}
)
