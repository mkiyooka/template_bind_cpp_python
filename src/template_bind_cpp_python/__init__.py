from __future__ import annotations

from importlib.metadata import version as get_version

try:
    from ._nanobind_module import Rand  # type: ignore[import]
except ImportError:
    Rand = None

__version__ = get_version("template_bind_cpp_python")

__all__ = ["Rand"]
