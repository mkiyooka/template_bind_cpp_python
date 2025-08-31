# ユーザーガイド

C++テンプレートバインディングプロジェクトのエンドユーザー向け利用ガイドです。

## 📦 インストール

### ローカルインストール

```bash
git clone <repo>
cd template_bind_cpp_python
git submodule update --init --recursive
uv pip install -e .
```

### リモートインストール

```bash
uv pip install git+https://github.com/user/template_bind_cpp_python.git
```

## 🚀 基本的な使い方

### ハミング距離計算

```python
import template_bind_cpp_python as cpp

# テストデータ
a_values = [0x123456789ABCDEF0, 0xFEDCBA9876543210]
b_values = [0x0FEDCBA987654321, 0x123456789ABCDEF0]

# 高速C++実装でハミング距離計算
calculator = cpp.HammingDistanceCalculator(a_values, b_values)
result = calculator.calculate()
data_size = calculator.size()

print(f"ハミング距離合計: {result}")
print(f"処理データ数: {data_size}")
```

### シンプル関数

```python
import template_bind_cpp_python as cpp

# 基本関数
print(cpp.add_integers(5, 3))      # 8
print(cpp.add_doubles(5.5, 3.2))   # 8.7

# テンプレート関数
print(cpp.add_generic_int(10, 20))     # 30
print(cpp.add_generic_double(7.7, 2.3)) # 10.0
```

## 📊 パフォーマンス比較

詳細なベンチマーク例は [`scripts/benchmark_hamming.py`](../scripts/benchmark_hamming.py) を実行してください：

```bash
python scripts/benchmark_hamming.py
```

Python実装とC++実装の性能差を確認できます。

## 🔧 型ヒント対応

インストール後は型ヒントが利用可能になります：

```python
from template_bind_cpp_python import HammingDistanceCalculator
from typing import List

# 型ヒント付きで記述可能
def calc_hamming(a: List[int], b: List[int]) -> int:
    calc = HammingDistanceCalculator(a, b)
    return calc.calculate()
```

## 🛠️ トラブルシューティング

### インストールエラー

- C++コンパイラが必要です（gcc/clang）
- submodule更新を忘れずに実行してください

### パフォーマンスが出ない

- リリースビルドでインストールされているか確認
- データサイズが小さすぎる場合、Python実装の方が速い場合があります
