from __future__ import annotations

from importlib.metadata import version as get_version

from .module_core import Rand

__version__ = get_version("template_bind_cpp_python")

__all__ = ["Rand"]
