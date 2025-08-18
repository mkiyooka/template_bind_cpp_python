# CMake >= 3.15 for scikit-build-core
cmake_minimum_required(VERSION 3.15)
project(template_bind_cpp_python
    VERSION 0.1.0
    LANGUAGES CXX C
)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(MODULE_NAME module_core)

# Force -O0 for Debug builds
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0" CACHE STRING "Flags used by the CXX compiler for debug builds." FORCE)
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -O0" CACHE STRING "Flags used by the C compiler for debug builds." FORCE)
    message(STATUS "Forcing -O0 for Debug build type.")
endif()

# Define project-wide include directories.
set(PROJECT_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(ENV{VIRTUAL_ENV} "${CMAKE_CURRENT_SOURCE_DIR}/.venv")
set(Python_FIND_VIRTUALENV FIRST)
message(STATUS "Using virtual environment: $ENV{VIRTUAL_ENV}")

# Enable testing for CTest.
enable_testing()

function(add_binding_system BINDING_SYSTEM BINDING_SYSTEM_FOUND)
    if(${BINDING_SYSTEM}_RESULT EQUAL 0)
        # 1. If installed via pip/conda, use find_package to locate BINDING_SYSTEM.
        message(STATUS "${BINDING_SYSTEM} found via ${Python_EXECUTABLE}, using pip/conda")
        message(STATUS "nanobind_DIR: ${nanobind_DIR}")
        find_package(${BINDING_SYSTEM} CONFIG REQUIRED)
        set(${BINDING_SYSTEM_FOUND} TRUE PARENT_SCOPE)
    elseif(EXISTS "${CMAKE_SOURCE_DIR}/ext/${BINDING_SYSTEM}/CMakeLists.txt")
        ## 2. If added as Git submodule, use add_subdirectory.
        message(STATUS "${BINDING_SYSTEM} not found via ${Python_EXECUTABLE}, trying local submodule")
        add_subdirectory(ext/${BINDING_SYSTEM} REQUIRED)
        set(${BINDING_SYSTEM_FOUND} TRUE PARENT_SCOPE)
    else()
        message(FATAL_ERROR
            "${BINDING_SYSTEM} not found via ${Python_EXECUTABLE} and no local submodule in ext/${BINDING_SYSTEM}")
        set(${BINDING_SYSTEM_FOUND} FALSE PARENT_SCOPE)
    endif()
endfunction()

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

message(STATUS "Using nanobind")
execute_process(COMMAND "${Python_EXECUTABLE}" -m nanobind --cmake_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE nanobind_ROOT
    RESULT_VARIABLE nanobind_RESULT
)
set(nanobind_FOUND FALSE)
add_binding_system(nanobind nanobind_FOUND)

message(STATUS "Using pybind11")
set(PYBIND11_FINDPYTHON ON)
execute_process(
    COMMAND "${Python_EXECUTABLE}" -m pybind11 --cmakedir
    OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE pybind11_ROOT
    RESULT_VARIABLE pybind11_RESULT
)
set(pybind11_FOUND FALSE)
add_binding_system(pybind11 pybind11_FOUND)

add_subdirectory(src/core)
set(NANOBIND_MODULE_NAME _nanobind_module)
set(PYBIND11_MODULE_NAME _pybind11_module)
add_subdirectory(src/bindings)
add_subdirectory(tests/cpp)

# Set default build type.
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting default build type to Debug for debugging")
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Add debug flags for Debug and RelWithDebInfo builds
if (CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0")
    message(STATUS "Debug symbols enabled for CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
endif()

# Install the Python module.
if(${nanobind_FOUND})
    install(TARGETS
        ${NANOBIND_MODULE_NAME} LIBRARY
        DESTINATION ${CMAKE_PROJECT_NAME}
    )
    install(FILES
        $<TARGET_FILE_DIR:${NANOBIND_MODULE_NAME}>/${NANOBIND_MODULE_NAME}.pyi
        $<TARGET_FILE_DIR:${NANOBIND_MODULE_NAME}>/py.typed
        DESTINATION ${CMAKE_PROJECT_NAME}
    )
endif()

if(${pybind11_FOUND})
    install(TARGETS ${PYBIND11_MODULE_NAME} LIBRARY DESTINATION ${CMAKE_PROJECT_NAME})
endif()

# ----- Make file list for custom targets -----
file(GLOB_RECURSE ALL_SOURCE_FILES
    ${CMAKE_SOURCE_DIR}/src/**/*.cpp
    ${CMAKE_SOURCE_DIR}/src/**/*.c
    ${CMAKE_SOURCE_DIR}/tests/**/*.cpp
    ${CMAKE_SOURCE_DIR}/include/**/*.hpp
    ${CMAKE_SOURCE_DIR}/include/**/*.h
)
foreach(src ${ALL_SOURCE_FILES})
    if (NOT src MATCHES "/src/bindings/")
        list(APPEND SOURCE_FILES_EXCLUDE_BINDING ${src})
    endif()
endforeach()

# ----- Setup custom targets -----
add_custom_target(check)

find_program(CLANG_FORMAT_EXE clang-format)
message(STATUS "Found clang-format: ${CLANG_FORMAT_EXE}")
if(CLANG_FORMAT_EXE)
    add_custom_target(format
        COMMAND ${CLANG_FORMAT_EXE} -i ${ALL_SOURCE_FILES}
        COMMENT "Formatting source code with clang-format"
    )
    add_custom_target(format-dry
        COMMAND ${CLANG_FORMAT_EXE} --dry-run --Werror ${ALL_SOURCE_FILES}
        COMMENT "Checking formatting (dry-run)"
    )
    add_dependencies(check format)
endif()

find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
message(STATUS "Found clang-tidy: ${CLANG_TIDY_EXE}")
if(CLANG_TIDY_EXE)
    set(CMAKE_CXX_CLANG_TIDY
        "${CLANG_TIDY_EXE}"
    )
    add_custom_target(lint
        COMMAND ${CMAKE_CXX_CLANG_TIDY} ${SOURCE_FILES_EXCLUDE_BINDING}
        COMMENT "Running clang-tidy"
    )
    add_dependencies(check lint)
endif()

find_program(CPPCHECK cppcheck)
if(CPPCHECK)
    add_custom_target(run-cppcheck
        COMMAND ${CPPCHECK}
            --project=${CMAKE_BINARY_DIR}/compile_commands.json
            -i.venv
            -isrc/bindings
            --enable=warning,style,performance,portability,information
            --inconclusive
            --error-exitcode=1
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running cppcheck"
        VERBATIM
    )
    add_dependencies(check run-cppcheck)
endif()

