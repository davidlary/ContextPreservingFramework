# Example: CLI Tool (File Organizer)

**Project**: Command-line file organizer with sorting, tagging, and search
**Language**: Python 3.11+ with Click
**Duration**: 4-6 hours (5 modules across 2 sessions)
**Framework**: Context-Preserving v3.0

---

## Project Overview

**What we're building**: A CLI tool that organizes files by type, date, or custom tags with search functionality.

**Commands**:
- `organize init` - Initialize configuration
- `organize sort <dir>` - Sort files by type/date
- `organize tag <file> [tags...]` - Add tags to files
- `organize search <query>` - Search by name/tag
- `organize stats <dir>` - Show directory statistics
- `organize undo` - Undo last operation

**Features**:
- Multiple sorting strategies (by type, date, size)
- Custom tagging system with SQLite backend
- Dry-run mode for preview
- Undo functionality
- Progress bars for large operations
- Configuration file (~/.organizer/config.yaml)

---

## Framework Setup (20 minutes)

### Step 1: Initialize Framework

```bash
cd ~/projects/file_organizer
python scripts/setup_framework.py --interactive

# Prompts:
# Project name? file_organizer
# Project type? coding
# Language? python
# Project kind? cli_tool

# Output: Framework files created
```

**Or manual setup**:
```bash
cd ~/projects/file_organizer

# Copy framework files
cp -r ~/ContextPreservingFramework/03_TEMPLATES/CLAUDE.md.template ./CLAUDE.md
cp -r ~/ContextPreservingFramework/03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md
cp -r ~/ContextPreservingFramework/03_TEMPLATES/project_types/coding/master_state_coding.json ./data/state/master_state.json

# Customize
vi CLAUDE.md  # Set project: file_organizer, test: pytest tests/
vi AUTONOMOUS_MODE.md  # Set STATUS: ACTIVE, scope: Modules 1.1-1.5
```

### Step 2: Define Project Structure

**Create**: `ARCHITECTURE.md`

