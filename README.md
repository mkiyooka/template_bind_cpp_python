# C++ and Python binding

## nanobind

`uv pip install`でC++のコンパイルとpythonパッケージとしてのインストールを同時に実行する。

``` sh
git clone <repo>
cd <dir>
uv sync
source .venv/bin/activate
uv pip install -e .
python examples/basic_usage.py
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

## pybind11

C++17より古い環境ではnanobindの代わりにpybind11を利用す必要があります。
環境変数`WITH_PYBIND11`を設定することでpybind11を使うように変更できます。

``` sh
git clone <repo>
cd <dir>
uv sync
source .venv/bin/activate
WITH_PYBIND11=True task build
python examples/basic_usage.py
```

nanobindのときと同様にC++コードのデバッグのために以下の方法でCMakeで直接ビルドできます。

``` sh
git clone <repo>
cd <dir>
uv sync
mkdir build && cd build
WITH_PYBIND11=True cmake ..
make -j
```

## 開発者向け

[このプロジェクトの実装状況](docs/implementation-status.md)

### compile_commands.josnの生成方法

clang-tidyにコンパイルオプションに合わせて解析させるため、コンパイル時に発行されるコマンドを渡す。
このときに利用する`compile_commands.josn`は次のコマンドで生成できる。

``` sh
mkdir build && cd build
cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=1
```
