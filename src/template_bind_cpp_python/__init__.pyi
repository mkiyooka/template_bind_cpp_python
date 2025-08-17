
from ._nanobind_module import Rand as _NBRand  # type: ignore[import]
from ._pybind11_module import Rand as _PBRand  # type: ignore[import]

# 実行時には None またはクラス本体が入る
nb_rand: type[_NBRand] | None
pb_rand: type[_PBRand] | None

# __all__ = ["nb_rand", "pb_rand"]
