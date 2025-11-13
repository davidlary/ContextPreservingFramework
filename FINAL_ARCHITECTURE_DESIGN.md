# Final Architecture Design

**Date**: 2025-11-13
**Purpose**: Final architecture incorporating all user feedback
**Status**: Ready for implementation

---

## User Preferences Incorporated

1. ✅ **Script Naming**: `cpf-install.sh`, `cpf-update.sh`, `cpf-uninstall.sh` (not generic names)
2. ✅ **Framework Directory**: `cpf/` visible (clear separation from project code)
3. ✅ **Config Directory**: `.cpf/` hidden (user's preference) ⭐
4. ✅ **Documentation**: Organized in `cpf/docs/` subdirectories (not cluttering root)
5. ✅ **No Conflicts**: All framework files clearly namespaced

---

## Final Directory Structure

### User Project After Framework Installation

```
my-project/                           ← User's project root
│
├── cpf/                              ← Framework (VISIBLE) ⭐
│   │
│   ├── README.md                     ← Short framework overview
│   ├── CLAUDE.md                     ← Claude Code activation file
│   ├── LICENSE                       ← Framework license
│   │
│   ├── docs/                         ← ALL documentation ⭐
│   │   ├── README.md                 ← Documentation index
│   │   ├── core/                     ← Core protocol
│   │   │   ├── CLAUDE_AUTONOMOUS_PROTOCOL.md
│   │   │   ├── PROTOCOL_CORE_RULES.md
│   │   │   └── ...
│   │   ├── guides/                   ← User guides
│   │   │   ├── 01_INTRODUCTION.md
│   │   │   ├── 02_SETUP_GUIDE.md
│   │   │   └── ...
│   │   ├── research/                 ← Research documents
│   │   │   ├── RESEARCH_INSTALLABLE_FRAMEWORK_ARCHITECTURE.md
│   │   │   └── ...
│   │   ├── testing/                  ← Test reports
│   │   ├── releases/                 ← Release notes
│   │   ├── analysis/                 ← Framework analysis
│   │   ├── sessions/                 ← Development notes
│   │   └── archive/                  ← Historical docs
│   │
│   ├── scripts/                      ← All framework scripts
│   │   ├── pre-commit-master.sh
│   │   ├── validate_semver.sh
│   │   ├── pre_write_check.sh
│   │   └── ... (all enforcement scripts)
│   │
│   ├── .claude/                      ← Framework metadata (hidden)
│   │   └── hooks/
│   │       └── compliance_enforcement.json
│   │
│   ├── templates/                    ← File templates
│   │   ├── state_template.json
│   │   └── config_template.json
│   │
│   ├── cpf-install.sh                ← Installation script ⭐
│   ├── cpf-update.sh                 ← Update script ⭐
│   └── cpf-uninstall.sh              ← Uninstall script ⭐
│
├── .cpf/                             ← Project config & state (HIDDEN) ⭐
│   ├── config.json                   ← Project configuration
│   ├── file_manifest.json            ← Authorized files list
│   ├── AUTONOMOUS_MODE.md            ← Autonomous mode setting
│   └── state/                        ← Project state tracking
│       ├── master_state.json
│       ├── context_tracking.json
│       └── operation_log.txt
│
├── .git/                             ← Project's git
│   └── hooks/                        ← Git hooks (symlinks) ⭐
│       ├── pre-commit    → ../../cpf/scripts/pre-commit-master.sh
│       ├── post-commit   → ../../cpf/scripts/post-commit-master.sh
│       └── pre-push      → ../../cpf/scripts/pre-push-master.sh
│
├── .gitignore                        ← Project gitignore
│   # Recommended entries:
│   # .cpf/state/          (state files are project-specific)
│   # .cpf/config.json     (might contain secrets)
│
├── README.md                         ← User's project README ⭐
├── src/                              ← User's project code
│   └── ...
└── ... (other user files)
```

---

## Key Design Decisions

### 1. Framework Directory: `cpf/` (Visible)

**Why Visible**:
- ✅ Developers should know framework is installed
- ✅ Easy to navigate (`cd cpf`)
- ✅ Follows pattern: `node_modules/`, `vendor/`, `venv/`
- ✅ Professional appearance

**Why Lowercase**:
- ✅ Unix convention (lowercase preferred)
- ✅ Consistent with standard directories
- ✅ Easier to type (no shift key)

---

### 2. Config/State Directory: `.cpf/` (Hidden) ⭐

**Why Hidden** (User's preference):
- ✅ Infrastructure files (like `.git`, `.github`)
- ✅ Less clutter in project root
- ✅ Standard convention for tool config
- ✅ Clear namespace

**Contents**:
- `config.json` - Framework configuration
- `file_manifest.json` - Authorized files
- `AUTONOMOUS_MODE.md` - Autonomous mode setting
- `state/` - State tracking files

**Why Combined**:
- ✅ All framework data in one place
- ✅ Easy to .gitignore entire directory (if desired)
- ✅ Clean separation from project files

---

### 3. Documentation: `cpf/docs/` (Organized)

**Structure**:
```
cpf/docs/
├── README.md                 ← Documentation index
├── core/                     ← Core protocol (6 files)
├── guides/                   ← User guides (existing 14 guides)
├── research/                 ← Research documents (6 files)
├── testing/                  ← Test reports (4 files)
├── releases/                 ← Release notes (5 files)
├── analysis/                 ← Framework analysis (6 files)
├── sessions/                 ← Development notes (3 files)
└── archive/                  ← Historical docs (1 file)
```

**Benefits**:
- ✅ Clean root (only 3 files: README, CLAUDE, LICENSE)
- ✅ Easy to find specific docs
- ✅ Professional organization
- ✅ Matches major frameworks (Vue, React, Kubernetes)

---

### 4. Script Naming: `cpf-{action}.sh`

**Scripts**:
- `cpf-install.sh` - Installation
- `cpf-update.sh` - Update from base repo
- `cpf-uninstall.sh` - Clean removal

**Why This Pattern**:
- ✅ Clear namespace (`cpf-` prefix)
- ✅ No conflicts with user scripts
- ✅ Groups alphabetically
- ✅ Unix convention (dashes, lowercase)

---

### 5. Git Hooks: Symlinks

**Location**: `.git/hooks/` (standard Git location)

**Contents** (symlinks to framework):
```bash
.git/hooks/pre-commit → ../../cpf/scripts/pre-commit-master.sh
.git/hooks/post-commit → ../../cpf/scripts/post-commit-master.sh
.git/hooks/pre-push → ../../cpf/scripts/pre-push-master.sh
```

**Benefits**:
- ✅ Hooks auto-update when framework updates
- ✅ Easy to disable (remove symlink)
- ✅ Clear that hooks come from framework

---

## README.md Strategy

### Two Separate READMEs (No Conflict)

#### 1. Framework README (`cpf/README.md`)
**Purpose**: Describe the framework itself
**Audience**: Developers using/contributing to framework
**Length**: Short (~50 lines), links to docs

**Contents**:
```markdown
# Context-Preserving Framework for Claude Code

Comprehensive context management for Claude Code development.

## Installation

Already installed in this project. See [Installation Guide](docs/guides/02_SETUP_GUIDE.md).

## Documentation

- **Core**: [docs/core/](docs/core/)
- **Guides**: [docs/guides/](docs/guides/)
- **Research**: [docs/research/](docs/research/)

## License

[License info]
```

#### 2. Project README (`README.md` at root)
**Purpose**: Describe the user's project
**Audience**: Users of the project
**Length**: Whatever user wants

**Optional Section**:
```markdown
## Context-Preserving Framework

This project uses the Context-Preserving Framework for Claude Code.
Framework files: `cpf/` | Documentation: [cpf/docs/](cpf/docs/)
```

**No Conflict**: Different files, different purposes ✅

---

## Installation Flow

### User Installing Framework

```bash
# Step 1: Clone framework as submodule
cd ~/my-project
git submodule add https://github.com/user/ContextPreservingFramework.git cpf

# Step 2: Run installer
cd cpf
./cpf-install.sh

# Result: Framework installed, hooks set up, .cpf/ created
```

### What `cpf-install.sh` Does

1. ✅ Creates `.cpf/` directory
2. ✅ Copies `templates/config_template.json` → `.cpf/config.json`
3. ✅ Copies `templates/state_template.json` → `.cpf/state/master_state.json`
4. ✅ Creates `.cpf/file_manifest.json` (empty initially)
5. ✅ Creates `.cpf/AUTONOMOUS_MODE.md` with STATUS: ACTIVE
6. ✅ Creates `.cpf/state/` directory
7. ✅ Creates symlinks in `.git/hooks/`
   - `pre-commit` → `../../cpf/scripts/pre-commit-master.sh`
   - `post-commit` → `../../cpf/scripts/post-commit-master.sh`
   - `pre-push` → `../../cpf/scripts/pre-push-master.sh`
8. ✅ Adds `.cpf/state/` to `.gitignore` (optional)
9. ✅ Displays success message with next steps

---

## Update Flow

### User Updating Framework

```bash
# Step 1: Pull latest framework code
cd ~/my-project/cpf
git pull origin main

# Step 2: Run updater
./cpf-update.sh

# Result: Framework updated, hooks refreshed, config migrated if needed
```

### What `cpf-update.sh` Does

1. ✅ Checks framework version (compare current vs installed)
2. ✅ Updates symlinks in `.git/hooks/` (in case paths changed)
3. ✅ Migrates config if schema changed (backwards compatibility)
4. ✅ Displays changelog since last update
5. ✅ Warns if breaking changes require action
6. ✅ Preserves user's `.cpf/config.json` and state

---

## Uninstall Flow

### User Removing Framework

```bash
cd ~/my-project/cpf
./cpf-uninstall.sh

# Optionally remove framework directory
cd ..
rm -rf cpf/
```

### What `cpf-uninstall.sh` Does

1. ✅ Removes symlinks from `.git/hooks/`
2. ✅ Asks: "Remove .cpf/ directory?" (user choice)
   - If yes: Removes `.cpf/` (config & state)
   - If no: Preserves `.cpf/` for later
3. ✅ Removes `.cpf/state/` from `.gitignore`
4. ✅ Displays instructions for final cleanup
5. ✅ Framework directory (`cpf/`) remains (user can delete manually)

---

## Separation of Concerns

### Framework Files (from Git, read-only)
**Location**: `cpf/`
**Contents**: Scripts, docs, templates, install scripts
**Updates**: `git pull` in `cpf/` directory
**Ownership**: Framework repository

### Project Config (user-editable, project-specific)
**Location**: `.cpf/`
**Contents**: config.json, file_manifest.json, AUTONOMOUS_MODE.md
**Updates**: User edits manually
**Ownership**: User project

### Project State (mutable, frequently changing)
**Location**: `.cpf/state/`
**Contents**: master_state.json, context_tracking.json, operation_log.txt
**Updates**: Framework writes automatically
**Ownership**: User project
**.gitignore**: Recommended (state is transient)

### Project Code (completely separate)
**Location**: `src/`, `lib/`, etc.
**Contents**: User's project code
**Updates**: User develops normally
**Ownership**: User project

---

## Benefits Summary

### Compared to Original Design

| Aspect | Original | Final Design | Improvement |
|--------|----------|--------------|-------------|
| Framework dir | `.framework/` | `cpf/` | ✅ Visible, lowercase, clearer |
| Config dir | `.claude/` | `.cpf/` | ✅ Hidden, dedicated namespace |
| State dir | `data/state/` | `.cpf/state/` | ✅ Grouped with config |
| Scripts | `install.sh` | `cpf-install.sh` | ✅ No conflicts |
| Docs | Root (31 files!) | `cpf/docs/` | ✅ Organized, not cluttering |
| README | Conflict risk | Separate paths | ✅ No confusion |

---

### Addresses All User Concerns

1. ✅ **Script Naming**: No conflicts (`cpf-*.sh` not generic)
2. ✅ **Framework Separation**: Clear `cpf/` directory
3. ✅ **Config Separation**: Hidden `.cpf/` directory (user's preference)
4. ✅ **Documentation**: Organized in `cpf/docs/` subdirectories
5. ✅ **README Conflict**: Separate files (`cpf/README.md` vs `README.md`)
6. ✅ **Clean Root**: Only 3 files in `cpf/` root (README, CLAUDE, LICENSE)
7. ✅ **Professional**: Matches patterns from major frameworks

---

## Implementation Steps

### Phase 1: Reorganize Documentation (This Repository)

```bash
# Create docs structure
mkdir -p docs/{core,guides,research,testing,releases,analysis,sessions,archive}

# Move files (preserves Git history)
git mv CLAUDE_AUTONOMOUS_PROTOCOL.md docs/core/
git mv PROTOCOL_CORE_RULES.md docs/core/
# ... (move all 28 files from root to appropriate subdirectories)

# Move existing guides/ to docs/guides/
git mv guides/ docs/

# Create documentation index
# Create docs/README.md

# Simplify root README.md
# Update to be short overview with links

# Commit reorganization
git commit -m "REORGANIZE: Move documentation to cpf/docs/ structure (cleans root directory)"
```

### Phase 2: Implement Installation Scripts

```bash
# Create installation scripts
touch cpf-install.sh cpf-update.sh cpf-uninstall.sh
chmod +x cpf-*.sh

# Implement each script
# Test in isolated project
```

### Phase 3: Update README with Installation Instructions

```bash
# Simplify README.md
# Add installation section
# Link to docs/guides/02_SETUP_GUIDE.md for details
```

### Phase 4: Test Complete Installation Flow

```bash
# Create test project
# Install framework
# Verify all files in correct locations
# Test hooks work
# Test update flow
# Test uninstall flow
```

---

## Final Recommendations

### Immediate Next Actions

1. **Reorganize Documentation** (Phase 1)
   - Move 28 markdown files from root to `docs/` subdirectories
   - Create `docs/README.md` index
   - Simplify root `README.md`
   - Commit reorganization

2. **Implement Installation System** (Phase 2)
   - Create `cpf-install.sh`
   - Create `cpf-update.sh`
   - Create `cpf-uninstall.sh`
   - Test in isolated project

3. **Update Documentation** (Phase 3)
   - Update root README with installation instructions
   - Update all internal links to new paths
   - Verify no broken links

4. **Comprehensive Testing** (Phase 4)
   - Test installation flow
   - Test update flow
   - Test uninstall flow
   - Verify hooks work correctly

---

## Conclusion

**User Concerns Addressed**: ✅ ALL

1. ✅ Script naming conflicts → Fixed with `cpf-*.sh`
2. ✅ Framework separation → Clear `cpf/` directory
3. ✅ Config organization → Hidden `.cpf/` (user's preference)
4. ✅ Documentation clutter → Organized in `cpf/docs/`
5. ✅ README conflict → Separate paths, clear purposes

**Status**: Architecture finalized, ready for implementation

**Next Step**: Begin Phase 1 (documentation reorganization)

**END OF DESIGN**
