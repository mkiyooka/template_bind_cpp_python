# File: toolchains/llvm-toolchain.cmake

# LLVMバージョンを指定 (例: 14, 16)
set(LLVM_VERSION "14" CACHE STRING "LLVM version to use (14, 16 or empty for system default)")

# brew/apt系のLLVMパスを設定
if(LLVM_VERSION STREQUAL "")
    set(LLVM_PATH "")
elseif(LLVM_VERSION MATCHES "^[0-9]+$")
    set(LLVM_PATH "/opt/homebrew/opt/llvm@${LLVM_VERSION}")
else()
    message(FATAL_ERROR "Unsupported LLVM_VERSION: ${LLVM_VERSION}")
endif()

if(LLVM_PATH)
    set(CMAKE_C_COMPILER   "${LLVM_PATH}/bin/clang"    CACHE FILEPATH "C compiler" FORCE)
    set(CMAKE_CXX_COMPILER "${LLVM_PATH}/bin/clang++"  CACHE FILEPATH "C++ compiler" FORCE)
    set(CMAKE_AR           "${LLVM_PATH}/bin/llvm-ar"  CACHE FILEPATH "Archiver" FORCE)
    set(CMAKE_RANLIB       "${LLVM_PATH}/bin/llvm-ranlib" CACHE FILEPATH "Ranlib" FORCE)
    set(CMAKE_LINKER       "${LLVM_PATH}/bin/clang++" CACHE FILEPATH "Linker" FORCE)

    # フラグ設定
    set(ENV{LDFLAGS} "-L${LLVM_PATH}/lib -L${LLVM_PATH}/lib/c++ -Wl,-rpath,${LLVM_PATH}/lib -Wl,-rpath,${LLVM_PATH}/lib/c++")
    set(ENV{CPPFLAGS} "-I${LLVM_PATH}/include")
    set(ENV{PKG_CONFIG_PATH} "${LLVM_PATH}/lib/pkgconfig")
else()
    # システムデフォルト
    set(CMAKE_C_COMPILER   "clang" CACHE FILEPATH "C compiler" FORCE)
    set(CMAKE_CXX_COMPILER "clang++" CACHE FILEPATH "C++ compiler" FORCE)
    set(CMAKE_AR           "ar" CACHE FILEPATH "Archiver" FORCE)
    set(CMAKE_RANLIB       "ranlib" CACHE FILEPATH "Ranlib" FORCE)
    set(CMAKE_LINKER       "clang++" CACHE FILEPATH "Linker" FORCE)
endif()

message(STATUS "Using LLVM at: ${LLVM_PATH:-system default}")
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX Compiler: ${CMAKE_CXX_COMPILER}")
