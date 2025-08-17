# C++ and Python binding

## 利用方法

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

- [ユーザ向けガイド](docs/user-guide.md)
- [開発者向けガイド](docs/developer-guide.md)
- [開発ルール](docs/development-rules.md)
- [このプロジェクトの実装状況](docs/implementation-status.md)

## License

This project is released under CC0 1.0 Universal.
You can copy, modify, and use it freely without attribution.