```markdown
# File Organizer Architecture

## Technology Stack
- Language: Python 3.11+
- CLI Framework: Click 8.1+
- Database: SQLite 3
- Testing: pytest
- Progress: tqdm
- Config: PyYAML

## Module Breakdown

### Module 1.1: Core Config & Setup (200 lines, 1 hour)
**Files**: `core/config.py`, `core/setup.py`
**Tests**: 8 tests
**Purpose**: Configuration management, initialization

### Module 1.2: File Operations (250 lines, 1.5 hours)
**Files**: `core/operations.py`, `core/file_utils.py`
**Tests**: 12 tests
**Purpose**: Sort, move, copy operations with undo

### Module 1.3: Tagging System (220 lines, 1 hour)
**Files**: `core/tags.py`, `core/database.py`
**Tests**: 10 tests
**Purpose**: Tag management with SQLite backend

### Module 1.4: Search & Stats (180 lines, 1 hour)
**Files**: `core/search.py`, `core/stats.py`
**Tests**: 8 tests
**Purpose**: Search by name/tag, directory statistics

### Module 1.5: CLI Interface (240 lines, 1 hour)
**Files**: `cli.py`, `commands/*.py`
**Tests**: 10 tests
**Purpose**: Click commands, progress bars, output formatting
```

---

## Project Structure

```
file_organizer/
├── CLAUDE.md
├── AUTONOMOUS_MODE.md
├── ARCHITECTURE.md
├── README.md
├── pyproject.toml
├── cli.py                  # Main CLI entry point
├── core/
│   ├── __init__.py
│   ├── config.py           # Config management
│   ├── setup.py            # Initialization
│   ├── operations.py       # File operations
│   ├── file_utils.py       # File utilities
│   ├── tags.py             # Tagging system
│   ├── database.py         # SQLite backend
│   ├── search.py           # Search functionality
│   └── stats.py            # Statistics
├── commands/
│   ├── __init__.py
│   ├── sort.py
│   ├── tag.py
│   ├── search.py
│   └── stats.py
├── tests/
│   ├── test_config.py
│   ├── test_operations.py
│   ├── test_tags.py
│   ├── test_search.py
│   └── test_cli.py
├── data/
│   └── state/
│       └── master_state.json
└── logs/
    └── operation_log.txt
```

---

## Implementation Session Example

### Session 1: Modules 1.1-1.3 (Foundation + Tagging)

**Context Budget**: Start 0% → Target < 35%

#### Starting Prompt

```
Resume file_organizer project - Session 1

Location: ~/projects/file_organizer
Autonomous mode: ACTIVE (see AUTONOMOUS_MODE.md)

Goal: Implement Modules 1.1-1.3 (Config, Operations, Tagging)

Instructions:
1. Read ARCHITECTURE.md for module specs
2. Implement Module 1.1 (config + setup)
3. Write tests, verify passing
4. Git commit
5. Repeat for Modules 1.2-1.3
6. Keep context < 35%
```

#### Module 1.1: Config & Setup (1 hour)

**Actions**:
1. Create `core/config.py` (100 lines)
   - Load/save YAML config
   - Default configuration
   - Validation
2. Create `core/setup.py` (100 lines)
   - Initialize ~/.organizer directory
   - Create default config
   - Setup SQLite database
3. Write `tests/test_config.py` (8 tests)
4. Run: `pytest tests/test_config.py -v`
5. Git commit

**Context**: 5% → 12%

**Commit**:
```
[Session 1] Module 1.1: Config & Setup - COMPLETE

Changes:
- Files created: core/config.py, core/setup.py
- Tests: tests/test_config.py (8/8 passing)
- Validation: Config loads/saves correctly

Duration: 58 minutes
Next: Module 1.2 (File Operations)

🤖 Autonomous execution - Session 1, Progress: 20%
```

#### Module 1.2: File Operations (1.5 hours)

**Actions**:
1. Create `core/file_utils.py` (120 lines)
   - File type detection
   - Safe move/copy operations
2. Create `core/operations.py` (130 lines)
   - Sort by type/date/size
   - Dry-run mode
   - Undo stack
3. Write `tests/test_operations.py` (12 tests)
4. Run: `pytest tests/test_operations.py -v`
5. Git commit

**Context**: 12% → 24%

**Commit**:
```
[Session 1] Module 1.2: File Operations - COMPLETE

Changes:
- Files created: core/operations.py, core/file_utils.py
- Tests: tests/test_operations.py (12/12 passing)
- Validation: Sort and undo working correctly

Duration: 85 minutes
Next: Module 1.3 (Tagging)

🤖 Autonomous execution - Session 1, Progress: 50%
```

#### Module 1.3: Tagging System (1 hour)

**Actions**:
1. Create `core/database.py` (100 lines)
   - SQLite connection
   - Schema creation
   - CRUD operations
2. Create `core/tags.py` (120 lines)
   - Add/remove tags
   - List tags
   - Tag queries
3. Write `tests/test_tags.py` (10 tests)
4. Run: `pytest tests/ -v`
5. Git commit

**Context**: 24% → 33%

**Session End Actions**:
1. Create recovery prompt
2. Update master_state.json
3. Final git commit

**Final Context**: 33% ✅ (Under 35% threshold)

---

### Session 2: Modules 1.4-1.5 (Search + CLI)

**Starting Context**: 0% (new session)

#### Starting Prompt

```
Resume file_organizer project - Session 2

Location: ~/projects/file_organizer
Git commit: [hash from Session 1]
Autonomous mode: ACTIVE

Status:
✅ Completed: Modules 1.1-1.3 (Config, Operations, Tagging)
🔄 In progress: Module 1.4 (Search & Stats)
⏳ Next: Module 1.5 (CLI Interface)

Instructions:
1. Read data/state/master_state.json
2. Verify tests still passing: pytest tests/
3. Implement Module 1.4 (search + stats)
4. Implement Module 1.5 (CLI commands)
5. Full integration test
6. Keep context < 35%
```

#### Module 1.4: Search & Stats (1 hour)

**Actions**:
1. Create `core/search.py` (100 lines)
   - Search by name (glob patterns)
   - Search by tags
   - Combined queries
2. Create `core/stats.py` (80 lines)
   - Directory statistics
   - File type distribution
   - Tag usage stats
3. Write `tests/test_search.py` (8 tests)
4. Run tests
5. Git commit

**Context**: 0% → 11%

#### Module 1.5: CLI Interface (1.5 hours)

**Actions**:
1. Create `cli.py` (120 lines)
   - Click group setup
   - Common options
   - Error handling
2. Create command files (120 lines total)
   - `commands/sort.py`
   - `commands/tag.py`
   - `commands/search.py`
   - `commands/stats.py`
3. Write `tests/test_cli.py` (10 tests)
4. Run full test suite
5. Manual testing with sample files
6. Git commit

**Context**: 11% → 28%

**Final Actions**:
1. Run full test suite: `pytest tests/ -v --cov`
2. Update README with usage examples
3. Test installation: `pip install -e .`
4. Final commit
5. Tag release: `git tag v1.0.0`

---

## Lessons Learned

### What Worked Well

1. **Small modules**: Each module under 250 lines kept context manageable
2. **Test-first**: Writing tests immediately caught issues early
3. **Frequent commits**: Never lost work, easy to track progress
4. **Autonomous mode**: No interruptions, smooth flow
5. **Click framework**: Made CLI development fast and clean

### Challenges

1. **Undo complexity**: Needed to track operation history carefully
2. **Path handling**: Cross-platform compatibility required extra testing
3. **Tag queries**: SQLite query optimization took iteration

### Context Management

- Session 1: 0% → 33% (3 modules, 3.5 hours)
- Session 2: 0% → 28% (2 modules, 2.5 hours)
- **Total**: 6 hours, 2 sessions, 5 modules complete

### Metrics

- **Files created**: 15
- **Lines of code**: 1,090
- **Test coverage**: 95%
- **Tests**: 48 passing
- **Sessions**: 2
- **Total time**: 6 hours

---

## Key Takeaways

1. **CLI tools are great for framework practice**: Smaller scope than web APIs
2. **Click + pytest = fast development**: Excellent tooling support
3. **SQLite for local data**: Perfect for CLI tools, no server setup
4. **Undo is valuable**: Users appreciate safety net for file operations
5. **Progress bars matter**: Make tool feel professional

---

## Next Steps

**If continuing this project**:

1. **Module 2.1**: Advanced filters (regex, date ranges)
2. **Module 2.2**: Plugin system for custom sorters
3. **Module 2.3**: Configuration presets/profiles
4. **Module 2.4**: Export/import tag databases

**Estimated**: 4 more hours, 1-2 sessions
