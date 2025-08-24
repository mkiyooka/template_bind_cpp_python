"""Command-line interface for Hamming distance calculation."""

from __future__ import annotations

import sys
from pathlib import Path

import typer

# Python実装をインポート
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from python_implementations import fast_math as py_fast_math

try:
    from template_bind_cpp_python import (
        HammingDistanceCalculator,  # type: ignore[import]
        __version__,  # type: ignore[import]
    )
except ImportError:
    HammingDistanceCalculator = None
    __version__ = "0.0.0"

app = typer.Typer()


@app.command("python")
def python_hamming(
    size: int = typer.Option(10000, "--size", "-s", help="データサイズ"),
    seed: int = typer.Option(42, "--seed", help="乱数シード"),
) -> None:
    """Python実装でハミング距離を計算."""
    print("=== Python実装 ハミング距離計算 ===")
    print(f"データサイズ: {size:,}")
    a_values, b_values = py_fast_math.generate_test_data(size, seed=seed)

    # ハミング距離計算
    result = py_fast_math.hamming_distance_builtin_batch(a_values, b_values)
    print(f"計算結果 (合計): {result:,}")


@app.command("cpp")
def cpp_hamming(
    size: int = typer.Option(10000, "--size", "-s", help="データサイズ"),
    seed: int = typer.Option(42, "--seed", help="乱数シード"),
) -> None:
    """C++実装でハミング距離を計算."""
    if HammingDistanceCalculator is None:
        print("C++実装が利用できません。'uv pip install -e .' を実行してください")
        return

    print("=== C++実装 ハミング距離計算 ===")
    print(f"データサイズ: {size:,}")
    a_values, b_values = py_fast_math.generate_test_data(size, seed=seed)

    calculator = HammingDistanceCalculator(a_values, b_values)

    # ハミング距離計算
    result = calculator.calculate()
    print(f"計算結果 (合計): {result:,}")


# バージョン表示のコールバック関数
def _version_callback(*, show_version: bool) -> None:
    if show_version:  # pragma: no cover
        print(f"Version: {__version__}")
        raise typer.Exit()


@app.callback()
def main(
    *,
    _version: bool = typer.Option(
        False,
        "--version",
        "-v",
        callback=_version_callback,
        is_eager=True,
        help="バージョンを表示して終了",
    ),
) -> None:
    """ハミング距離計算ライブラリ CLI"""
    return


if __name__ == "__main__":
    app()
