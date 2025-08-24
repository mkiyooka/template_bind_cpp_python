#!/usr/bin/env bash
set -euo pipefail

# 環境自動判定とセットアップスクリプト
# Usage: ./scripts/setup_environment.sh [preset_name]

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_ROOT}"

# OS検出
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f "/etc/os-release" ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                echo "ubuntu"
                ;;
            amzn|centos|rhel|fedora|almalinux|rocky)
                echo "rhel"  # RHEL系統合
                ;;
            *)
                echo "default"
                ;;
        esac
    else
        echo "default"
    fi
}

# コマンドライン引数解析
AUTO_INSTALL_TOOLS=false
PRESET_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --install-tools)
            AUTO_INSTALL_TOOLS=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options] [preset_name]"
            echo "Options:"
            echo "  --install-tools    自動的に品質管理ツールをインストール"
            echo "  --help, -h         このヘルプを表示"
            echo ""
            echo "Available presets:"
            echo "  ubuntu, rhel, macos, llvm-build, ci"
            echo ""
            echo "Examples:"
            echo "  $0                    # 環境自動検出"
            echo "  $0 ubuntu            # Ubuntuプリセット使用"
            echo "  $0 --install-tools   # 品質ツール自動インストール"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            PRESET_NAME="$1"
            shift
            ;;
    esac
done

# プリセット決定
if [[ -z "$PRESET_NAME" ]]; then
    OS_TYPE=$(detect_os)
    PRESET_NAME="${OS_TYPE}"
    echo "✅ 環境自動検出: $OS_TYPE (プリセット: $PRESET_NAME)"
else
    OS_TYPE=$(detect_os)
    echo "✅ 指定プリセット: $PRESET_NAME (検出環境: $OS_TYPE)"
fi

# 依存関係チェック・インストール案内
check_dependencies() {
    local os_type="$1"
    
    echo "🔍 依存関係確認中..."
    
    # 共通チェック
    if ! command -v cmake >/dev/null 2>&1; then
        echo "❌ CMakeが見つかりません"
        case "$os_type" in
            macos)
                echo "💡 インストール: brew install cmake"
                ;;
            ubuntu)
                echo "💡 インストール: sudo apt install cmake"
                ;;
            rhel)
                echo "💡 インストール: sudo yum install cmake3"
                ;;
        esac
        exit 1
    fi
    
    # Python環境
    if [[ ! -d ".venv" ]]; then
        echo "❌ Python仮想環境が見つかりません"
        echo "💡 実行: uv sync"
        exit 1
    fi
    
    echo "✅ 必要な依存関係が確認できました"
}

