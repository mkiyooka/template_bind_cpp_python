"""C++ Template Binding Project

このライブラリは、C++実装のクラスと関数をPythonから利用できるようにしています。

Example:
    >>> import template_bind_cpp_python as lib
    >>> # Fast Class example
    >>> calculator = lib.HammingDistanceCalculator([1, 2, 3], [4, 5, 6])
    >>> result = calculator.calculate()
    >>> print(f"Hamming distance sum: {result}")
    >>> # Simple Function example
    >>> sum_result = lib.add_integers(5, 3)
    >>> print(f"5 + 3 = {sum_result}")
"""

from __future__ import annotations

from importlib.metadata import version as get_version

try:
    from ._nanobind_module import (  # type: ignore[import-untyped]
        HammingDistanceCalculator,
        add_doubles,
        add_generic_double,
        add_generic_int,
        add_integers,
    )
except ImportError:
    # モジュールがビルドされていない場合のフォールバック
    HammingDistanceCalculator = None  # type: ignore[assignment]
    add_integers = None  # type: ignore[assignment]
    add_doubles = None  # type: ignore[assignment]
    add_generic_int = None  # type: ignore[assignment]
    add_generic_double = None  # type: ignore[assignment]

__version__ = get_version("template_bind_cpp_python")

__all__ = [
    "HammingDistanceCalculator",
    "add_integers",
    "add_doubles",
    "add_generic_int",
    "add_generic_double",
]
