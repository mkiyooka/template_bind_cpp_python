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

# Enable testing for CTest.
enable_testing()

# Find Python and binding libraries.
if($ENV{WITH_PYBIND11})
    message(STATUS "Using pybind11")
    set(PYBIND11_FINDPYTHON ON)
    find_package(
        Python 3.8
        COMPONENTS Interpreter Development REQUIRED
    )

    ## 1. If you have installed pybind11 via pip or conda, you can use
    ##    find_package command to find the pybind11 root directory.
    find_package(pybind11 CONFIG REQUIRED)

    ## 2. Or if you have installed pybind11 as Git submodule,
    ##    you can use the add_subdirectory command.
    # add_subdirectory(ext/pybind11 REQUIRED)
else()
    message(STATUS "Using nanobind")
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

    ## 1. If you have installed nanobind via pip or conda, you can use
    ##    execute_process and find_package commands to find the nanobind root directory.
    execute_process(
        COMMAND "${Python_EXECUTABLE}" -m nanobind --cmake_dir
        OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE nanobind_ROOT
    )
    find_package(nanobind CONFIG REQUIRED)

    ## 2. Or if you have installed nanobind as Git submodule,
    ##    you can use the add_subdirectory command.
    # add_subdirectory(ext/nanobind)
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
