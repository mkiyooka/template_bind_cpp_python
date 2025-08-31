# CMake version requirements:
# - nanobind: >= 3.15 (scikit-build-core)
# - cmake --preset: >= 3.19
# - project requirement: >= 3.19
cmake_minimum_required(VERSION 3.19)

# Default compiler preference (non-macOS: GCC preferred)
if(NOT APPLE AND NOT DEFINED CMAKE_C_COMPILER AND NOT DEFINED CMAKE_CXX_COMPILER)
    find_program(GCC_C_COMPILER NAMES gcc cc)
    find_program(GCC_CXX_COMPILER NAMES g++ c++)
    if(GCC_C_COMPILER AND GCC_CXX_COMPILER)
        set(CMAKE_C_COMPILER "${GCC_C_COMPILER}" CACHE FILEPATH "C compiler" FORCE)
        set(CMAKE_CXX_COMPILER "${GCC_CXX_COMPILER}" CACHE FILEPATH "C++ compiler" FORCE)
        message(STATUS "Using GCC toolchain: ${GCC_C_COMPILER}, ${GCC_CXX_COMPILER}")
    endif()
endif()
set(CMAKE_POSITION_INDEPENDENT_CODE ON) # Enable position-independent code. add "-fPIC"

# Optional: LLVM toolchain override
# Use: cmake --preset=<preset> -DCMAKE_TOOLCHAIN_FILE=toolchains/llvm-toolchain.cmake

project(template_bind_cpp_python
    VERSION 0.1.0
    LANGUAGES CXX C
)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(MODULE_NAME module_core)

# Auto-copy compile_commands.json to project root for IDE support
add_custom_target(copy_compile_commands ALL
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
        ${CMAKE_BINARY_DIR}/compile_commands.json 
        ${CMAKE_SOURCE_DIR}/compile_commands.json
    DEPENDS ${CMAKE_BINARY_DIR}/compile_commands.json
    COMMENT "Copying compile_commands.json to project root"
)

# Define project-wide include directories.
set(PROJECT_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(ENV{VIRTUAL_ENV} "${CMAKE_CURRENT_SOURCE_DIR}/.venv")
set(Python_FIND_VIRTUALENV FIRST)
message(STATUS "Using virtual environment: $ENV{VIRTUAL_ENV}")

# Unset default Python, set .venv Python
unset(Python_EXECUTABLE)
# Find Python and binding libraries.
if (CMAKE_VERSION VERSION_LESS 3.18)
    set(DEV_MODULE Development)
else()
    set(DEV_MODULE Development.Module)
endif()
find_package(Python 3.8
    REQUIRED COMPONENTS Interpreter ${DEV_MODULE}
    OPTIONAL_COMPONENTS Development.SABIModule
)
message(STATUS "Using python: ${Python_EXECUTABLE}")

# Search nanobind
message(STATUS "Using nanobind")
add_subdirectory(ext/nanobind REQUIRED)

add_subdirectory(src/core)
set(NANOBIND_MODULE_NAME _nanobind_module)
add_subdirectory(src/bindings)

# Set default build type.
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting default build type to Release")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Add debug flags for Debug and RelWithDebInfo builds
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0")
    message(STATUS "Debug symbols enabled for CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
elseif (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -g -O2")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} -g -O2")
    message(STATUS "Release with debug symbols enabled for CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
endif()

# Install the Python module.
install(TARGETS
    ${NANOBIND_MODULE_NAME} LIBRARY
    DESTINATION ${CMAKE_PROJECT_NAME}
)
install(FILES
    $<TARGET_FILE_DIR:${NANOBIND_MODULE_NAME}>/${NANOBIND_MODULE_NAME}.pyi
    DESTINATION ${CMAKE_PROJECT_NAME}
    OPTIONAL
)
install(FILES
    $<TARGET_FILE_DIR:${NANOBIND_MODULE_NAME}>/py.typed
    DESTINATION ${CMAKE_PROJECT_NAME}
)

# ============================================================================
# Development Environment Setup (skipped in scikit-build)
# ============================================================================
if(NOT SKBUILD)
    # Enable testing for CTest, call before add_subdirectory(tests/cpp)
    enable_testing()
    
    # Add test and debug directories
    add_subdirectory(tests/cpp)
    add_subdirectory(debug)
    
    # Collect source files for quality tools
    file(GLOB_RECURSE ALL_SOURCE_FILES
        ${CMAKE_SOURCE_DIR}/src/**/*.cpp
        ${CMAKE_SOURCE_DIR}/src/**/*.c
        ${CMAKE_SOURCE_DIR}/debug/**/*.cpp
        ${CMAKE_SOURCE_DIR}/debug/**/*.c
        ${CMAKE_SOURCE_DIR}/tests/**/*.cpp
        ${CMAKE_SOURCE_DIR}/include/**/*.hpp
        ${CMAKE_SOURCE_DIR}/include/**/*.h
    )
    
    # Setup quality management tools
    include(cmake/quality-tools.cmake)
    setup_quality_tools()
    setup_quality_targets("${ALL_SOURCE_FILES}")
    setup_quality_check_target()
    
    # Development utility target for listing available quality targets
    add_custom_target(list-quality-targets
        COMMAND ${CMAKE_COMMAND} -E echo "=== Available Quality Targets ==="
        COMMAND ${CMAKE_COMMAND} -E echo "fullcheck         - Run all quality checks: format + lint + cppcheck"
        COMMAND ${CMAKE_COMMAND} -E echo "format            - Format code with clang-format"
        COMMAND ${CMAKE_COMMAND} -E echo "format-dry        - Check formatting without changes"
        COMMAND ${CMAKE_COMMAND} -E echo "lint              - Lint code with clang-tidy"
        COMMAND ${CMAKE_COMMAND} -E echo "run-cppcheck      - Run cppcheck static analysis"
        COMMAND ${CMAKE_COMMAND} -E echo "run-cppcheck-verbose - Run cppcheck with verbose output"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${CMAKE_COMMAND} -E echo "Note: All targets exclude src/bindings/ directory"
        COMMENT "Listing all available quality targets"
    )
endif()
