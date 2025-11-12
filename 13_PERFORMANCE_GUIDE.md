# Performance Optimization Guide

**How to optimize framework performance for large files and fast state updates**

**Estimated reading time**: 15 minutes
**Token cost**: ~11K tokens (5.5% context)
**When to read**: When experiencing performance issues or working with large projects

---

## Table of Contents

1. [Large File Handling](#large-file-handling)
2. [State Update Optimization](#state-update-optimization)
3. [Memory Management](#memory-management)
4. [Git Performance](#git-performance)
5. [Context Window Optimization](#context-window-optimization)
6. [Benchmarking and Monitoring](#benchmarking-and-monitoring)

---

## Large File Handling

### Problem: Reading Large Files is Slow

**Symptom**: Claude Code takes 10+ seconds to read files >10K lines

**Solutions**:

#### 1. Use Partial File Reads

**Instead of**:
```python
# Bad: Reads entire 50K line file
with open('core/large_module.py', 'r') as f:
    content = f.read()
```

**Do this**:
```python
# Good: Read only what you need
def read_function(file_path, function_name):
    """Read only a specific function from large file"""
    with open(file_path, 'r') as f:
        lines = []
        in_function = False
        indent_level = 0

        for line in f:
            if f'def {function_name}(' in line:
                in_function = True
                indent_level = len(line) - len(line.lstrip())

            if in_function:
                lines.append(line)

                # Stop when we exit the function
                if line.strip() and not line.startswith(' ' * (indent_level + 1)):
                    if len(lines) > 1:  # Not just the def line
                        break

        return ''.join(lines)

# Usage
authenticate_func = read_function('core/auth.py', 'authenticate')
```

---

#### 2. Use Line Ranges with Read Tool

**When using Claude Code Read tool**:
```python
# Instead of reading entire file
Read(file_path="core/large_module.py")

# Read specific range
Read(file_path="core/large_module.py", offset=100, limit=50)
# Reads lines 100-150 only
```

---

#### 3. Split Large Files into Modules

**If file >1000 lines**: Split into smaller modules

**Example**: `core/auth.py` (1500 lines)
```
Before:
core/auth.py (1500 lines)
  - login()
  - logout()
  - validate_token()
  - refresh_token()
  - password_reset()
  - oauth_flow()

After:
core/auth/
  __init__.py
  login.py (200 lines)
  logout.py (150 lines)
  tokens.py (300 lines)
  password.py (200 lines)
  oauth.py (400 lines)
```

**Benefits**:
- Read only relevant module (200 lines vs 1500)
- Faster navigation
- Better organization

---

#### 4. Use File Indexing

**Create index of large codebase**:

**Script**: `scripts/create_file_index.py`
```python
#!/usr/bin/env python3
"""
Create searchable index of codebase for fast lookups.
"""

import ast
import json
from pathlib import Path

def index_python_file(file_path):
    """Extract functions, classes from Python file"""
    with open(file_path, 'r') as f:
        try:
            tree = ast.parse(f.read())
        except SyntaxError:
            return []

    items = []
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            items.append({
                'type': 'function',
                'name': node.name,
                'line': node.lineno,
                'file': str(file_path)
            })
        elif isinstance(node, ast.ClassDef):
            items.append({
                'type': 'class',
                'name': node.name,
                'line': node.lineno,
                'file': str(file_path)
            })

    return items

def create_index(root_dir):
    """Create index of entire codebase"""
    index = []

    for py_file in Path(root_dir).rglob('*.py'):
        index.extend(index_python_file(py_file))

    return index

def save_index(index, output_file='data/codebase_index.json'):
    """Save index to JSON"""
    with open(output_file, 'w') as f:
        json.dump(index, f, indent=2)

def search_index(index, query):
    """Search index for function/class"""
    results = []
    for item in index:
        if query.lower() in item['name'].lower():
            results.append(item)
    return results

if __name__ == '__main__':
    # Create index
    index = create_index('core/')
    save_index(index)
    print(f"✅ Indexed {len(index)} items")

    # Example search
    results = search_index(index, 'authenticate')
    for r in results:
        print(f"{r['type']} {r['name']} at {r['file']}:{r['line']}")
```

**Usage**:
```bash
# Create index once
python scripts/create_file_index.py

# Search quickly (no need to read entire codebase)
python scripts/search_index.py "authenticate"
# Output: function authenticate at core/auth/login.py:15
```

---

## State Update Optimization

### Problem: State Updates are Slow

**Symptom**: Updating `master_state.json` takes multiple seconds

**Solutions**:

#### 1. Atomic File Writes

**Instead of**:
```python
# Bad: Not atomic, can corrupt file if interrupted
with open('data/state/master_state.json', 'w') as f:
    json.dump(state, f)
```

**Do this**:
```python
# Good: Atomic write using temp file
import json
import os
import tempfile

def atomic_write_json(file_path, data):
    """Write JSON atomically (no corruption risk)"""
    # Write to temp file first
    fd, temp_path = tempfile.mkstemp(
        dir=os.path.dirname(file_path),
        prefix='.tmp_',
        suffix='.json'
    )

    try:
        with os.fdopen(fd, 'w') as f:
            json.dump(data, f, indent=2)

        # Atomic rename (POSIX systems)
        os.replace(temp_path, file_path)
    except Exception:
        # Clean up temp file on error
        if os.path.exists(temp_path):
            os.remove(temp_path)
        raise

# Usage
atomic_write_json('data/state/master_state.json', state)
```

---

#### 2. Incremental State Updates

**Instead of**:
```python
# Bad: Load entire state, modify, save entire state
state = load_state('data/state/master_state.json')
state['modules_complete'].append('1.2')
save_state('data/state/master_state.json', state)
```

**Do this**:
```python
# Good: Update only what changed
def update_state_field(file_path, field, value, operation='append'):
    """Update single field without loading/saving everything"""
    import fcntl

    with open(file_path, 'r+') as f:
        # Lock file (prevent concurrent writes)
        fcntl.flock(f, fcntl.LOCK_EX)

        state = json.load(f)

        # Update field
        if operation == 'append':
            state[field].append(value)
        elif operation == 'set':
            state[field] = value
        elif operation == 'remove':
            state[field].remove(value)

        # Write back
        f.seek(0)
        json.dump(state, f, indent=2)
        f.truncate()

        fcntl.flock(f, fcntl.LOCK_UN)

# Usage
update_state_field('data/state/master_state.json', 'modules_complete', '1.2', 'append')
```

---

#### 3. Batch State Updates

**Instead of**:
```python
# Bad: 3 separate file writes
update_state('modules_complete', '1.1')
update_state('modules_complete', '1.2')
update_state('modules_complete', '1.3')
```

**Do this**:
```python
# Good: Single batch update
def batch_update_state(file_path, updates):
    """Apply multiple updates in one write"""
    state = load_state(file_path)

    for field, value, operation in updates:
        if operation == 'append':
            state[field].append(value)
        elif operation == 'set':
            state[field] = value

    atomic_write_json(file_path, state)

# Usage
batch_update_state('data/state/master_state.json', [
    ('modules_complete', '1.1', 'append'),
    ('modules_complete', '1.2', 'append'),
    ('modules_complete', '1.3', 'append'),
])
```

---

#### 4. State Caching

**For frequently read state**:

```python
class StateCache:
    """Cache state files in memory with TTL"""

    def __init__(self, ttl=60):
        self.cache = {}
        self.ttl = ttl  # seconds

    def get(self, file_path):
        """Get state from cache or load"""
        import time

        if file_path in self.cache:
            state, timestamp = self.cache[file_path]
            if time.time() - timestamp < self.ttl:
                return state

        # Cache miss or expired
        state = load_state(file_path)
        self.cache[file_path] = (state, time.time())
        return state

    def invalidate(self, file_path):
        """Invalidate cache after write"""
        if file_path in self.cache:
            del self.cache[file_path]

# Global cache instance
state_cache = StateCache(ttl=60)

# Usage
state = state_cache.get('data/state/master_state.json')
# ... modify state ...
atomic_write_json('data/state/master_state.json', state)
state_cache.invalidate('data/state/master_state.json')
```

---

## Memory Management

### Problem: High Memory Usage with Large Projects

**Symptom**: Claude Code session uses 2GB+ RAM

**Solutions**:

#### 1. Stream Large Files

**Instead of**:
```python
# Bad: Loads entire file into memory
with open('data/large_dataset.csv', 'r') as f:
    data = f.readlines()  # 10GB in memory

for line in data:
    process(line)
```

**Do this**:
```python
# Good: Stream line by line
with open('data/large_dataset.csv', 'r') as f:
    for line in f:  # Only one line in memory at a time
        process(line)
```

---

#### 2. Use Generators for Large Collections

**Instead of**:
```python
# Bad: Builds entire list in memory
def get_all_modules():
    modules = []
    for file in Path('core/').rglob('*.py'):
        modules.append(parse_module(file))
    return modules

all_modules = get_all_modules()  # All in memory
for module in all_modules:
    analyze(module)
```

**Do this**:
```python
# Good: Generator (lazy evaluation)
def get_all_modules():
    for file in Path('core/').rglob('*.py'):
        yield parse_module(file)  # One at a time

for module in get_all_modules():  # Low memory usage
    analyze(module)
```

---

#### 3. Clean Up Large Variables

**After processing large data**:

```python
# Process large dataset
large_data = load_large_dataset('data/10gb_file.csv')
result = process(large_data)

# Clean up explicitly
del large_data
import gc
gc.collect()  # Force garbage collection

return result
```

---

#### 4. Use Memory-Mapped Files

**For very large files** (>1GB):

```python
import mmap

def search_large_file(file_path, pattern):
    """Search large file without loading into memory"""
    with open(file_path, 'r+b') as f:
        # Memory-map the file
        mmapped_file = mmap.mmap(f.fileno(), 0)

        # Search
        index = mmapped_file.find(pattern.encode())

        mmapped_file.close()
        return index

# Usage
position = search_large_file('data/massive_log.txt', 'ERROR')
```

---

## Git Performance

### Problem: Git Operations are Slow

**Symptom**: `git add .` or `git commit` takes >30 seconds

**Solutions**:

#### 1. Use .gitignore Effectively

**Add to `.gitignore`**:
```
# Large data files (don't commit)
data/*.csv
data/*.db
data/raw/

# Caches
__pycache__/
*.pyc
.pytest_cache/
.mypy_cache/

# Virtual environments
venv/
env/

# IDE files
.vscode/
.idea/

# Large logs
logs/*.log
```

---

#### 2. Use Git LFS for Large Files

**Install Git Large File Storage**:
```bash
# Install
git lfs install

# Track large files
git lfs track "*.csv"
git lfs track "*.db"
git lfs track "*.pkl"

# Commit
git add .gitattributes
git commit -m "Setup Git LFS"
```

**Benefits**:
- Large files stored separately
- Only pointers in git history
- Faster clone, pull, push

---

#### 3. Shallow Clones for CI

**In CI/CD pipelines**:
```yaml
# .github/workflows/test.yml
steps:
  - uses: actions/checkout@v3
    with:
      fetch-depth: 1  # Shallow clone (faster)
```

---

#### 4. Commit Specific Files

**Instead of**:
```bash
# Bad: Adds everything (slow if many files)
git add .
git commit -m "Update"
```

**Do this**:
```bash
# Good: Add only what changed
git add core/auth.py tests/test_auth.py data/state/master_state.json
git commit -m "[Module 1.1] Complete authentication"
```

---

#### 5. Use Git Worktrees for Parallel Work

**For multiple branches simultaneously**:
```bash
# Create worktree for feature branch
git worktree add ../myproject-feature feature/new-auth

# Work in separate directory (no branch switching needed)
cd ../myproject-feature
# ... implement feature ...

# Commit and remove worktree
git commit -m "Implement new auth"
cd ../myproject
git worktree remove ../myproject-feature
```

---

## Context Window Optimization

### Problem: Hitting Context Limits Too Quickly

**Symptom**: Context reaches 35% after 2-3 small operations

**Solutions**:

#### 1. Use File Summaries Instead of Full Files

**Create summaries**:

**Script**: `scripts/create_file_summary.py`
```python
def summarize_file(file_path):
    """Create summary of Python file (interfaces only)"""
    import ast

    with open(file_path, 'r') as f:
        tree = ast.parse(f.read())

    summary = []
    summary.append(f"# {file_path}\n")

    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            args = [arg.arg for arg in node.args.args]
            summary.append(f"def {node.name}({', '.join(args)}): ...")

        elif isinstance(node, ast.ClassDef):
            summary.append(f"\nclass {node.name}:")
            for item in node.body:
                if isinstance(item, ast.FunctionDef):
                    args = [arg.arg for arg in item.args.args]
                    summary.append(f"    def {item.name}({', '.join(args)}): ...")

    return '\n'.join(summary)

# Usage
summary = summarize_file('core/auth.py')
# Returns only function signatures (not implementations)
```

**Benefits**:
- 100 lines vs 1000 lines
- 10x reduction in context usage

---

#### 2. Reference Files by Path, Not Content

**In recovery prompts**:

**Instead of**:
```markdown
## Files Changed

core/auth.py:
```python
def authenticate(username, password):
    # ... 50 lines of code ...
```
```

**Do this**:
```markdown
## Files Changed

- core/auth.py (authentication logic, see core/auth.py:15-65)
- tests/test_auth.py (12 tests, all passing)

Key interfaces:
- authenticate(username, password) -> Token
- validate_token(token) -> User | None
```

**Savings**: 90% reduction in context usage

---

#### 3. Use Compressed State Representation

**For module lists**:

**Instead of**:
```json
{
  "modules_complete": [
    {"id": "1.1", "name": "Authentication", "lines": 200, "tests": 15},
    {"id": "1.2", "name": "Authorization", "lines": 180, "tests": 12},
    {"id": "1.3", "name": "Sessions", "lines": 150, "tests": 10}
  ]
}
```

**Do this**:
```json
{
  "modules_complete": ["1.1", "1.2", "1.3"]
}
```

**Details stored separately**:
```json
// data/state/module_1.1_state.json
{
  "id": "1.1",
  "name": "Authentication",
  "lines": 200,
  "tests": 15
}
```

---

## Benchmarking and Monitoring

### Track Performance Metrics

**Script**: `scripts/benchmark.py`
```python
#!/usr/bin/env python3
"""
Benchmark framework operations.
"""

import time
import json
from pathlib import Path

def benchmark_operation(name, func, *args, **kwargs):
    """Benchmark single operation"""
    start = time.time()
    result = func(*args, **kwargs)
    elapsed = time.time() - start

    return {
        'operation': name,
        'duration_ms': round(elapsed * 1000, 2),
        'timestamp': time.time()
    }

def run_benchmarks():
    """Run all benchmarks"""
    results = []

    # Benchmark: Load state
    results.append(benchmark_operation(
        'load_state',
        load_state,
        'data/state/master_state.json'
    ))

    # Benchmark: Save state
    state = load_state('data/state/master_state.json')
    results.append(benchmark_operation(
        'save_state',
        atomic_write_json,
        'data/state/master_state.json',
        state
    ))

    # Benchmark: Read large file
    results.append(benchmark_operation(
        'read_large_file',
        read_file,
        'core/large_module.py'
    ))

    # Benchmark: Git status
    results.append(benchmark_operation(
        'git_status',
        lambda: subprocess.run(['git', 'status'], capture_output=True)
    ))

    return results

def main():
    """Run benchmarks and display results"""
    print("Running performance benchmarks...\n")

    results = run_benchmarks()

    print(f"{'Operation':<20} {'Duration (ms)':<15}")
    print("-" * 35)

    for result in results:
        print(f"{result['operation']:<20} {result['duration_ms']:<15}")

    # Save results
    with open('data/benchmarks.json', 'w') as f:
        json.dump(results, f, indent=2)

    print("\n✅ Benchmarks complete")

if __name__ == '__main__':
    main()
```

**Run regularly**:
```bash
# Benchmark after major changes
python scripts/benchmark.py

# Compare to baseline
python scripts/compare_benchmarks.py
```

---

### Performance Monitoring Dashboard

**Track over time**:

```python
# scripts/performance_dashboard.py
import json
import matplotlib.pyplot as plt
from pathlib import Path

def plot_performance_trends():
    """Plot performance trends over time"""
    benchmark_files = sorted(Path('data/benchmarks/').glob('*.json'))

    operations = {}
    for bench_file in benchmark_files:
        with open(bench_file) as f:
            data = json.load(f)

        for result in data:
            op = result['operation']
            if op not in operations:
                operations[op] = {'timestamps': [], 'durations': []}

            operations[op]['timestamps'].append(result['timestamp'])
            operations[op]['durations'].append(result['duration_ms'])

    # Plot
    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    axes = axes.flatten()

    for i, (op, data) in enumerate(operations.items()):
        if i >= 4:
            break
        axes[i].plot(data['timestamps'], data['durations'])
        axes[i].set_title(op)
        axes[i].set_ylabel('Duration (ms)')

    plt.tight_layout()
    plt.savefig('reports/performance_trends.png')
    print("✅ Performance dashboard saved to reports/performance_trends.png")

if __name__ == '__main__':
    plot_performance_trends()
```

---

## Performance Checklist

**Before deploying to large project**:

- [ ] Large files (>1000 lines) split into modules
- [ ] State updates use atomic writes
- [ ] .gitignore excludes large data files
- [ ] Git LFS configured for large binaries
- [ ] File index created for fast searches
- [ ] Memory profiling done (no leaks)
- [ ] Benchmarks run (all operations <500ms)
- [ ] Context usage tested (stays below 25%)

---

## Performance Targets

| Operation | Target | Critical |
|-----------|--------|----------|
| Load state file | <100ms | <500ms |
| Save state file | <200ms | <1s |
| Read Python file (<1K lines) | <50ms | <200ms |
| Git status | <300ms | <2s |
| Git commit | <1s | <5s |
| Run unit tests | <10s | <60s |

**If any operation exceeds critical threshold**: Investigate and optimize

---

**Performance Guide version**: 3.4
**Last updated**: January 2025
