.PHONY: install dev clean lint type-check test

# Install the installer
install:
	pip install -e .

# Install with dev dependencies
dev:
	pip install -e ".[dev]"

# Clean up
clean:
	rm -rf build/ dist/ *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# Run linter
lint:
	ruff check install.py
	ruff format install.py --check

# Run type checker
type-check:
	mypy install.py

# Run all checks
check: lint type-check

# Format code
format:
	ruff format install.py