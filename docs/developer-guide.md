# 開発者向けガイド

nanobind使用C++/Pythonバインディングプロジェクトの開発環境構築・デバッグ・品質管理ガイドです。

## 🚀 環境構築

```bash
git clone <repo>
cd <dir>
git submodule update --init --recursive
uv sync
```

## ⚙️ 設定ファイル概要

| ファイル | 目的 | 使用方法 |
|----------|------|----------|
| `pyproject.toml` | Python設定・依存関係 | `uv sync`で読み込み |
| `CMakeLists.txt` | C++ビルド・品質ツール | `cmake ..`で読み込み |
| `.vscode/launch.json` | VSCodeデバッグ設定 | F5でデバッグ開始 |
| `.vscode/tasks.json` | VSCodeビルドタスク | Ctrl+Shift+Pでタスク実行 |
| `.clang-format` | C++コードフォーマット | `make format`で適用 |
| `.clang-tidy` | C++静的解析 | `make lint`で実行 |

## 🔨 ビルド

### Python統合ビルド（推奨）
```bash
# システム標準コンパイラを使用（推奨）
unset CC CXX
uv pip install -e .
```

### C++直接ビルド（デバッグ用）
```bash
cmake -S . -B build
cmake --build build
```

生成されるファイル:
```
build/src/bindings/_nanobind_module.*.so
build/debug/main_debug  # デバッグ用実行ファイル
```

### ⚠️ LLVM14環境での注意事項

`use_llvm14`使用時はPythonバインディングが正常に動作しない場合があります：

```bash
# ❌ 問題：llvm14でビルドした場合
use_llvm14
uv pip install -e .
python -c "import template_bind_cpp_python"  # 実行時エラー

# ✅ 解決策：システム標準コンパイラでビルド
unset CC CXX  # LLVM14環境をリセット
rm -rf build/ .venv/lib/python*/site-packages/template_bind_cpp_python*
uv pip install -e .
```

**原因**: llvm14のリンカがmacOS互換性のないバイナリを生成するため

## 🛠️ 品質管理ツール

### 必要ツールインストール
```bash
# Python: uv syncで自動インストール
# C++ (macOS)
brew install cppcheck
# C++ (Ubuntu)
sudo apt install cppcheck
```

### C++品質チェック（CMake）
```bash
cmake --build build --target check  # 全チェック
cmake --build build --target format # フォーマット
cmake --build build --target lint   # clang-tidy
cmake --build build --target run-cppcheck # 静的解析
```

### Python品質チェック（taskipy）
```bash
task check     # 全チェック
task format    # ruffフォーマット
task lint      # ruffリント
task typecheck # pyright
task test      # pytest
```

## 📋 型ヒント対応状況

### 🚨 開発中の制約
プロジェクト開発中は `src/template_bind_cpp_python/` に`.pyi`ファイルを配置していないため、**型ヒントは利用できません**。

### ✅ 型ヒント利用方法
別ディレクトリでインストール後に型ヒントが利用可能:
```bash
# 別ディレクトリで
uv pip install -e /path/to/template_bind_cpp_python
# 型ヒント利用可能
```

## 🐛 C++デバッグ

### VSCodeデバッグ（推奨）
1. **準備**: `.vscode/launch.json`、`.vscode/tasks.json` が設定済み
2. **開始**: VSCodeで **F5** を押すかデバッグビューで「▶️ 開始」
3. **操作**: ブレークポイント設定後、GUIで直感的にデバッグ

### コンソールデバッグ（必要に応じて）
```bash
# デバッグビルド
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build

# LLDB起動 (macOS)
lldb build/debug/main_debug
# GDB起動 (Linux)
gdb build/debug/main_debug
```

### 共通デバッグコマンド
| コマンド | LLDB | GDB | 動作 |
|----------|------|-----|------|
| ブレークポイント | `b file.cpp:10` | `b file.cpp:10` | 行にブレーク設定 |
| 実行開始 | `run` | `run` | プログラム実行 |
| ステップオーバー | `next` | `next` | 次の行 |
| ステップイン | `step` | `step` | 関数内に入る |
| 変数表示 | `p var` | `p var` | 変数値表示 |
| 継続実行 | `c` | `c` | 次のブレークまで |
| 終了 | `q` | `q` | デバッガ終了 |

---

詳細なコーディング規約は [development-rules.md](development-rules.md) を参照してください。
