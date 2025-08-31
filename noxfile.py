import nox

nox.options.default_venv_backend = "uv"
nox.options.reuse_venv = "yes"


@nox.session(python=["3.13"], tags=["ruff"])
def ruff(session) -> None:
    session.install("ruff")
    session.run("ruff", "check", "--fix", "--show-fixes", "--exit-non-zero-on-fix", ".")
    session.run("ruff", "format", ".")


@nox.session(python=["3.10", "3.13"], tags=["typecheck"])
def typecheck(session) -> None:
    session.install("-e", ".")
    session.install("pyright")
    session.run("pyright")


@nox.session(python=["3.10", "3.11", "3.12", "3.13"], tags=["test"])
def test(session) -> None:
    session.install("-e", ".")
    session.install("pytest", "pytest-cov")
    session.run("pytest")


@nox.session(python="3.13", tags=["coverage"], requires=["test-{python}"])
def coverage(session):
    session.run("pytest", "--cov=src", "--cov-report=term")
