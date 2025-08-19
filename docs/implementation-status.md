# 実装状況

## Python開発環境

- [x] パッケージ管理ツールに`uv`を利用
- [x] パッケージ管理の設定ファイルは`pyproject.toml`を利用
- [x] テスト導入: pytest
- [x] 型チェック導入: pyright
- [x] コードフォーマッタ導入: ruff format
- [x] リンタ導入: ruff check
- [x] テスト導入: nox
- [x] pre-commit導入

## C++開発環境

- [x] Pythonのビルドシステムに`scikit_build_core`を利用して、`pip install`でビルド可能にする
- [x] C++コードのデバッグのため`cmake`から直接ビルド可能にする
- [x] CTestによるテストを導入する
- [x] コンソールで`gdb/lldb`を使ってデバッグするための設定
    - [x] `CMakeLists.txt` にデバッグシンボルを生成する設定を追加
    - [x] `gdb/lldb` で実行可能なバイナリをビルドする手順を確立
    - [x] `gdb/lldb` を使ってC++コードをデバッグする手順をドキュメント化
- [x] VSCodeから`gdb/lldb`を使ってデバッグするための設定
    - [x] `.vscode/tasks.json` を作成し、デバッグ用ビルド設定を追加
    - [x] `.vscode/launch.json` を作成し、デバッグ設定を追加
    - [x] VSCodeからC++コードをデバッグする手順をドキュメント化
    - [x] VSCode cmake extensionでの自動ビルド失敗不具合を修正
- [x] コードフォーマッタ導入: clangd, clang-format (CMake経由で実行できるように設定)
- [x] リンタ導入: clangd, clang-tidy (CMake経由で実行できるように設定)
- [x] 静的解析ツール導入: cppcheck (CMake経由で実行できるように設定)

## Pythonプログラム

- [ ] VSCodeでの型ヒント対応
    - [ ] `src/template_bind_cpp_python/__init__.pyi` の内容を整備
    - [ ] `pyright` の設定を確認し、必要であれば修正
    - [ ] VSCodeで型ヒントが正しく表示されることを確認

## 乱数生成クラスの実装

- [x] 使用言語: C++
- [x] `std::random`の`mt19937`を利用
- [x] $U[0,1)$ に従う一様乱数 $X \sim U[0,1)$ を生成するためのクラス`rand`
- [x] 初期化時にseed設定
- [x] `set_seed()`メソッドでseed番号を再初期化
- [x] `next()`メソッドで乱数を1つ生成

## CLIアプリの実装

- [x] 使用言語: Python
- [x] 使用パッケージ: typer (CLI実装)
- [x] `src/template_bind_cpp_python/cli.py`に`unif`コマンドを実装
    - [x] C++で実装したrandクラスを呼び出し
        - [x] 呼び出しにpybind11を利用
        - [x] 呼び出しにnanobindを利用
        - [x] nanobindをpip/venv経由ではなくsubmoduleとする方針に変更
        - [x] pybind11は採用は中止してnanobindに一本化する
    - [x] `bind-demo unif`で乱数を1つ生成
    - [x] `bind-demo unif N`で乱数をN個生成
    - [x] `bind-demo unif --seed SEED N`でseedをSEEDに設定して乱数をN個生成
