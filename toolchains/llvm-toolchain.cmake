# File: toolchains/llvm-toolchain.cmake
# Cross-platform LLVM toolchain configuration
# Usage: cmake --preset=<preset> -DCMAKE_TOOLCHAIN_FILE=toolchains/llvm-toolchain.cmake

# LLVM version configuration
set(LLVM_VERSION "" CACHE STRING "LLVM version (14, 16, or empty for auto-detection)")

# Auto-detect LLVM environment from CC/CXX variables
if(NOT LLVM_VERSION AND DEFINED ENV{CC} AND "$ENV{CC}" MATCHES "llvm@([0-9]+)")
    string(REGEX REPLACE ".*llvm@([0-9]+).*" "\\1" DETECTED_VERSION "$ENV{CC}")
    set(LLVM_VERSION "${DETECTED_VERSION}")
    message(STATUS "Auto-detected LLVM version: ${LLVM_VERSION}")
endif()

# Platform-specific LLVM path resolution
if(LLVM_VERSION)
    if(APPLE)
        # macOS with Homebrew
        set(LLVM_PATH "/opt/homebrew/opt/llvm@${LLVM_VERSION}")
        if(NOT EXISTS "${LLVM_PATH}")
            set(LLVM_PATH "/opt/homebrew/opt/llvm")  # Fallback to latest
        endif()
    elseif(UNIX)
        # Linux with package manager or SCL
        find_path(LLVM_PATH_ROOT 
            NAMES bin/clang-${LLVM_VERSION} bin/clang
            PATHS 
                /usr/lib/llvm-${LLVM_VERSION}           # Ubuntu/Debian
                /opt/rh/llvm-toolset-${LLVM_VERSION}/root/usr  # RHEL SCL
                /usr/local/llvm-${LLVM_VERSION}         # Manual install
            NO_DEFAULT_PATH
        )
        if(LLVM_PATH_ROOT)
            set(LLVM_PATH "${LLVM_PATH_ROOT}")
        endif()
    endif()
endif()

# Configure compilers and tools
if(LLVM_PATH AND EXISTS "${LLVM_PATH}")
    message(STATUS "Using LLVM toolchain: ${LLVM_PATH}")
    
    # Compilers
    set(CMAKE_C_COMPILER   "${LLVM_PATH}/bin/clang"   CACHE FILEPATH "C compiler" FORCE)
    set(CMAKE_CXX_COMPILER "${LLVM_PATH}/bin/clang++" CACHE FILEPATH "C++ compiler" FORCE)
    
    # Tools (prefer system standard for better compatibility)
    if(APPLE)
        # macOS: Use system ar/ranlib for compatibility
        find_program(SYSTEM_AR ar PATHS /usr/bin /bin NO_DEFAULT_PATH)
        find_program(SYSTEM_RANLIB ranlib PATHS /usr/bin /bin NO_DEFAULT_PATH)
        if(SYSTEM_AR AND SYSTEM_RANLIB)
            set(CMAKE_AR "${SYSTEM_AR}" CACHE FILEPATH "Archiver" FORCE)
            set(CMAKE_RANLIB "${SYSTEM_RANLIB}" CACHE FILEPATH "Ranlib" FORCE)
            message(STATUS "Using system ar/ranlib for macOS compatibility")
        endif()
    else()
        # Linux: Use LLVM tools if available
        if(EXISTS "${LLVM_PATH}/bin/llvm-ar")
            set(CMAKE_AR "${LLVM_PATH}/bin/llvm-ar" CACHE FILEPATH "Archiver" FORCE)
        endif()
        if(EXISTS "${LLVM_PATH}/bin/llvm-ranlib")
            set(CMAKE_RANLIB "${LLVM_PATH}/bin/llvm-ranlib" CACHE FILEPATH "Ranlib" FORCE)
        endif()
    endif()
    
    # Environment flags
    set(ENV{CPPFLAGS} "-I${LLVM_PATH}/include")
    if(EXISTS "${LLVM_PATH}/lib")
        set(ENV{LDFLAGS} "-L${LLVM_PATH}/lib")
        set(ENV{PKG_CONFIG_PATH} "${LLVM_PATH}/lib/pkgconfig")
    endif()
    
else()
    # System default compilers
    message(STATUS "Using system default toolchain")
    find_program(CMAKE_C_COMPILER NAMES clang gcc cc)
    find_program(CMAKE_CXX_COMPILER NAMES clang++ g++ c++)
    
    if(NOT CMAKE_C_COMPILER OR NOT CMAKE_CXX_COMPILER)
        message(FATAL_ERROR "No suitable C/C++ compiler found")
    endif()
endif()

# Display configuration
message(STATUS "Toolchain configuration:")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  CXX Compiler: ${CMAKE_CXX_COMPILER}")
if(CMAKE_AR)
    message(STATUS "  Archiver: ${CMAKE_AR}")
endif()
if(CMAKE_RANLIB)
    message(STATUS "  Ranlib: ${CMAKE_RANLIB}")
endif()