# C++ テンプレートバインディングプロジェクト (nanobind)

C++とPythonをnanobindでバインディングするテンプレートプロジェクトです。ハミング距離計算の高速化と汎用関数の実装例を含みます。

## クイックスタート

```bash
git clone <repo>
cd <dir>
git submodule update --init --recursive
uv sync
unset CC CXX  # LLVM環境がある場合はリセット
uv pip install -e .
python scripts/benchmark_hamming.py
```

### 💡 トラブルシューティング

**モジュールインポートエラーが発生する場合:**
```bash
# ビルド環境をリセットして再ビルド
unset CC CXX
rm -rf build/ .venv/lib/python*/site-packages/template_bind_cpp_python*
uv pip install -e .
```

## 機能

### ハミング距離計算 (HammingDistanceCalculator)
- C++実装による高速ハミング距離計算
- データ転送と計算処理の分離設計
- Python実装との性能比較機能

### シンプル関数 (Simple Functions)
- 整数・浮動小数点数の加算関数
- テンプレート関数の実装例
- nanobindを用いたバインディング例

## 開発用ビルド

C++デバッグ用にCMakeから直接ビルド:

```bash
mkdir build && cd build
cmake ..
make -j
```

## 技術仕様

- **バインディング**: nanobind (submodule)
- **ビルドシステム**: scikit-build-core + CMake
- **パッケージ管理**: uv
- **C++標準**: C++17

## 開発者向け

- [ユーザ向けガイド](docs/user-guide.md)
- [開発者向けガイド](docs/developer-guide.md)
- [開発ルール](docs/development-rules.md)
- [このプロジェクトの実装状況](docs/implementation-status.md)

## License

This project is released under CC0 1.0 Universal.
You can copy, modify, and use it freely without attribution.
