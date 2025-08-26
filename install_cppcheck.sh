#!/bin/bash
curl -S -O https://github.com/danmar/cppcheck/archive/refs/tags/2.18.0.tar.gz
tar -xzvf 2.18.0.tar.gz


# scripts/install_cppcheck_managed.sh
"""cppcheck installation with package management."""

set -e


install_cppcheck_from_source() {
    local INSTALL_BASE="$HOME/.local/bin/cppcheck"
    local REGISTRY_DIR="$HOME/.local/registry"
    local CPPCHECK_VERSION="2.18.0"

    local build_dir="./cppcheck-build"
    
    echo "Building cppcheck $CPPCHECK_VERSION from source..."
    
    mkdir -p "$build_dir"
    cd "$build_dir"
    
    # ソースダウンロード
    curl -L -O "https://github.com/danmar/cppcheck/archive/refs/tags/$CPPCHECK_VERSION.tar.gz"
    tar -xzf "$CPPCHECK_VERSION.tar.gz"
    cd "cppcheck-$CPPCHECK_VERSION"
    mkdir build
    cd build
    cmake ..
    cmake --build .
    # 最適化ビルド
    make MATCHCOMPILER=yes FILESDIR="$INSTALL_BASE/share/cppcheck" \
         HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG" -j$(nproc) \
         PREFIX="$INSTALL_BASE"
    
    # インストール
    make install PREFIX="$INSTALL_BASE"

    rm -rf "$build_dir"

    echo "cppcheck built and installed to $INSTALL_BASE"
}

install_cppcheck_from_source
