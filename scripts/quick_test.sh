#!/usr/bin/env bash
set -euo pipefail

# Quick test script
# Usage: ./scripts/quick_test.sh [preset_name]

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# OS auto-detection
PRESET="${1:-}"
if [[ -z "$PRESET" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PRESET="macos"
    elif [[ -f "/etc/os-release" ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian) PRESET="ubuntu" ;;
            amzn|centos|rhel|fedora|almalinux|rocky) PRESET="rhel" ;;
            *) PRESET="default" ;;
        esac
    else
        PRESET="default"
    fi
fi

echo "🧪 Quick Test (preset: $PRESET)"

# Build
echo "🔧 Configure & Build"
cmake --preset="$PRESET" && cmake --build build

# Quality checks (non-failing)
echo "📋 Quality checks"
cmake --build build --target format-dry 2>/dev/null && echo "✅ format" || echo "⚠️ format"
cmake --build build --target lint 2>/dev/null && echo "✅ lint" || echo "⚠️ lint" 
cmake --build build --target run-cppcheck 2>/dev/null && echo "✅ cppcheck" || echo "⚠️ cppcheck"

# Python integration
echo "🐍 Python integration"
if [[ -d ".venv" ]]; then
    uv pip install -e . >/dev/null
    python -c "import template_bind_cpp_python as lib; assert lib.add_integers(5,3)==8; print('✅ Python test passed')"
else
    echo "⚠️ No .venv found"
fi

echo "🎉 Test completed!"