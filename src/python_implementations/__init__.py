"""ハミング距離計算のPython実装 (C++との性能比較用)"""

from .fast_math import (
    generate_test_data,
    hamming_distance_builtin_batch,
)

__all__ = [
    "hamming_distance_builtin_batch",
    "generate_test_data",
]
