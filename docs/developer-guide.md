# 開発者向けガイド

nanobind使用C++/Pythonバインディングプロジェクトの開発環境構築・デバッグ・品質管理ガイドです。

## 🚀 環境構築

- aa
    - aa

```bash
git clone <repo>
cd <dir>
git submodule update --init --recursive
uv sync
```

## 🌍 クロスプラットフォーム対応

CMakePresets.jsonを使用して環境別の設定を分離しています。

## 🎯 設計思想: ビルドとツールの分離

**コンパイル**:

- **macOS**: システム標準 (Apple Clang)
- **Linux**: GCC優先 (互換性・安定性重視)

**品質管理ツール**:

- **全環境**: LLVM (clang-format, clang-tidy) 優先
- **分離理由**: 最新の静的解析とフォーマット機能を活用

### 利用可能なプリセット

| プリセット   | 環境          | コンパイラ   | 品質ツール    | 説明           |
| ------------ | ------------- | ------------ | ------------- | -------------- |
| `default`    | 汎用          | システム標準 | システム標準  | 基本設定       |
| `debug`      | 汎用          | システム標準 | システム標準  | デバッグビルド |
| `macos`      | macOS         | Apple Clang  | Homebrew LLVM | macOS推奨設定  |
| `ubuntu`     | Ubuntu/Debian | GCC          | LLVM          | Ubuntu推奨設定 |
| `rhel`       | RHEL系        | GCC          | LLVM (SCL)    | RHEL系推奨設定 |
| `llvm-build` | 汎用          | LLVM         | LLVM          | LLVM統一環境   |
| `ci`         | CI環境        | システム標準 | 無効          | CI最適化       |

### プリセット使用方法

```bash
# 推奨: GCC + LLVM品質ツール
cmake --preset=ubuntu        # Ubuntu: GCC + LLVM品質ツール
cmake --build --preset=ubuntu-debug

cmake --preset=rhel          # RHEL系: GCC + LLVM品質ツール  
cmake --build --preset=rhel-debug

# オプション: LLVM統一環境
cmake --preset=llvm-build    # すべてLLVM
cmake --build --preset=llvm-build-debug

# 分離実行
cmake --preset=ubuntu        # 設定のみ
cmake --build build          # ビルドのみ
make format lint             # 品質チェック
```

## ⚙️ 設定ファイル概要

| ファイル                          | 目的               | 使用方法                       |
| --------------------------------- | ------------------ | ------------------------------ |
| `CMakePresets.json`               | 環境別ビルド設定   | `cmake --preset=<name>`        |
| `CMakeLists.txt`                  | C++ビルド制御      | プリセットから自動読み込み     |
| `cmake/quality-tools.cmake`       | 品質管理ツール設定 | CMakeLists.txtから自動読み込み |
| `toolchains/llvm-toolchain.cmake` | LLVM統一環境       | `llvm-build`プリセット使用     |
| `.vscode/launch.json`             | VSCodeデバッグ設定 | F5でデバッグ開始               |
| `.vscode/tasks.json`              | VSCodeビルドタスク | Ctrl+Shift+Pでタスク実行       |
| `.clang-format`                   | フォーマットルール | 自動適用                       |
| `.clang-tidy`                     | 静的解析ルール     | 自動適用                       |

## 🔨 ビルド

### Python統合ビルド（推奨）

```bash
# システム標準コンパイラを使用（推奨）
unset CC CXX
uv pip install -e .
```

### C++直接ビルド（デバッグ用）

#### プリセット使用（推奨）

```bash
# 環境に応じてプリセット選択
cmake --preset=ubuntu          # Ubuntu
cmake --preset=macos           # macOS
cmake --preset=rhel            # RHEL系

# デバッグビルド実行
cmake --build --preset=ubuntu-debug
cmake --build --preset=rhel-debug
```

#### 従来方式（プリセット未対応環境）

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

#### 生成されるファイル

```text
build/src/bindings/_nanobind_module.*.so
build/debug/debug_main  # デバッグ用実行ファイル
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

### 品質管理ツールインストール

#### macOS (Homebrew)

```bash
brew install cmake cppcheck llvm@16
```

#### Linux（管理者権限あり）

```bash
# Ubuntu/Debian
sudo apt install build-essential cmake cppcheck clang-format clang-tidy

# RHEL系
sudo yum install cmake3 cppcheck clang-tools-extra
# または
sudo dnf install cmake cppcheck clang-tools-extra
```

#### Linux（管理者権限なし）

```bash
# miseインストール
curl https://mise.run | sh

# ツールインストール
mise install cmake@4.1.0 llvm@16
mise use -g cmake@4.1.0 llvm@16

# cppcheckソースビルド
cd /tmp
curl -L https://github.com/danmar/cppcheck/archive/2.18.0.tar.gz | tar -xz
cd cppcheck-*
make -j MATCHCOMPILER=yes HAVE_RULES=yes CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function"
make install PREFIX=$HOME/.local FILESDIR=$HOME/.local/share/cppcheck
```

### C++品質チェック（CMake）

#### 基本コマンド

```bash
# 全体チェック
cmake --build build --target check              # 全チェック（format + lint + cppcheck）
cmake --build build --target list-quality-targets # 利用可能なターゲット一覧表示

# 個別チェック
cmake --build build --target format             # clang-formatでコード整形
cmake --build build --target format-dry         # フォーマットチェック（変更なし）
cmake --build build --target lint               # clang-tidyでリント
cmake --build build --target run-cppcheck       # cppcheck基本静的解析
cmake --build build --target run-cppcheck-verbose # cppcheck詳細出力
```

#### clang static analyzer（詳細解析）

```bash
cmake --build build --target static-analysis    # 静的解析実行
cmake --build build --target view-analysis      # 解析結果をブラウザで表示
cmake --build build --target quick-analysis     # エラーを無視して継続実行
```

**注意**: `static-analysis`は`check`ターゲットに含まれません（リソース集約的なため）

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

| コマンド         | LLDB            | GDB             | 動作             |
| ---------------- | --------------- | --------------- | ---------------- |
| ブレークポイント | `b file.cpp:10` | `b file.cpp:10` | 行にブレーク設定 |
| 実行開始         | `run`           | `run`           | プログラム実行   |
| ステップオーバー | `next`          | `next`          | 次の行           |
| ステップイン     | `step`          | `step`          | 関数内に入る     |
| 変数表示         | `p var`         | `p var`         | 変数値表示       |
| 継続実行         | `c`             | `c`             | 次のブレークまで |
| 終了             | `q`             | `q`             | デバッガ終了     |

---

詳細なコーディング規約は [development-rules.md](development-rules.md) を参照してください。
