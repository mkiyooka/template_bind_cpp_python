# 開発者向けガイド

このプロジェクトはC++/Pythonバインディングを含む複合プロジェクトです。環境構築・ビルド・品質管理の手順をまとめます。

## 環境セットアップ（uv sync）

1. Python環境は [uv](https://github.com/astral-sh/uv) を利用します。
2. プロジェクトルートで以下を実行してください。

    ```sh
    uv sync
    ```

    これで必要なPythonパッケージがインストールされます。

## CMakeによるビルド・実行

1. ビルドディレクトリを作成し、CMakeでビルドします。

    ```sh
    mkdir build && cd build
    cmake ..
    make
    ```

    buildディレクトリの作成や移動をせずcmakeから実行するには以下のコマンドを実行します。

    ```sh
    cmake -S . -B build
    cmake --build build
    ```

2. 実行ファイルやPythonバインディングは `build/` 以下に生成されます。

    次のようなファイルが生成されます。

    ``` text
    build/src/bindings/_pybind11_module.*.so
    build/src/bindings/_nanobind_module.*.so
    ```

## 静的解析・フォーマットツールのインストール

- C++: `cppcheck` を利用します。

    Ubuntuの場合は以下のコマンドでインストールできます。

    ```sh
    sudo apt install cppcheck
    ```

    macOSの場合は以下のコマンドでインストールできます。

    ```sh
    brew install cppcheck
    ```

- Python: `uv sync` で必要なツールがインストールされます。

## CMakeカスタムターゲットによるC++のformat/lint/test

- `make format` でC++の自動整形
- `make lint` でC++のlintチェック

    ```sh
    mkdir build && cd build
    cmake ..
    make format
    make lint
    make run-cppcheck
    make check # format, lint, run-cppcheckを一括実行
    make test
    ```

    以下のコマンドでも同じことができます。

    ```sh
    cmake --build build --target format
    cmake --build build --target lint
    cmake --build build --target run-cppcheck
    cmake --build build --target check # format, lint, run-cppcheckを一括実行
    cmake --build build --target test
    ```

## taskipyによるPythonのformat/lint/test

```sh
task format
task lint
task typecheck
task check # format, lint, typecheckを一括実行
task test
```

---

開発に関するルールは [開発ルール](development-rules.md) を参照してください。
