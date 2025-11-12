# Automation Guide - CI/CD Integration

**How to automate testing, validation, and deployment with the framework**

**Estimated reading time**: 15 minutes
**Token cost**: ~12K tokens (6% context)
**When to read**: When setting up continuous integration for your project

---

## Table of Contents

1. [GitHub Actions Workflows](#github-actions-workflows)
2. [GitLab CI Templates](#gitlab-ci-templates)
3. [State Validation in CI](#state-validation-in-ci)
4. [Automated Testing Strategies](#automated-testing-strategies)
5. [Deployment Automation](#deployment-automation)
6. [Automated Recovery Prompts](#automated-recovery-prompts)

---

## GitHub Actions Workflows

### Basic Test Workflow

**Purpose**: Run tests on every push and pull request

**File**: `.github/workflows/test.yml`

```yaml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: [3.9, 3.10, 3.11]

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Cache dependencies
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
        restore-keys: |
          ${{ runner.os }}-pip-

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest pytest-cov

    - name: Run unit tests
      run: |
        pytest tests/unit/ -v --cov=core --cov-report=xml

    - name: Run integration tests
      run: |
        pytest tests/integration/ -v

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        fail_ci_if_error: true
```

---

### Framework State Validation Workflow

**Purpose**: Validate state files on every commit

**File**: `.github/workflows/validate-state.yml`

```yaml
name: Validate Framework State

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'data/state/**'
      - 'docs/recovery_prompts/**'

jobs:
  validate-state:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install JSON schema validator
      run: |
        pip install jsonschema

    - name: Validate master_state.json
      run: |
        python scripts/validate_state.py data/state/master_state.json

    - name: Validate module state files
      run: |
        for file in data/state/module_*.json; do
          if [ -f "$file" ]; then
            echo "Validating $file..."
            python scripts/validate_state.py "$file"
          fi
        done

    - name: Check state consistency
      run: |
        python scripts/check_state_consistency.py

    - name: Verify recovery prompts exist
      run: |
        # Check that recovery prompts match in-progress modules
        python scripts/verify_recovery_prompts.py

    - name: Report validation results
      if: always()
      run: |
        echo "State validation complete"
        cat validation_report.txt
```

---

### Comprehensive CI Workflow (Full Pipeline)

**Purpose**: Complete CI pipeline with linting, testing, state validation

**File**: `.github/workflows/ci.yml`

```yaml
name: Comprehensive CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  lint:
    name: Lint Code
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install linting tools
      run: |
        pip install pylint flake8 black isort mypy

    - name: Run Black (format check)
      run: |
        black --check core/ tests/

    - name: Run isort (import order)
      run: |
        isort --check-only core/ tests/

    - name: Run Flake8
      run: |
        flake8 core/ tests/ --max-line-length=100

    - name: Run Pylint
      run: |
        pylint core/ --fail-under=8.0

    - name: Run MyPy (type checking)
      run: |
        mypy core/ --strict

  test:
    name: Run Tests
    runs-on: ubuntu-latest
    needs: lint

    strategy:
      matrix:
        python-version: [3.9, 3.10, 3.11]

    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_pass
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Cache dependencies
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-cov pytest-xdist

    - name: Run unit tests (parallel)
      run: |
        pytest tests/unit/ -v -n 4 --cov=core

    - name: Run integration tests
      env:
        DATABASE_URL: postgresql://test_user:test_pass@localhost:5432/test_db
      run: |
        pytest tests/integration/ -v

    - name: Generate coverage report
      run: |
        pytest --cov=core --cov-report=xml --cov-report=html

    - name: Upload coverage
      uses: codecov/codecov-action@v3

  validate-framework:
    name: Validate Framework State
    runs-on: ubuntu-latest
    needs: lint

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install validators
      run: |
        pip install jsonschema

    - name: Validate state files
      run: |
        python scripts/validate_all_state.py

    - name: Check module progression
      run: |
        python scripts/check_module_progression.py

    - name: Verify git commit format
      run: |
        python scripts/verify_commit_format.py

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: lint

    steps:
    - uses: actions/checkout@v3

    - name: Run Bandit (security linter)
      run: |
        pip install bandit
        bandit -r core/ -f json -o bandit-report.json

    - name: Run Safety (dependency check)
      run: |
        pip install safety
        safety check --json

    - name: Upload security reports
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: security-reports
        path: bandit-report.json
```

---

### Deployment Workflow

**Purpose**: Deploy to production after all tests pass

**File**: `.github/workflows/deploy.yml`

```yaml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  test:
    name: Run Full Test Suite
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-cov

    - name: Run all tests
      run: |
        pytest tests/ -v --cov=core --cov-report=xml

    - name: Check coverage threshold
      run: |
        # Fail if coverage below 80%
        coverage report --fail-under=80

  build:
    name: Build Application
    runs-on: ubuntu-latest
    needs: test

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install build tools
      run: |
        pip install build

    - name: Build package
      run: |
        python -m build

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: dist
        path: dist/

  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build
    environment: production

    steps:
    - uses: actions/checkout@v3

    - name: Download artifacts
      uses: actions/download-artifact@v3
      with:
        name: dist
        path: dist/

    - name: Deploy to PyPI
      env:
        TWINE_USERNAME: ${{ secrets.PYPI_USERNAME }}
        TWINE_PASSWORD: ${{ secrets.PYPI_PASSWORD }}
      run: |
        pip install twine
        twine upload dist/*

    - name: Create GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        files: dist/*
        body: |
          Release ${{ github.ref_name }}

          See CHANGELOG.md for details.
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## GitLab CI Templates

### Basic GitLab CI Configuration

**File**: `.gitlab-ci.yml`

```yaml
stages:
  - lint
  - test
  - validate
  - deploy

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  paths:
    - .cache/pip
    - venv/

before_script:
  - python -V
  - pip install virtualenv
  - virtualenv venv
  - source venv/bin/activate
  - pip install -r requirements.txt

lint:
  stage: lint
  script:
    - pip install pylint flake8 black mypy
    - black --check core/ tests/
    - flake8 core/ tests/
    - pylint core/ --fail-under=8.0
    - mypy core/

unit-tests:
  stage: test
  script:
    - pip install pytest pytest-cov
    - pytest tests/unit/ -v --cov=core
  coverage: '/TOTAL.*\s+(\d+%)$/'

integration-tests:
  stage: test
  services:
    - postgres:14
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: test_user
    POSTGRES_PASSWORD: test_pass
    DATABASE_URL: postgresql://test_user:test_pass@postgres:5432/test_db
  script:
    - pip install pytest
    - pytest tests/integration/ -v

validate-state:
  stage: validate
  script:
    - pip install jsonschema
    - python scripts/validate_all_state.py
  only:
    changes:
      - data/state/**
      - docs/recovery_prompts/**

deploy-production:
  stage: deploy
  script:
    - pip install build twine
    - python -m build
    - twine upload dist/*
  only:
    - tags
  when: manual
```

---

## State Validation in CI

### Automated State Validation Script

**Purpose**: Validate all state files in CI pipeline

**File**: `scripts/validate_all_state.py`

```python
#!/usr/bin/env python3
"""
Validate all framework state files in CI pipeline.
"""

import json
import sys
from pathlib import Path
from jsonschema import validate, ValidationError

def load_schema(schema_name):
    """Load JSON schema from 10_REFERENCE/state_schemas.md"""
    # Extract schema from markdown file
    schemas_file = Path("10_REFERENCE/state_schemas.md")
    if not schemas_file.exists():
        print(f"❌ Schema file not found: {schemas_file}")
        sys.exit(1)

    # Parse schemas from markdown (simple extraction)
    # In production, schemas should be separate JSON files
    schemas = {
        "master_state": {
            "type": "object",
            "required": ["project", "version", "current_phase", "modules_complete"],
            "properties": {
                "project": {"type": "string"},
                "version": {"type": "string"},
                "current_phase": {"type": "string"},
                "modules_complete": {"type": "array"}
            }
        }
    }
    return schemas.get(schema_name)

def validate_state_file(file_path):
    """Validate a single state file"""
    print(f"Validating: {file_path}")

    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON in {file_path}: {e}")
        return False

    # Determine schema based on filename
    if "master_state" in str(file_path):
        schema = load_schema("master_state")
    elif "module_" in str(file_path):
        schema = load_schema("module_state")
    else:
        schema = load_schema("context_tracking")

    try:
        validate(instance=data, schema=schema)
        print(f"✅ Valid: {file_path}")
        return True
    except ValidationError as e:
        print(f"❌ Validation error in {file_path}: {e.message}")
        return False

def main():
    """Validate all state files"""
    state_dir = Path("data/state")

    if not state_dir.exists():
        print(f"❌ State directory not found: {state_dir}")
        sys.exit(1)

    all_valid = True
    state_files = list(state_dir.glob("*.json"))

    if not state_files:
        print("⚠️  No state files found")
        return

    print(f"Found {len(state_files)} state files to validate\n")

    for state_file in state_files:
        if not validate_state_file(state_file):
            all_valid = False

    print("\n" + "="*50)
    if all_valid:
        print("✅ All state files valid")
        sys.exit(0)
    else:
        print("❌ State validation failed")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

---

### Check Module Progression Script

**Purpose**: Ensure modules are completed in logical order

**File**: `scripts/check_module_progression.py`

```python
#!/usr/bin/env python3
"""
Check that modules are completed in logical progression.
"""

import json
import sys
from pathlib import Path

def load_master_state():
    """Load master state file"""
    state_file = Path("data/state/master_state.json")
    with open(state_file, 'r') as f:
        return json.load(f)

def check_progression(modules_complete):
    """Check modules are completed in order"""
    issues = []

    # Extract module numbers (e.g., "1.1" -> (1, 1))
    def parse_module(m):
        parts = m.split('.')
        return (int(parts[0]), int(parts[1]))

    completed = sorted([parse_module(m) for m in modules_complete])

    # Check for gaps
    for i in range(len(completed) - 1):
        current = completed[i]
        next_mod = completed[i + 1]

        # Check if we skipped a module
        if current[0] == next_mod[0]:  # Same major version
            if next_mod[1] - current[1] > 1:
                missing = f"{current[0]}.{current[1] + 1}"
                issues.append(f"Skipped module: {missing}")

    return issues

def main():
    """Main validation"""
    print("Checking module progression...\n")

    state = load_master_state()
    modules_complete = state.get("modules_complete", [])

    print(f"Modules complete: {', '.join(modules_complete)}")

    issues = check_progression(modules_complete)

    if issues:
        print("\n❌ Progression issues found:")
        for issue in issues:
            print(f"  - {issue}")
        sys.exit(1)
    else:
        print("\n✅ Module progression is valid")
        sys.exit(0)

if __name__ == "__main__":
    main()
```

---

## Automated Testing Strategies

### Parallel Test Execution

**Optimize CI runtime** by running tests in parallel:

```yaml
# .github/workflows/test-parallel.yml
name: Parallel Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test-group: [unit, integration, e2e]

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-xdist

    - name: Run ${{ matrix.test-group }} tests
      run: |
        pytest tests/${{ matrix.test-group }}/ -v -n 4
```

---

### Scheduled Validation

**Run comprehensive checks nightly**:

```yaml
# .github/workflows/nightly.yml
name: Nightly Validation

on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily

jobs:
  full-validation:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-cov

    - name: Run full test suite
      run: |
        pytest tests/ -v --cov=core --cov-report=html

    - name: Validate all state files
      run: |
        python scripts/validate_all_state.py

    - name: Check for stale modules
      run: |
        python scripts/check_stale_modules.py

    - name: Generate health report
      run: |
        python scripts/generate_health_report.py

    - name: Upload report
      uses: actions/upload-artifact@v3
      with:
        name: nightly-report
        path: reports/
```

---

## Deployment Automation

### Automated Version Bumping

**Script**: `scripts/bump_version.sh`

```bash
#!/bin/bash
# Bump version and create release

set -e

CURRENT_VERSION=$(git describe --tags --abbrev=0)
echo "Current version: $CURRENT_VERSION"

# Parse version (e.g., v3.3.0 -> 3.3.0)
VERSION=${CURRENT_VERSION#v}
IFS='.' read -r -a VERSION_PARTS <<< "$VERSION"

MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Increment based on argument
case "$1" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Usage: $0 {major|minor|patch}"
    exit 1
    ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
echo "New version: $NEW_VERSION"

# Update version in files
sed -i "s/^**Version**: .*/**Version**: ${NEW_VERSION:1}/" README.md

# Commit and tag
git add README.md
git commit -m "Bump version to $NEW_VERSION"
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"

echo "✅ Version bumped to $NEW_VERSION"
echo "Push with: git push origin main --tags"
```

---

### Docker Build Automation

**File**: `.github/workflows/docker-build.yml`

```yaml
name: Build Docker Image

on:
  push:
    branches: [ main ]
    tags:
      - 'v*.*.*'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2

    - name: Login to DockerHub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: myorg/myapp
        tags: |
          type=ref,event=branch
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}

    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

---

## Automated Recovery Prompts

### Generate Recovery Prompt on CI Failure

**Purpose**: Create recovery prompt if CI fails mid-session

**File**: `.github/workflows/recovery-on-failure.yml`

```yaml
name: Recovery Prompt on Failure

on:
  workflow_run:
    workflows: ["Comprehensive CI"]
    types: [completed]

jobs:
  create-recovery:
    if: ${{ github.event.workflow_run.conclusion == 'failure' }}
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Generate recovery prompt
      run: |
        python scripts/generate_recovery_prompt.py \
          --reason "CI failure" \
          --commit "${{ github.sha }}" \
          --workflow "${{ github.event.workflow_run.name }}"

    - name: Commit recovery prompt
      run: |
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git add docs/recovery_prompts/
        git commit -m "[Auto] Create recovery prompt for CI failure"
        git push
```

---

## Best Practices

### 1. **Cache Dependencies**
- Cache pip packages, npm modules to speed up CI
- Use `actions/cache` for GitHub Actions

### 2. **Parallel Execution**
- Run independent test suites in parallel
- Use pytest-xdist for parallel pytest execution

### 3. **Fail Fast**
- Run linting before tests (cheaper, faster feedback)
- Stop pipeline early on critical failures

### 4. **Matrix Testing**
- Test on multiple Python/Node versions
- Test on multiple OS (Ubuntu, macOS, Windows)

### 5. **Secrets Management**
- Store API keys, tokens in CI secrets
- Never commit credentials to repository

### 6. **Artifact Preservation**
- Upload test reports, coverage data
- Preserve logs for failed builds

---

**Automation Guide version**: 3.4
**Last updated**: January 2025
