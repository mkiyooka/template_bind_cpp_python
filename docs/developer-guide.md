# 開発者向けガイド

nanobind使用C++/Pythonバインディングプロジェクトの開発環境構築・ツール利用ガイドです。

## 環境構築

```bash
git clone <repo>
cd <dir>
git submodule update --init --recursive

# Python環境
uv sync

# C++開発環境 (pixi)
pixi install
```

### ツール役割分担

| ツール | 役割                                                                     |
| ------ | ------------------------------------------------------------------------ |
| uv     | Pythonパッケージ管理・仮想環境                                           |
| pixi   | C++ツールチェーン管理 (cmake, ninja, clang-format, clang-tidy, cppcheck) |

## 設定ファイル概要

| ファイル                          | 目的                 | 備考                             |
| --------------------------------- | -------------------- | -------------------------------- |
| `pyproject.toml`                  | Python設定・依存関係 | uv、品質ツール設定               |
| `pixi.toml`                       | C++開発ツール管理    | pixiでcmake, clang-tools等を管理 |
| `CMakePresets.json`               | 環境別ビルド設定     | `cmake --preset=<name>`          |
| `CMakeLists.txt`                  | C++ビルド制御        | compile_commands.json自動コピー  |
| `cmake/quality-tools.cmake`       | 品質管理ツール設定   | clang-format/tidy, cppcheck      |
| `toolchains/llvm-toolchain.cmake` | LLVM統一環境         | `llvm-build`プリセット用         |
| `.vscode/launch.json`             | VSCodeデバッグ設定   | F5でデバッグ開始                 |
| `.clang-format`, `.clang-tidy`    | C++品質ツール        | 自動適用                         |

## 🔨 ビルド

### Python統合ビルド（推奨）

```bash
uv pip install -e .
```

### C++直接ビルド（デバッグ用）

```bash
# 環境に応じてプリセット選択
cmake --preset=ubuntu          # Ubuntu
cmake --preset=macos           # macOS
cmake --preset=rhel            # RHEL系

# デバッグビルド実行
cmake --build --preset=ubuntu-debug
```

## 🛠️ 品質管理ツール

### 一括実行

```bash
# 全体チェック（Python + C++）
task check

# 言語別チェック
task check-py    # Python（ruff format/lint + pyright + pytest）
task check-cpp   # C++（clang-format/tidy + cppcheck + test）
```

### 一覧表示

```bash
# taskipy利用可能タスク一覧
task -l

# CMakeターゲット一覧
task help-cpp
```

### 個別実行例

```bash
# フォーマット（両方式）
task format-py                                  # taskipy経由
cmake --build build --target format            # cmake経由

# リント（両方式）
task lint-cpp                                   # taskipy経由
cmake --build build --target lint              # cmake経由
```

## 🐛 C++デバッグ

### VSCodeデバッグ（推奨）

1. **準備**: `.vscode/launch.json`、`.vscode/tasks.json` が設定済み
2. **開始**: VSCodeで **F5** を押すかデバッグビューで「▶️ 開始」
3. **操作**: ブレークポイント設定後、GUIで直感的にデバッグ

### コンソールデバッグ

```bash
# デバッグビルド
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build

# LLDB起動 (macOS) / GDB起動 (Linux)
lldb build/debug/main_debug
gdb build/debug/main_debug
```

## wheel生成・配布

ビルド済みwheelを生成し、ユーザがソースビルドなしでインストールできるようにする。

### wheel生成

```bash
# 現在のプラットフォーム向け
./scripts/build_wheels.sh

# プラットフォーム指定
./scripts/build_wheels.sh linux    # manylinux wheel (Docker必要)
./scripts/build_wheels.sh macos    # macOS wheel
./scripts/build_wheels.sh all      # 両方
```

生成されたwheelは `wheelhouse/` に出力される。
STABLE_ABI (abi3) を活用しているため、Python 3.10用の1回のビルドで
Python 3.10以降の全バージョンに対応する。

### GitLabへのアップロード

```bash
# 環境変数を設定
export GITLAB_URL="https://gitlab.example.com"
export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
export PROJECT_ID="123"

# Package Registry + Releases にアップロード
./scripts/upload_gitlab.sh

# モード指定
./scripts/upload_gitlab.sh registry  # Package Registryのみ
./scripts/upload_gitlab.sh release   # Releasesのみ
```

### ユーザのインストール方法

```bash
# GitLab Package Registryから
pip install template-bind-cpp-python \
    --index-url https://gitlab.example.com/api/v4/projects/123/packages/pypi/simple

# GitLab Releasesからダウンロードしたwheelを直接
pip install template_bind_cpp_python-0.0.0-cp310-abi3-manylinux_2_28_x86_64.whl
```

---

詳細な開発ルールは [development-rules.md](development-rules.md) を参照してください。
