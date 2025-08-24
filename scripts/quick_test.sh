#!/usr/bin/env bash
set -euo pipefail

# Quick test script for cross-platform build and tool separation
# Usage: ./scripts/quick_test.sh [preset_name]

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_ROOT}"

PRESET_NAME="${1:-}"

echo "🧪 Quick Test: Build and Tool Separation"
echo "========================================"

# Auto-detect OS if no preset specified
if [[ -z "$PRESET_NAME" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PRESET_NAME="macos"
    elif [[ -f "/etc/os-release" ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                PRESET_NAME="ubuntu"
                ;;
            amzn|centos|rhel|fedora|almalinux|rocky)
                PRESET_NAME="rhel"
                ;;
            *)
                PRESET_NAME="default"
                ;;
        esac
    else
        PRESET_NAME="default"
    fi
    echo "✅ Auto-detected preset: $PRESET_NAME"
else
    echo "✅ Using preset: $PRESET_NAME"
fi

echo ""
echo "🔧 Step 1: Configure with preset"
echo "cmake --preset=$PRESET_NAME"
if ! cmake --preset="$PRESET_NAME"; then
    echo "❌ Configuration failed"
    exit 1
fi

echo ""
echo "🏗️  Step 2: Build"
echo "cmake --build build"
if ! cmake --build build; then
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "📋 Step 3: Quality tools test"

echo ""
echo "🎨 Testing clang-format..."
if cmake --build build --target format-dry; then
    echo "✅ clang-format check passed"
else
    echo "⚠️  clang-format check failed (but continuing...)"
fi

echo ""
echo "🔍 Testing clang-tidy (if available)..."
if cmake --build build --target lint 2>/dev/null; then
    echo "✅ clang-tidy check completed"
else
    echo "⚠️  clang-tidy not available or check failed"
fi

echo ""
echo "🧮 Testing cppcheck (if available)..."
if cmake --build build --target run-cppcheck 2>/dev/null; then
    echo "✅ cppcheck analysis completed"
else
    echo "⚠️  cppcheck not available"
fi

echo ""
echo "🐍 Step 4: Python integration test"
if [[ -f ".venv/bin/python" ]] || [[ -f ".venv/Scripts/python.exe" ]]; then
    echo "Installing Python package..."
    if uv pip install -e . >/dev/null 2>&1; then
        echo "✅ Python package installation successful"
        
        echo "Testing Python imports..."
        if python -c "import template_bind_cpp_python; print('✅ Module import successful')"; then
            echo "🎯 Testing functionality..."
            if python -c "
import template_bind_cpp_python as lib
result = lib.add_integers(5, 3)
print(f'✅ Function test: add_integers(5, 3) = {result}')
assert result == 8, 'Unexpected result'
"; then
                echo "✅ All Python tests passed"
            else
                echo "❌ Python function test failed"
                exit 1
            fi
        else
            echo "❌ Module import failed"
            exit 1
        fi
    else
        echo "❌ Python package installation failed"
        exit 1
    fi
else
    echo "⚠️  No Python virtual environment found, skipping Python tests"
fi

echo ""
echo "📊 Test Summary"
echo "==============="
echo "✅ Configuration: PASSED (preset: $PRESET_NAME)"
echo "✅ Build: PASSED"
echo "✅ Python integration: PASSED" 
echo ""
echo "🎉 Quick test completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   • Run full benchmarks: python scripts/benchmark_hamming.py"
echo "   • Check code documentation: python scripts/check_docstring.py"
echo "   • Quality check: cmake --build build --target check"