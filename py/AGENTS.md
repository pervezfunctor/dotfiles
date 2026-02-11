# Agent Coding Guidelines

## Type Safety

- Use strict pyright static typing with `strict` mode enabled (see `[tool.pyright]` in pyproject.toml).
- Always specify return types and parameter types.
- Avoid `Any` and `Unknown` types; use `TypeVar` or `Protocol` for generics.

## Data Validation

- Use Pydantic models for all input from users/files.
- Use Pydantic-compatible libraries for data handling.

## Code Style

- Follow ruff linting rules (see `[tool.ruff.lint]` in pyproject.toml).
- Format code with ruff (see `[tool.ruff.format]` in pyproject.toml).
- Prefer generator comprehensions over loops when transforming iterables/collections.
- If generator comprehensions are not possible, use `yield` for generator functions. Avoid building collections.
- Prefer async/await patterns for most I/O operations.
- Use `Iterable` or `AsyncIterable` types instead of concrete collection types for function signatures.
- Use `NoReturn` type for functions that never return.
- Prefer functions over classes.

## Resource Management

- Always use `with` statements for synchronous resource handling.
- Always use `async with` statements for asynchronous resource handling.

## Testing & Quality

- Write tests using pytest with async mode (see `[tool.pytest.ini_options]` in pyproject.toml).
- Test files should match patterns: `*_test.py`.
- Use pixi or uv commands to run quality checks:
  - `pixi run check` or `uv run --extra dev pyright && uv run --extra dev ruff check` - Runs both pyright and ruff
  - `pixi run typecheck` or `uv run --extra dev pyright` - Runs pyright only
  - `pixi run lint` or `uv run --extra dev ruff check` - Runs ruff only
  - `pixi run lint-fix` or `uv run --extra dev ruff check --fix` - Auto-fixes ruff issues
  - `pixi run test` or `uv run --extra dev pytest` - Runs pytest
- Run type checking and linting before committing.
- DO NOT test private methods.
- Avoid mocks wherever possible.


## Error Handling

- Use specific exception types; avoid bare `except:`.
- Raise exceptions with descriptive messages.
- Use `logging.exception()` to capture tracebacks in error handlers.
- Use structlog for structured logging (see dependencies).
- Install rich.traceback for rich tracebacks (see dependencies).
- Use result.Result for fallible functions (see dependencies).

## Documentation

- Use inline comments for non-obvious logic only.

## CLI & Async Patterns

- Use typer for CLI applications.
- Use aiofiles, asyncssh, aiobreaker for async I/O operations.
- Use aiostream for async stream manipulation.
- Use tenacity for retry logic.
