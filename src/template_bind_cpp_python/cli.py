"""Command-line interface for generating random numbers."""

import typer

from template_bind_cpp_python import Rand

try:
    from template_bind_cpp_python import __version__
except ImportError:
    # __version__が定義されていない場合のデフォルト値
    __version__ = "0.0.0"

app = typer.Typer()


@app.command("unif")
def unif(
    n: int = typer.Argument(1, help="1st number"), seed: int | None = None
) -> None:
    """一様乱数をn個生成。seed指定可能。"""
    r = Rand(seed or 0)
    if seed is not None:
        r.set_seed(seed)
    for _ in range(n):
        print(r.next())


# サブコマンドではなくオプションとしてバージョンを表示するためのコールバック関数
def _version_callback(*, show_version: bool) -> None:
    if show_version:  # pragma: no cover
        print(f"Version: {__version__}")
        raise typer.Exit()


@app.callback()
def main(
    *,
    version: bool = typer.Option(
        False,
        "--version",
        "-v",
        callback=_version_callback,
        is_eager=True,
        help="バージョンを表示して終了",
    ),
) -> None:
    """メイン関数"""
    return


if __name__ == "__main__":
    app()
