#!/usr/bin/env bash
# ビルド済みwheelを生成するスクリプト
# 使い方: ./scripts/build_wheels.sh [platform]
#   platform: linux, macos, all (デフォルト: 現在のプラットフォーム)
#
# macOS: uv build で現在の環境向けabi3 wheelを生成
# Linux: cibuildwheel + Docker でmanylinux wheelを生成
#
# 前提条件:
#   - uv がインストール済み
#   - Linux wheelの生成にはDockerが必要
#   - git submodule が初期化済み
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_ROOT}"

# git submodule の確認
if [ ! -f "ext/nanobind/CMakeLists.txt" ]; then
    echo "nanobind submodule を初期化しています..."
    git submodule update --init --recursive
fi

PLATFORM="${1:-auto}"

if [ "${PLATFORM}" = "auto" ]; then
    case "$(uname -s)" in
        Linux)  PLATFORM="linux" ;;
        Darwin) PLATFORM="macos" ;;
        *)
            echo "エラー: サポートされていないプラットフォームです: $(uname -s)"
            exit 1
            ;;
    esac
fi

mkdir -p wheelhouse

echo "=== wheel生成開始 ==="
echo "プラットフォーム: ${PLATFORM}"
echo "出力先: ${PROJECT_ROOT}/wheelhouse/"

build_macos() {
    echo "macOS: uv build でabi3 wheelを生成します..."
    uv build --wheel --out-dir wheelhouse
}

build_linux() {
    echo "Linux: cibuildwheel + Docker でmanylinux wheelを生成します..."
    uvx cibuildwheel --platform linux --output-dir wheelhouse
}

case "${PLATFORM}" in
    linux)
        build_linux
        ;;
    macos)
        build_macos
        ;;
    all)
        echo "全プラットフォームのwheelを生成します..."
        echo ""
        echo "--- Linux (manylinux) ---"
        build_linux
        echo ""
        echo "--- macOS ---"
        build_macos
        ;;
    *)
        echo "エラー: 不明なプラットフォーム: ${PLATFORM}"
        echo "使い方: $0 [linux|macos|all]"
        exit 1
        ;;
esac

echo ""
echo "=== sdist生成 ==="
uv build --sdist --out-dir wheelhouse

echo ""
echo "=== 生成完了 ==="
echo "生成されたファイル:"
ls -la wheelhouse/*.whl wheelhouse/*.tar.gz 2>/dev/null || echo "  (ファイルが見つかりません)"
