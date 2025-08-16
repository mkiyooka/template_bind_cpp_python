# C++ and Python binding

`uv pip install`でC++のコンパイルとpythonパッケージとしてのインストールを同時に実行する。

``` sh
git clone <repo>
cd <dir>
uv sync
source .venv/bin/activate
uv pip install -e .
python examples/basic_usage.py
# デモ用のcliアプリは以下のコマンドで実行できる
bind-demo --help
```

C++コードのデバッグのために以下の方法でCMakeで直接ビルドできます。

``` sh
git clone <repo>
cd <dir>
uv sync
mkdir build && cd build
cmake ..
make -j
```

## nanobind or pybind11

C++17より古い環境ではnanobindの代わりにpybind11を利用す必要があります。
このテンプレートはnanobindとpybind11両方のサンプルを含んでいます。
利用する環境にあわせてライブラリを選択してください。

## 開発者向け

[このプロジェクトの実装状況](docs/implementation-status.md)

### compile_commands.josnの生成方法

clang-tidyにコンパイルオプションに合わせて解析させるため、コンパイル時に発行されるコマンドを渡す。
このときに利用する`compile_commands.josn`は次のコマンドで生成できる。

``` sh
cmake . -B _build -DCMAKE_EXPORT_COMPILE_COMMANDS=1
cp _build/compile_commands.json ./
```
