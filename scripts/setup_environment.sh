#!/usr/bin/env bash
set -euo pipefail

# 環境自動判定とセットアップスクリプト
# Usage: ./scripts/setup_environment.sh [preset_name] [--install-tools]

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_ROOT}"

# OS検出
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f "/etc/os-release" ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian) echo "ubuntu" ;;
            amzn|centos|rhel|fedora|almalinux|rocky) echo "rhel" ;;
            *) echo "linux" ;;
        esac
    else
        echo "linux"
    fi
}

# ユーザーローカル環境セットアップ
setup_local_env() {
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
    
    # シェル設定に追加
    local shell_rc=""
    [[ -n "${BASH_VERSION:-}" ]] && shell_rc="$HOME/.bashrc"
    [[ -n "${ZSH_VERSION:-}" ]] && shell_rc="$HOME/.zshrc"
    
    if [[ -n "$shell_rc" ]] && ! grep -q "\.local/bin" "$shell_rc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
    fi
}

# cppcheckインストール
install_cppcheck() {
    local os_type="$1"
    
    if command -v cppcheck >/dev/null 2>&1; then
        return 0
    fi
    
    case "$os_type" in
        macos)
            echo "❌ cppcheck未インストール。実行: brew install cppcheck"
            return 1
            ;;
        ubuntu)
            if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
                sudo apt install -y cppcheck
            else
                echo "📦 cppcheckをソースからビルド中..."
                local temp_dir=$(mktemp -d)
                cd "$temp_dir"
                curl -L https://github.com/danmar/cppcheck/archive/2.18.0.tar.gz | tar -xz
                cd cppcheck-*
                make -j"$(nproc)" MATCHCOMPILER=yes FILESDIR="$HOME/.local/share/cppcheck"
                make install PREFIX="$HOME/.local" FILESDIR="$HOME/.local/share/cppcheck"
                rm -rf "$temp_dir"
            fi
            ;;
        rhel)
            if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
                sudo yum install -y cppcheck || sudo dnf install -y cppcheck
            else
                echo "📦 cppcheckをソースからビルド中..."
                local temp_dir=$(mktemp -d)
                cd "$temp_dir"
                curl -L https://github.com/danmar/cppcheck/archive/2.18.0.tar.gz | tar -xz
                cd cppcheck-*
                make -j"$(nproc)" MATCHCOMPILER=yes FILESDIR="$HOME/.local/share/cppcheck"
                make install PREFIX="$HOME/.local" FILESDIR="$HOME/.local/share/cppcheck"
                rm -rf "$temp_dir"
            fi
            ;;
        *)
            echo "📦 cppcheckをソースからビルド中..."
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -L https://github.com/danmar/cppcheck/archive/2.13.0.tar.gz | tar -xz
            cd cppcheck-*
            make -j"$(nproc 2>/dev/null || echo 2)" MATCHCOMPILER=yes FILESDIR="$HOME/.local/share/cppcheck"
            make install PREFIX="$HOME/.local" FILESDIR="$HOME/.local/share/cppcheck"
            rm -rf "$temp_dir"
            ;;
    esac
}

# LLVM toolsインストール
install_llvm_tools() {
    local os_type="$1"
    
    if command -v clang-format >/dev/null 2>&1 && command -v clang-tidy >/dev/null 2>&1; then
        return 0
    fi
    
    case "$os_type" in
        macos)
            echo "❌ LLVM tools未インストール。実行: brew install llvm"
            return 1
            ;;
        ubuntu)
            local llvm_url="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/clang+llvm-16.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz"
            ;;
        rhel)
            local llvm_url="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/clang+llvm-16.0.6-x86_64-linux-gnu-rhel86.tar.xz"
            ;;
        *)
            local llvm_url="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/clang+llvm-16.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz"
            ;;
    esac
    
    echo "📦 LLVM toolsをダウンロード中..."
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    curl -L -o llvm.tar.xz "$llvm_url"
    tar -xf llvm.tar.xz
    
    local llvm_dir=$(find . -name "clang+llvm-*" -type d | head -n1)
    cp "$llvm_dir/bin/clang-format" "$HOME/.local/bin/" 2>/dev/null || true
    cp "$llvm_dir/bin/clang-tidy" "$HOME/.local/bin/" 2>/dev/null || true
    cp "$llvm_dir/bin/scan-build" "$HOME/.local/bin/" 2>/dev/null || true
    
    rm -rf "$temp_dir"
}

# CMakeインストール
install_cmake() {
    local os_type="$1"
    
    if command -v cmake >/dev/null 2>&1; then
        return 0
    fi
    
    case "$os_type" in
        macos)
            echo "❌ CMake未インストール。実行: brew install cmake"
            return 1
            ;;
        *)
            echo "📦 CMakeをダウンロード中..."
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            
            local cmake_url="https://github.com/Kitware/CMake/releases/download/v3.31.0/cmake-3.31.0-linux-x86_64.tar.gz"
            curl -L -o cmake.tar.gz "$cmake_url"
            tar -xf cmake.tar.gz
            
            local cmake_dir=$(find . -name "cmake-*" -type d | head -n1)
            cp -r "$cmake_dir/bin"/* "$HOME/.local/bin/"
            cp -r "$cmake_dir/share"/* "$HOME/.local/share/" 2>/dev/null || true
            
            rm -rf "$temp_dir"
            ;;
    esac
}

# メイン処理
main() {
    local auto_install=false
    local preset_name=""
    
    # 引数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-tools) auto_install=true; shift ;;
            --help|-h)
                echo "Usage: $0 [preset_name] [--install-tools]"
                echo "  preset_name: ubuntu, rhel, macos, etc."
                echo "  --install-tools: 品質管理ツールを自動インストール"
                exit 0
                ;;
            -*) echo "Unknown option: $1"; exit 1 ;;
            *) preset_name="$1"; shift ;;
        esac
    done
    
    # OS検出とプリセット決定
    local os_type=$(detect_os)
    [[ -z "$preset_name" ]] && preset_name="$os_type"
    
    echo "🚀 環境セットアップ開始 (OS: $os_type, プリセット: $preset_name)"
    
    # Python環境チェック
    if [[ ! -d ".venv" ]]; then
        echo "❌ Python仮想環境が見つかりません。実行: uv sync"
        exit 1
    fi
    
    # ツールインストール
    if [[ "$auto_install" == "true" ]]; then
        setup_local_env
        
        echo "🔧 ツールインストール中..."
        install_cmake "$os_type" || exit 1
        install_cppcheck "$os_type" || exit 1
        install_llvm_tools "$os_type" || exit 1
        
        echo "✅ ツールインストール完了"
        echo "💡 新しいターミナルを開くか、以下を実行: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    
    # CMakeプリセット確認
    if [[ ! -f "CMakePresets.json" ]]; then
        echo "❌ CMakePresets.json が見つかりません"
        exit 1
    fi
    
    # CMakeセットアップとビルド
    echo "🔧 CMake設定中..."
    cmake --preset="$preset_name" || {
        echo "❌ CMake設定失敗。利用可能プリセット:"
        cmake --list-presets 2>/dev/null || echo "  プリセット一覧の取得失敗"
        exit 1
    }
    
    echo "🏗️ ビルド中..."
    cmake --build --preset="$preset_name" || {
        echo "❌ ビルド失敗"
        exit 1
    }
    
    echo ""
    echo "🎉 セットアップ完了！"
    echo "📋 次のステップ:"
    echo "   • テスト実行: cmake --build build --target test"
    echo "   • 品質チェック: cmake --build build --target check"
    echo "   • Python統合: uv pip install -e ."
}

main "$@"