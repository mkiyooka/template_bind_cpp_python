# CMake >= 3.15 for scikit-build-core
cmake_minimum_required(VERSION 3.15)

# LLVM環境変数検出とツールチェーン自動選択
if(DEFINED ENV{CC} AND "$ENV{CC}" MATCHES "llvm@14")
    message(STATUS "Detected LLVM14 environment via CC: $ENV{CC}")
    # コンパイラのみLLVM14を使用、アーカイバ・リンカはシステム標準を使用（macOS互換性のため）
    set(CMAKE_C_COMPILER "$ENV{CC}" CACHE FILEPATH "C compiler" FORCE)
    set(CMAKE_CXX_COMPILER "$ENV{CXX}" CACHE FILEPATH "C++ compiler" FORCE)
    # macOS互換性のためシステム標準のarを使用
    find_program(SYSTEM_AR ar PATHS /usr/bin /bin NO_DEFAULT_PATH)
    find_program(SYSTEM_RANLIB ranlib PATHS /usr/bin /bin NO_DEFAULT_PATH)
    if(SYSTEM_AR)
        set(CMAKE_AR "${SYSTEM_AR}" CACHE FILEPATH "Archiver" FORCE)
    endif()
    if(SYSTEM_RANLIB)
        set(CMAKE_RANLIB "${SYSTEM_RANLIB}" CACHE FILEPATH "Ranlib" FORCE)
    endif()
    message(STATUS "Using LLVM14 compilers with system ar/ranlib for macOS compatibility")
endif()

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

# ----- Setup custom targets -----
add_custom_target(check)

# clang-format: 個別インストール版を優先、次にLLVMバージョン
find_program(CLANG_FORMAT_EXE 
    NAMES clang-format
    PATHS 
        /opt/homebrew/bin                    # brew install clang-format
        /opt/homebrew/opt/llvm/bin          # brew install llvm (latest)
        /opt/homebrew/opt/llvm@20/bin       # brew install llvm@20
        /opt/homebrew/opt/llvm@19/bin       # brew install llvm@19
        /opt/homebrew/opt/llvm@18/bin       # brew install llvm@18
        /opt/homebrew/opt/llvm@17/bin       # brew install llvm@17
        /opt/homebrew/opt/llvm@16/bin       # brew install llvm@16
        /opt/homebrew/opt/llvm@15/bin       # brew install llvm@15
        /opt/homebrew/opt/llvm@14/bin       # brew install llvm@14
    NO_DEFAULT_PATH
)
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

# clang-tidy: LLVMインストールが必要
find_program(CLANG_TIDY_EXE 
    NAMES clang-tidy
    PATHS 
        /opt/homebrew/opt/llvm/bin          # brew install llvm (latest)
        /opt/homebrew/opt/llvm@20/bin       # brew install llvm@20
        /opt/homebrew/opt/llvm@19/bin       # brew install llvm@19
        /opt/homebrew/opt/llvm@18/bin       # brew install llvm@18
        /opt/homebrew/opt/llvm@17/bin       # brew install llvm@17
        /opt/homebrew/opt/llvm@16/bin       # brew install llvm@16
        /opt/homebrew/opt/llvm@15/bin       # brew install llvm@15
        /opt/homebrew/opt/llvm@14/bin       # brew install llvm@14
    NO_DEFAULT_PATH
)
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
message(STATUS "Found cppcheck: ${CPPCHECK}")
if(CPPCHECK)
    add_custom_target(run-cppcheck
        COMMAND ${CPPCHECK}
            --enable=all
            --inconclusive
            --std=c++17
            --platform=native
            -I include/
            --suppress=missingIncludeSystem
            --suppress=unusedFunction
            --inline-suppr
            --quiet
            ${SOURCE_FILES_EXCLUDE_BINDING}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running cppcheck static analysis (excluding bindings)"
        VERBATIM
    )
    add_custom_target(run-cppcheck-verbose
        COMMAND ${CPPCHECK}
            --enable=all
            --inconclusive
            --std=c++17
            --platform=native
            -I include/
            --suppress=missingIncludeSystem
            --suppress=unusedFunction
            --inline-suppr
            --verbose
            ${SOURCE_FILES_EXCLUDE_BINDING}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running cppcheck static analysis (verbose output, excluding bindings)"
        VERBATIM
    )
    add_dependencies(check run-cppcheck)
endif()
