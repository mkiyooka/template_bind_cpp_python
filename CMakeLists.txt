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

# Optional: LLVM toolchain override
# Use: cmake --preset=<preset> -DCMAKE_TOOLCHAIN_FILE=toolchains/llvm-toolchain.cmake

project(template_bind_cpp_python
    VERSION 0.1.0
    LANGUAGES CXX C
)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(MODULE_NAME module_core)

# Define project-wide include directories.
set(PROJECT_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(ENV{VIRTUAL_ENV} "${CMAKE_CURRENT_SOURCE_DIR}/.venv")
set(Python_FIND_VIRTUALENV FIRST)
message(STATUS "Using virtual environment: $ENV{VIRTUAL_ENV}")

# Enable testing for CTest.
enable_testing()

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

# --- search nanobind ---
message(STATUS "Using nanobind")
add_subdirectory(ext/nanobind REQUIRED)

add_subdirectory(src/core)
set(NANOBIND_MODULE_NAME _nanobind_module)
add_subdirectory(src/bindings)

# テストとデバッグターゲットはscikit-build環境では除外
if(NOT SKBUILD)
    add_subdirectory(tests/cpp)
    add_subdirectory(debug)
endif()

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

# ----- Make file list for custom targets -----
file(GLOB_RECURSE ALL_SOURCE_FILES
    ${CMAKE_SOURCE_DIR}/src/**/*.cpp
    ${CMAKE_SOURCE_DIR}/src/**/*.c
    ${CMAKE_SOURCE_DIR}/debug/**/*.cpp
    ${CMAKE_SOURCE_DIR}/debug/**/*.c
    ${CMAKE_SOURCE_DIR}/tests/**/*.cpp
    ${CMAKE_SOURCE_DIR}/include/**/*.hpp
    ${CMAKE_SOURCE_DIR}/include/**/*.h
)
foreach(src ${ALL_SOURCE_FILES})
    if (NOT src MATCHES "/src/bindings/")
        list(APPEND SOURCE_FILES_EXCLUDE_BINDING ${src})
    endif()
endforeach()

# ----- Setup quality management tools (separate from build) -----
include(cmake/quality-tools.cmake)
setup_quality_tools()

# Setup custom targets
add_custom_target(check)
setup_quality_targets("${ALL_SOURCE_FILES}")

# Add quality targets to check
if(TARGET format)
    add_dependencies(check format)
endif()
if(TARGET lint)
    add_dependencies(check lint)
endif()
# Note: static-analysis is not added to check by default as it's more intensive
# Use: cmake --build build --target static-analysis

find_program(CPPCHECK cppcheck)
message(STATUS "Found cppcheck: ${CPPCHECK}")
if(CPPCHECK)
    # cppcheckの基本設定
    set(CPPCHECK_BASE_ARGS
        --enable=all
        --inconclusive
        --std=c++17
        --platform=native
        -I include/
        --suppress=missingIncludeSystem
        --suppress=unusedFunction
        --inline-suppr
        --quiet
    )
    
    # プリセットから追加引数を取得
    if(DEFINED CPPCHECK_ADDITIONAL_ARGS)
        string(REPLACE " " ";" CPPCHECK_EXTRA_ARGS "${CPPCHECK_ADDITIONAL_ARGS}")
        list(APPEND CPPCHECK_BASE_ARGS ${CPPCHECK_EXTRA_ARGS})
    endif()
    
    add_custom_target(run-cppcheck
        COMMAND ${CPPCHECK}
            ${CPPCHECK_BASE_ARGS}
            ${SOURCE_FILES_EXCLUDE_BINDING}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running cppcheck static analysis (excluding bindings)"
        VERBATIM
    )
    # cppcheck verbose版（--quietを--verboseに変更）
    set(CPPCHECK_VERBOSE_ARGS ${CPPCHECK_BASE_ARGS})
    list(REMOVE_ITEM CPPCHECK_VERBOSE_ARGS "--quiet")
    list(APPEND CPPCHECK_VERBOSE_ARGS "--verbose")
    
    add_custom_target(run-cppcheck-verbose
        COMMAND ${CPPCHECK}
            ${CPPCHECK_VERBOSE_ARGS}
            ${SOURCE_FILES_EXCLUDE_BINDING}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running cppcheck static analysis (verbose output, excluding bindings)"
        VERBATIM
    )
    add_dependencies(check run-cppcheck)
endif()
