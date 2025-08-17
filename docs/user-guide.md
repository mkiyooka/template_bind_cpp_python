# User Guide

このプロジェクトのPythonパッケージを利用するには、以下の手順でインストールしてください。

## パッケージのインストール

1. プロジェクトルートで以下を実行します。

    ```sh
    uv pip install .
    ```

2. リモートリポジトリから直接インストール

    ```sh
    uv pip install git+https://github.com/mkiyooka/template_bind_cpp_python.git
    ```

3. これでPythonパッケージがインストールされ、`import template_bind_cpp_python` で利用可能になります。

    [examples/basic_usage.py](../examples/basic_usage.py) を参考にしてください。

---

詳細なAPIや利用例は `examples/` ディレクトリや `README.md` を参照してください。
