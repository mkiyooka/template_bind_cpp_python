# 開発者向けガイド

このプロジェクトはC++/Pythonバインディングを含む複合プロジェクトです。環境構築・ビルド・品質管理の手順をまとめます。

## プロジェクト入手

``` sh
git clone <repo>
cd <dir>
git submodule update --init --recursive
```

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

## C++デバッグ

### コンソールでのLLDBデバッグ

1. **デバッグビルドの実行**:
    デバッグシンボルを有効にしてプロジェクトをビルドします。

    ```bash
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
    cmake --build build
    ```

    これにより、`build`ディレクトリにデバッグ情報を含む実行可能ファイルが生成されます。

2. **LLDBの起動**:

    ビルドされた実行可能ファイルに対して`lldb`を起動します。例えば、デバッグ用の実行可能ファイルをデバッグする場合:

    ```bash
    lldb build/src/core/debug_rand
    ```

3. **LLDBコマンド**:
    - `b <ファイル名>:<行番号>`: ブレークポイントを設定します。例: `b src/core/rand.cpp:5`
    - `run`: プログラムを実行します。
    - `next`: 次の行に進みます（関数呼び出しをステップオーバー）。
    - `step`: 次の行に進みます（関数呼び出しにステップイン）。
    - `p <変数名>`: 変数の値を表示します。
    - `l`: 現在のコードの周囲を表示します。
    - `c`: 次のブレークポイントまで実行を続行します。
    - `q`: LLDBを終了します。

### VSCodeでのLLDBデバッグ

1. **`.vscode/launch.json` の作成**:
    VSCodeでC++デバッグを設定するには、プロジェクトのルートディレクトリに`.vscode/launch.json`ファイルを作成します。以下は`debug_rand`実行可能ファイルをデバッグするための設定例です。

    ```json:launch.json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch debug_rand",
                "type": "cppdbg",
                "request": "launch",
                "program": "${workspaceFolder}/build/src/core/debug_rand",
                "args": [],
                "stopAtEntry": false,
                "cwd": "${workspaceFolder}",
                "environment": [],
                "externalConsole": false,
                "osx": {
                    "MIMode": "lldb"
                },
                "linux": {
                    "MIMode": "gdb"
                },
                "setupCommands": [
                    {
                        "description": "Enable pretty-printing for lldb",
                        "text": "-enable-pretty-printing",
                        "ignoreFailures": true
                    }
                ],
                "preLaunchTask": "cmake_for_debug",
            }
        ]
    }
    ```

2. **`tasks.json` の作成 (オプション)**:
    `launch.json` で `preLaunchTask` を使用する場合、`.vscode/tasks.json` ファイルでビルドタスクを定義する必要があります。

    ```json
    {
        "version": "2.0.0",
        "tasks": [
            {
                "label": "cmake_for_debug",
                "type": "shell",
                "command": "cmake",
                "args": [
                    "-S.",
                    "-Bbuild",
                    "-DCMAKE_BUILD_TYPE=Debug",
                    "-DPython_EXECUTABLE=${workspaceFolder}/.venv/bin/python"
                ],
                "options": {
                    "cwd": "${workspaceFolder}",
                    "env": {
                        "VIRTUAL_ENV": "${workspaceFolder}/.venv",
                        "PATH": "${workspaceFolder}/.venv/bin:${env:PATH}"
                    }
                },
                "group": {
                    "kind": "build",
                    "isDefault": false
                },
                "detail": "CMakeを使ってデバッグ用セットアップを実行"
            },
            {
                "label": "build_for_debug",
                "type": "shell",
                "command": "cmake",
                "args": [
                    "--build",
                    "${workspaceFolder}/build",
                ],
                "options": {
                    "cwd": "${workspaceFolder}",
                    "env": {
                        "VIRTUAL_ENV": "${workspaceFolder}/.venv",
                        "PATH": "${workspaceFolder}/.venv/bin:${env:PATH}"
                    }
                },
                "group": {
                    "kind": "build",
                    "isDefault": true
                },
                "detail": "CMakeを使ってデバッグ用ビルドを実行",
                "dependsOn": [
                    "cmake_for_debug"
                ]
            },
        ]
    }
    ```

3. **デバッグの開始**:
    VSCodeの「実行とデバッグ」ビューに移動し、「Launch debug_rand」設定を選択してデバッグを開始します。
