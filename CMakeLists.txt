# CMake >= 3.15 for scikit-build-core
cmake_minimum_required(VERSION 3.15)
project(
    template_bind_cpp_python
    VERSION 0.1.0
    LANGUAGES CXX C
)
set(MODULE_NAME module_core)

# Define project-wide include directories.
set(PROJECT_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
message(STATUS "Using virtual environment: $ENV{VIRTUAL_ENV}")

# Unset default Python, set .venv Python
unset(Python_EXECUTABLE)

# Enable testing for CTest.
enable_testing()

# Find Python and binding libraries.
if($ENV{WITH_PYBIND11})
    message(STATUS "Using pybind11")
    set(BINDING_SYSTEM pybind11)
    set(PYBIND11_FINDPYTHON ON)
    find_package(
        Python 3.8
        COMPONENTS Interpreter Development REQUIRED
    )
    message(STATUS "python executable: ${Python_EXECUTABLE}")

    execute_process(
        COMMAND "${Python_EXECUTABLE}" -m pybind11 --cmakedir
        OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE pybind11_ROOT
        RESULT_VARIABLE pybind11_RESULT
        OUTPUT_QUIET
        ERROR_QUIET
    )
else()
    message(STATUS "Using nanobind")
    set(BINDING_SYSTEM nanobind)
    if (CMAKE_VERSION VERSION_LESS 3.18)
        set(DEV_MODULE Development)
    else()
        set(DEV_MODULE Development.Module)
    endif()
    find_package(
        Python 3.8
        REQUIRED COMPONENTS Interpreter ${DEV_MODULE}
        OPTIONAL_COMPONENTS Development.SABIModule
    )
    message(STATUS "python executable: ${Python_EXECUTABLE}")

    execute_process(
        COMMAND "${Python_EXECUTABLE}" -m ${BINDING_SYSTEM} --cmake_dir
        OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE nanobind_ROOT
        RESULT_VARIABLE nanobind_RESULT
    )
endif()

if(${BINDING_SYSTEM}_RESULT EQUAL 0)
    # 1. If installed via pip/conda, use find_package to locate BINDING_SYSTEM.
    message(STATUS "${BINDING_SYSTEM} found via ${Python_EXECUTABLE}, using pip/conda")
    message(STATUS "nanobind_DIR: ${nanobind_DIR}")
    find_package(${BINDING_SYSTEM} CONFIG REQUIRED)
elseif(EXISTS "${CMAKE_SOURCE_DIR}/ext/${BINDING_SYSTEM}/CMakeLists.txt")
    ## 2. If added as Git submodule, use add_subdirectory.
    message(STATUS "${BINDING_SYSTEM} not found via ${Python_EXECUTABLE}, trying local submodule")
    add_subdirectory(ext/${BINDING_SYSTEM} REQUIRED)
else()
    message(FATAL_ERROR
        "${BINDING_SYSTEM} not found via ${Python_EXECUTABLE} and no local submodule in ext/${BINDING_SYSTEM}")
endif()

add_subdirectory(src/core)
add_subdirectory(src/bindings)
add_subdirectory(tests/cpp)

# Set default build type.
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting default build type to Release")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Install the Python module.
install(TARGETS ${MODULE_NAME} LIBRARY DESTINATION ${CMAKE_PROJECT_NAME})
