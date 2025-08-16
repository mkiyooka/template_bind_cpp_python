from __future__ import annotations

from importlib.metadata import version as get_version

try:
    from ._nanobind_module import Rand as nb_rand  # type: ignore[import]
except ImportError:
    nb_rand = None

try:
    from ._pybind11_module import Rand as pb_rand  # type: ignore[import]
except ImportError:
    pb_rand = None

__version__ = get_version("template_bind_cpp_python")

__all__ = ["nb_rand", "pb_rand"]
