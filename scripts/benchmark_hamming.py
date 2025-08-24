#!/usr/bin/env python3
"""ハミング距離計算の性能比較: Python vs C++"""

from __future__ import annotations

import sys
import time
from pathlib import Path
from typing import TYPE_CHECKING, Any

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))
from python_implementations import fast_math as py_fast_math

if TYPE_CHECKING:
    from collections.abc import Callable

try:
    import template_bind_cpp_python as cpp_module

    cpp_available = True
except ImportError:
    cpp_module = None
    cpp_available = False


def benchmark_function(
    func: Callable[..., Any], *args: Any, iterations: int = 10
) -> tuple[Any, float]:
    """関数のベンチマークを実行"""
    result = None
    start_time = time.perf_counter()
    for _ in range(iterations):
        result = func(*args)
    end_time = time.perf_counter()
    return result, (end_time - start_time) / iterations


def test_simple_functions() -> None:
    """Simple function modules test"""
    print("\n=== Simple Function Test ===")

    if not cpp_available or cpp_module is None:
        print("C++実装が利用できません")
        return

    print(f"{cpp_module.add_integers(5, 3)=}")
    print(f"{cpp_module.add_doubles(5.5, 3.2)=}")
    print(f"{cpp_module.add_generic_int(10, 20)=}")
    print(f"{cpp_module.add_generic_double(7.7, 2.3)=}")


def compare_hamming_distance() -> None:
    """Python実装とC++実装の性能を比較"""
    print("=== ハミング距離計算性能比較 ===")

    # テストデータ生成
    data_size = 100_000
    a_values, b_values = py_fast_math.generate_test_data(data_size, seed=42)

    # Python実装
    py_result, py_time = benchmark_function(
        py_fast_math.hamming_distance_builtin_batch, a_values, b_values
    )
    print(f"Python: {py_time * 1e6:.1f}us")

    if not cpp_available or cpp_module is None:
        print("C++実装が利用できません")
        return

    # C++実装
    calculator = cpp_module.HammingDistanceCalculator(a_values, b_values)
    cpp_result, cpp_time = benchmark_function(calculator.calculate)
    print(f"C++:    {cpp_time * 1e6:.1f}us")

    # 比較結果
    speedup = py_time / cpp_time
    print(f"C++が{speedup:.0f}x高速")

    # 正確性確認
    if py_result == cpp_result:
        print("✓ 結果一致")
    else:
        print("✗ 結果不一致")


if __name__ == "__main__":
    test_simple_functions()
    compare_hamming_distance()