# 品質ツールチェック・自動インストール
check_quality_tools() {
    local os_type="$1"
    local auto_install="${2:-false}"
    
    echo "🔍 品質管理ツール確認中..."
    
    local missing_tools=()
    local install_commands=()
    
    # cppcheck チェック
    if ! command -v cppcheck >/dev/null 2>&1; then
        missing_tools+=("cppcheck")
        case "$os_type" in
            macos)
                install_commands+=("brew install cppcheck")
                ;;
            ubuntu)
                install_commands+=("sudo apt install -y cppcheck")
                ;;
            rhel)
                install_commands+=("sudo yum install -y cppcheck")
                ;;
        esac
    fi
    
    # clang-format チェック
    if ! command -v clang-format >/dev/null 2>&1; then
        missing_tools+=("clang-format")
        case "$os_type" in
            macos)
                install_commands+=("brew install llvm")
                ;;
            ubuntu)
                install_commands+=("sudo apt install -y clang-format")
                ;;
            rhel)
                # RHEL系ではSCL LLVMを推奨
                install_commands+=("sudo yum install -y centos-release-scl")
                install_commands+=("sudo yum install -y llvm-toolset-13")
                ;;
        esac
    fi
    
    # clang-tidy チェック
    if ! command -v clang-tidy >/dev/null 2>&1; then
        if [[ ! " ${missing_tools[*]} " =~ " clang-format " ]]; then
            missing_tools+=("clang-tidy")
            case "$os_type" in
                macos)
                    install_commands+=("brew install llvm")
                    ;;
                ubuntu)
                    install_commands+=("sudo apt install -y clang-tidy")
                    ;;
                rhel)
                    # clang-formatと同じSCLパッケージに含まれる
                    ;;
            esac
        fi
    fi
    
    # scan-build (clang static analyzer) チェック
    if ! command -v scan-build >/dev/null 2>&1; then
        if [[ ! " ${missing_tools[*]} " =~ " clang-format " ]]; then
            missing_tools+=("scan-build")
            case "$os_type" in
                macos)
                    # LLVMパッケージにscan-buildも含まれる
                    if [[ ! " ${install_commands[*]} " =~ " brew install llvm " ]]; then
                        install_commands+=("brew install llvm")
                    fi
                    ;;
                ubuntu)
                    install_commands+=("sudo apt install -y clang-tools")
                    ;;
                rhel)
                    # SCL LLVMパッケージにscan-buildも含まれる
                    ;;
            esac
        fi
    fi
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        echo "✅ 品質管理ツールが利用可能です"
        return 0
    fi
    
    echo "⚠️  未インストールツール: ${missing_tools[*]}"
    
    if [[ "$auto_install" == "true" ]]; then
        echo "🔧 自動インストールを実行中..."
        for cmd in "${install_commands[@]}"; do
            echo "実行中: $cmd"
            if eval "$cmd"; then
                echo "✅ インストール成功: $cmd"
            else
                echo "❌ インストール失敗: $cmd"
                return 1
            fi
        done
        
        # RHEL系の場合、SCL環境の説明
        if [[ "$os_type" == "rhel" ]] && [[ " ${missing_tools[*]} " =~ " clang-format " ]]; then
            echo ""
            echo "📋 RHEL系でLLVM使用時の注意:"
            echo "   品質チェック時は以下を実行してください:"
            echo "   scl enable llvm-toolset-13 'cmake --build build --target format lint'"
        fi
        
        echo "✅ 品質管理ツールのインストール完了"
    else
        echo "💡 自動インストール用コマンド:"
        for cmd in "${install_commands[@]}"; do
            echo "   $cmd"
        done
        echo ""
        echo "💡 自動インストールするには --install-tools オプションを使用"
        echo "   例: $0 --install-tools"
    fi
}

# メイン処理
main() {
    echo "🚀 環境セットアップを開始します"
    echo "📁 プロジェクト: $(basename "$PROJECT_ROOT")"
    
    # OS検出とプリセット決定
    OS_TYPE=$(detect_os)
    
    # 依存関係確認
    check_dependencies "$OS_TYPE"
    check_quality_tools "$OS_TYPE" "$AUTO_INSTALL_TOOLS"
    
    # CMakeプリセット確認
    if [[ ! -f "CMakePresets.json" ]]; then
        echo "❌ CMakePresets.json が見つかりません"
        exit 1
    fi
    
    echo "🔧 CMake設定実行中... (プリセット: $PRESET_NAME)"
    if ! cmake --preset="$PRESET_NAME"; then
        echo "❌ CMake設定に失敗しました"
        echo "💡 利用可能なプリセット:"
        cmake --list-presets 2>/dev/null | grep "^  " || echo "  プリセット一覧の取得に失敗"
        exit 1
    fi
    
    echo "🏗️  ビルド実行中..."
    if ! cmake --build --preset="$PRESET_NAME"; then
        echo "❌ ビルドに失敗しました"
        exit 1
    fi
    
    echo ""
    echo "🎉 セットアップ完了！"
    echo "📋 次のステップ:"
    echo "   • テスト実行: cmake --build build --target test"
    echo "   • 品質チェック: cmake --build build --target check"
    echo "   • Python統合: uv pip install -e ."
    echo "   • ベンチマーク: python scripts/benchmark_hamming.py"
}

# メイン実行
main