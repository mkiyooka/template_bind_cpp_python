#!/usr/bin/env bash
# GitLab Package Registry / Releases へのアップロードスクリプト
#
# 環境変数:
#   GITLAB_URL    - GitLabのURL (例: https://gitlab.example.com)
#   GITLAB_TOKEN  - GitLabのアクセストークン (api スコープが必要)
#   PROJECT_ID    - GitLabプロジェクトID
#
# 使い方:
#   export GITLAB_URL="https://gitlab.example.com"
#   export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
#   export PROJECT_ID="123"
#   ./scripts/upload_gitlab.sh [registry|release|both]
#
# 前提条件:
#   - wheelhouse/ に wheel と sdist が生成済み
#   - twine がインストール済み (Package Registry使用時)
#   - curl が利用可能 (Release使用時)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WHEELHOUSE="${PROJECT_ROOT}/wheelhouse"

# 環境変数チェック
check_env() {
    local missing=()
    [ -z "${GITLAB_URL:-}" ] && missing+=("GITLAB_URL")
    [ -z "${GITLAB_TOKEN:-}" ] && missing+=("GITLAB_TOKEN")
    [ -z "${PROJECT_ID:-}" ] && missing+=("PROJECT_ID")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "エラー: 以下の環境変数が設定されていません:"
        for var in "${missing[@]}"; do
            echo "  - ${var}"
        done
        echo ""
        echo "設定例:"
        echo "  export GITLAB_URL=\"https://gitlab.example.com\""
        echo "  export GITLAB_TOKEN=\"glpat-xxxxxxxxxxxx\""
        echo "  export PROJECT_ID=\"123\""
        exit 1
    fi
}

# wheelhouse の確認
check_wheelhouse() {
    if [ ! -d "${WHEELHOUSE}" ] || [ -z "$(ls -A "${WHEELHOUSE}" 2>/dev/null)" ]; then
        echo "エラー: ${WHEELHOUSE} にファイルが見つかりません。"
        echo "先に ./scripts/build_wheels.sh を実行してください。"
        exit 1
    fi
}

# バージョン取得
get_version() {
    cd "${PROJECT_ROOT}"
    python -c "
import tomllib
with open('pyproject.toml', 'rb') as f:
    data = tomllib.load(f)
print(data['project']['version'])
"
}

# GitLab Package Registry へアップロード (twine)
upload_registry() {
    echo "=== GitLab Package Registry へアップロード ==="
    local registry_url="${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/packages/pypi"

    uvx twine upload \
        --repository-url "${registry_url}" \
        --username __token__ \
        --password "${GITLAB_TOKEN}" \
        "${WHEELHOUSE}"/*.whl "${WHEELHOUSE}"/*.tar.gz

    echo ""
    echo "アップロード完了"
    echo "インストール方法:"
    echo "  pip install template-bind-cpp-python --index-url ${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/packages/pypi/simple"
}

# GitLab Release へアップロード
upload_release() {
    echo "=== GitLab Release へアップロード ==="
    local version
    version=$(get_version)
    local tag="v${version}"
    local api_url="${GITLAB_URL}/api/v4/projects/${PROJECT_ID}"

    echo "バージョン: ${version}"
    echo "タグ: ${tag}"

    # タグの存在確認・作成
    local tag_exists
    tag_exists=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        "${api_url}/repository/tags/${tag}")

    if [ "${tag_exists}" != "200" ]; then
        echo "タグ ${tag} を作成します..."
        curl -sf -X POST \
            -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "{\"tag_name\": \"${tag}\", \"ref\": \"main\"}" \
            "${api_url}/repository/tags" > /dev/null
    fi

    # Release 作成
    echo "Release を作成します..."
    curl -sf -X POST \
        -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{\"tag_name\": \"${tag}\", \"description\": \"Release ${version}\"}" \
        "${api_url}/releases" > /dev/null 2>&1 || true

    # ファイルをアップロード
    for file in "${WHEELHOUSE}"/*.whl "${WHEELHOUSE}"/*.tar.gz; do
        [ -f "${file}" ] || continue
        local filename
        filename=$(basename "${file}")
        echo "アップロード中: ${filename}"

        # Generic Package としてアップロード
        local upload_url="${api_url}/packages/generic/template-bind-cpp-python/${version}/${filename}"
        curl -sf -X PUT \
            -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            --upload-file "${file}" \
            "${upload_url}" > /dev/null

        # Release にリンクを追加
        curl -sf -X POST \
            -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "{\"name\": \"${filename}\", \"url\": \"${upload_url}\", \"link_type\": \"package\"}" \
            "${api_url}/releases/${tag}/assets/links" > /dev/null
    done

    echo ""
    echo "Release アップロード完了"
    echo "Release URL: ${GITLAB_URL}/projects/${PROJECT_ID}/-/releases/${tag}"
}

# メイン処理
MODE="${1:-both}"

check_env
check_wheelhouse

case "${MODE}" in
    registry)
        upload_registry
        ;;
    release)
        upload_release
        ;;
    both)
        upload_registry
        echo ""
        upload_release
        ;;
    *)
        echo "エラー: 不明なモード: ${MODE}"
        echo "使い方: $0 [registry|release|both]"
        exit 1
        ;;
esac

echo ""
echo "=== 完了 ==="
