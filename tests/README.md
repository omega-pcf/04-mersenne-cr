# Tests

This repo has no Python test suite today: the verification entrypoint is `pnpm run verify` (Lean 4, `lake build`), and there is nothing for pytest to collect, so `pyproject.toml` carries no `[tool.pytest.ini_options]`.

When Python tests are added, follow the family form used by `05-kk-golden-throat`: `[dependency-groups] dev = ["pytest>=8.0"]` plus `[tool.pytest.ini_options] testpaths = ["tests"]`, run as `uv run pytest tests/ -q`.
