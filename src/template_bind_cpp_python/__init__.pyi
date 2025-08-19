from ._nanobind_module import Rand as _NBRand  # type: ignore[import]

# 実行時には None またはクラス本体が入る
Rand: type[_NBRand] | None

# __all__ = ["Rand"]
