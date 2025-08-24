"""ハミング距離計算のPython実装 (性能比較用)"""

from __future__ import annotations

import random


def hamming_distance_builtin_batch(a_list: list[int], b_list: list[int]) -> int:
    """ハミング距離計算 - Python組み込み関数版 (一括処理して合計を返す)"""
    if len(a_list) != len(b_list):
        msg = "List sizes must match"
        raise ValueError(msg)

    return sum(bin(a ^ b).count("1") for a, b in zip(a_list, b_list, strict=False))


def generate_test_data(size: int, *, seed: int = 42) -> tuple[list[int], list[int]]:
    """ハミング距離計算用のテストデータを生成

    Args:
        size: データサイズ
        seed: 乱数シード

    Returns
    -------
        テストデータのペア (a_list, b_list)
    """
    random.seed(seed)
    a_list = [random.getrandbits(64) for _ in range(size)]
    b_list = [random.getrandbits(64) for _ in range(size)]
    return a_list, b_list
