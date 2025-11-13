# Research: Framework Naming & Directory Structure

**Date**: 2025-11-13
**Purpose**: Deep research on naming conventions and directory structure for installable framework
**Problem**: Generic names (install.sh, .framework/) could conflict with user projects
**Status**: Research Phase - Critical Architecture Decision

---

## Problem Statement

### User's Observation (CORRECT)

> "Perhaps we should use names other than install.sh, update.sh, uninstall.sh as they may conflict with the project one is creating"

**User is absolutely right.** Generic script names will conflict with:
- User's own `install.sh` for their project
- CI/CD scripts with same names
- Standard project tooling
- Package manager scripts

### User's Proposal

1. **Script Naming**: `install_CPF.sh`, `update_CPF.sh`, `uninstall_CPF.sh`
   - "CPF" = Context-Preserving Framework
   - Clear namespace, no conflicts

2. **Directory Structure**: `CPF/` subdirectory
   - Keeps framework files separate from project code
   - Tidy, not confused with project files
   - All framework files in one place

**Initial Assessment**: This makes excellent sense. Let me research best practices.

---

## Research: Established Framework Patterns

### Category 1: User-Level Frameworks (Installed in Home Directory)

#### Oh My Zsh
**Directory**: `~/.oh-my-zsh/`
- Hidden directory (starts with `.`)
- Lives in home directory (not per-project)
- Contains: themes, plugins, tools
- Installation: `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

**Key Insights**:
- Uses hidden directory (user tool, not per-project)
- Install script lives IN the framework directory (`tools/install.sh`)
- Clear namespace in directory name
- Widely trusted (millions of users)

---

#### Rustup (Rust Toolchain)
**Directory**: `~/.rustup/`
- Hidden directory
- Lives in home directory
- Contains: toolchains, downloads, settings
- Installation: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

**Key Insights**:
- Hidden directory for user tool
- Install script is separate (`rustup-init`)
- Manages updates internally
- Clear separation from project code

---

#### NVM (Node Version Manager)
**Directory**: `~/.nvm/`
- Hidden directory
- Lives in home directory
- Contains: node versions, npm packages
- Installation: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash`

**Key Insights**:
- Hidden directory
- Per-project: Uses `.nvmrc` files in project roots
- Clear namespace

---

### Category 2: Project-Level Frameworks (Installed in Each Project)

#### Node.js / npm
**Directory**: `node_modules/`
- **VISIBLE** directory (not hidden)
- Per-project
- Contains: all dependencies
- `.gitignore`'d but visible to developers

**Key Insights**:
- Visible directory (developers need to see it)
- Clear, standard name
- Per-project installation
- Separation from project source code (not in `src/`)

---

#### Python virtualenv / venv
**Directory**: `venv/` or `.venv/`
- Common patterns:
  - `venv/` (visible)
  - `.venv/` (hidden)
  - `env/` (visible)
- Per-project
- Contains: Python packages, interpreters

**Key Insights**:
- Both visible and hidden used
- Per-project
- `.gitignore`'d
- Developers know to look for it

---

#### Ruby Gems / Bundler
**Directory**: `vendor/bundle/`
- **VISIBLE** directory
- Per-project (when using `bundle install --path vendor/bundle`)
- Contains: Ruby gems
- Clear namespace (`vendor/` for third-party code)

**Key Insights**:
- Uses `vendor/` prefix for third-party code
- Visible directory
- Standard location developers expect

---

### Category 3: Git-Related Frameworks

#### Git Submodules
**Directory**: User-specified, commonly:
- `.git/modules/` (Git's internal tracking)
- Submodule itself: any directory name

**Key Insights**:
- User controls directory name
- Often uses descriptive names
- Can be hidden or visible

---

#### Pre-commit Framework (Python)
**Directory**: `.pre-commit/`
- **HIDDEN** directory
- Contains: hook scripts, cached repos
- Configuration: `.pre-commit-config.yaml` (hidden)

**Key Insights**:
- Hidden directory (infrastructure, not code)
- Clear namespace
- Dot-prefix convention

---

## Analysis: Hidden vs Visible Directory

### Hidden Directory (`.CPF/`)

**Pros**:
- ✅ Doesn't clutter project root in `ls` output
- ✅ Follows convention for infrastructure (.git, .github, .vscode)
- ✅ Less likely to be accidentally modified
- ✅ Standard for tool configuration

**Cons**:
- ❌ Less discoverable (developers might not know it's there)
- ❌ Harder to navigate to (need `ls -a`)
- ❌ Could be mistaken for "not important"

**Used By**: Git (.git), Oh My Zsh (.oh-my-zsh), Rustup (.rustup), Pre-commit (.pre-commit)

---

### Visible Directory (`CPF/`)

**Pros**:
- ✅ Highly discoverable (appears in normal `ls`)
- ✅ Clearly visible to developers
- ✅ Easier to navigate to
- ✅ "What you see is what you get"
- ✅ Better for educational purposes (framework repository itself)

**Cons**:
- ❌ Clutters project root slightly
- ❌ Could be confused with project code (if not clearly named)

**Used By**: node_modules, vendor/, venv/ (when visible)

---

### Hybrid Approach

**Pattern**: Visible directory for framework, hidden files for config

Example:
```
project/
├── CPF/                        ← VISIBLE framework directory
│   ├── scripts/
│   ├── .claude/
│   └── docs/
├── .cpf-config.json            ← HIDDEN config
├── data/                       ← VISIBLE project data
│   └── state/                  ← Project state
└── src/                        ← Project code
```

---

## Analysis: Directory Naming Options

### Option 1: `CPF/` (User's Suggestion)
**Full Name**: Context-Preserving Framework

**Pros**:
- ✅ Short, concise (3 characters)
- ✅ Clear acronym
- ✅ Easy to type
- ✅ No conflicts with common names
- ✅ Namespace clarity

**Cons**:
- ❌ Acronym might not be immediately obvious to new users
- ❌ Could conflict if project also uses "CPF" acronym

**Verdict**: ✅ **GOOD CHOICE**

---

### Option 2: `.cpf/` (Hidden Version)
**Same as Option 1 but hidden**

**Pros**: Same as Option 1 + hidden benefits
**Cons**: Same as Option 1 + hidden drawbacks

**Verdict**: ✅ **GOOD ALTERNATIVE**

---

### Option 3: `context-framework/`
**Longer, more explicit**

**Pros**:
- ✅ Self-documenting (clear what it is)
- ✅ No acronym confusion
- ✅ Professional naming

**Cons**:
- ❌ Long (17 characters)
- ❌ Harder to type
- ❌ Takes more space in listings

**Verdict**: ⚠️ **TOO VERBOSE**

---

### Option 4: `.claude/cpf/`
**Nested under existing .claude/ directory**

**Pros**:
- ✅ Uses existing .claude/ namespace
- ✅ Groups Claude-related files together
- ✅ Hidden from casual view

**Cons**:
- ❌ Assumes .claude/ exists (not always true in projects)
- ❌ Nested structure harder to navigate
- ❌ Framework is more than just Claude config

**Verdict**: ❌ **NOT RECOMMENDED** - Framework is standalone

---

### Option 5: `cpf/` (Lowercase)
**Same as Option 1 but lowercase**

**Unix Convention**: Lowercase for directories is more common

**Pros**:
- ✅ Follows Unix convention (lowercase preferred)
- ✅ Consistent with: node_modules, vendor, venv
- ✅ Easier to type (no shift key)

**Cons**:
- ❌ Less visually distinct in mixed-case listings

**Verdict**: ✅ **BETTER THAN CPF/** (follows Unix conventions)

---

## Analysis: Script Naming Options

### Option 1: `install_CPF.sh` (User's Suggestion)

**Pros**:
- ✅ Clear prefix shows action
- ✅ Suffix shows framework
- ✅ No conflicts
- ✅ Groups alphabetically: `install_CPF.sh`, `update_CPF.sh`, `uninstall_CPF.sh`

**Cons**:
- ❌ Mixed case (CPF in caps)
- ❌ Underscore convention less common in Unix

**Verdict**: ✅ **GOOD, but could be improved**

---

### Option 2: `cpf-install.sh`

**Pros**:
- ✅ Prefix shows framework first
- ✅ Dash convention (more Unix-like)
- ✅ Lowercase (consistent)
- ✅ Groups alphabetically: `cpf-install.sh`, `cpf-update.sh`, `cpf-uninstall.sh`

**Cons**:
- ❌ Less obvious that action is the primary purpose

**Verdict**: ✅ **BETTER** (more Unix-like)

---

### Option 3: `cpf_install.sh`

**Pros**:
- ✅ Prefix shows framework
- ✅ Underscore separator
- ✅ Lowercase

**Cons**:
- ❌ Underscore less conventional for executable scripts

**Verdict**: ⚠️ **ACCEPTABLE** but dash preferred

---

### Option 4: `install-cpf.sh`

**Pros**:
- ✅ Action-first (clear what it does)
- ✅ Dash convention
- ✅ Lowercase

**Cons**:
- ❌ Doesn't group by framework in alphabetical listings

**Verdict**: ⚠️ **LESS IDEAL** for grouping

---

## Research: Where Should Different Files Go?

### Framework Files (Read-Only, Updated from Git)

**Location**: `cpf/` or `.cpf/`

**Contents**:
- `scripts/` - All framework scripts
- `docs/` - Framework documentation
- `.claude/hooks/` - Hook templates
- `templates/` - File templates
- `examples/` - Example configurations
- `README.md` - Framework readme
- `cpf-install.sh` - Installation script
- `cpf-update.sh` - Update script
- `cpf-uninstall.sh` - Uninstall script

**Principle**: Everything that comes from the framework repository

---

### Project State Files (User-Specific, Mutable)

**Location**: `data/state/` or `.cpf-state/`

**Contents**:
- `master_state.json` - Project state tracking
- `context_tracking.json` - Context usage
- `operation_log.txt` - Operation logs
- `checkpoints/` - Checkpoint files

**Principle**: Project-specific data that changes during development

**Important**: These should NOT be in `cpf/` because:
- They're user-generated, not framework-generated
- They persist across framework updates
- Each project has its own state

---

### Project Configuration (User-Specific, Semi-Static)

**Location**: `.cpf/config/` or root level

**Contents**:
- `cpf-config.json` - Project-specific framework settings
- `file_manifest.json` - Authorized files list
- `AUTONOMOUS_MODE.md` - Autonomous mode setting

**Principle**: Configuration that users might edit

---

### Git Hooks (Symlinks to Framework)

**Location**: `.git/hooks/`

**Contents** (symlinks):
- `pre-commit` → `../../cpf/scripts/pre-commit-master.sh`
- `post-commit` → `../../cpf/scripts/post-commit-master.sh`
- `pre-push` → `../../cpf/scripts/pre-push-master.sh`

**Principle**: Git-native location, symlinks to framework scripts

---

## Recommended Architecture

### Directory Structure (Clean Separation)

```
my-project/                           ← User's project root
│
├── cpf/                              ← Framework directory (VISIBLE)
│   ├── scripts/                      ← All framework scripts
│   │   ├── pre-commit-master.sh
│   │   ├── validate_semver.sh
│   │   ├── pre_write_check.sh
│   │   └── ... (all other scripts)
│   │
│   ├── docs/                         ← Framework documentation
│   │   ├── guides/
│   │   ├── rules/
│   │   └── README.md
│   │
│   ├── templates/                    ← File templates
│   │   ├── state_template.json
│   │   └── config_template.json
│   │
│   ├── .claude/                      ← Framework metadata (hidden)
│   │   └── hooks/
│   │       └── compliance_enforcement.json
│   │
│   ├── .git/                         ← Framework's own git (if submodule)
│   │
│   ├── cpf-install.sh                ← Installation script ⭐
│   ├── cpf-update.sh                 ← Update script ⭐
│   ├── cpf-uninstall.sh              ← Uninstall script ⭐
│   │
│   └── README.md                     ← Framework readme
│
├── .cpf/                             ← Project-specific config (HIDDEN)
│   ├── config.json                   ← Project configuration
│   ├── file_manifest.json            ← Authorized files
│   └── AUTONOMOUS_MODE.md            ← Autonomous mode setting
│
├── data/                             ← Project data (VISIBLE or HIDDEN)
│   └── state/                        ← State tracking
│       ├── master_state.json
│       ├── context_tracking.json
│       └── operation_log.txt
│
├── .git/                             ← Project's git
│   └── hooks/                        ← Git hooks (SYMLINKS)
│       ├── pre-commit       → ../../cpf/scripts/pre-commit-master.sh
│       ├── post-commit      → ../../cpf/scripts/post-commit-master.sh
│       └── pre-push         → ../../cpf/scripts/pre-push-master.sh
│
├── .gitignore                        ← Project gitignore
│   # Should include:
│   # data/state/          (state files are project-specific)
│   # .cpf/config.json     (config might have secrets)
│
├── src/                              ← User's project code
│   └── ...
│
└── README.md                         ← User's project readme
```

---

### Key Design Principles

1. **Clear Separation**:
   - `cpf/` = Framework code (from Git, read-only)
   - `.cpf/` = Project config (user-editable)
   - `data/state/` = Project state (changes frequently)
   - `src/` = User's project code (completely separate)

2. **No Conflicts**:
   - All framework scripts prefixed: `cpf-*.sh`
   - Framework directory: `cpf/` (unique name)
   - Config directory: `.cpf/` (unique name)

3. **Discoverability**:
   - `cpf/` is VISIBLE (developers know framework is there)
   - Scripts have clear names (`cpf-install.sh` not `install.sh`)
   - README.md in `cpf/` explains the framework

4. **Git-Friendly**:
   - `cpf/` can be a Git submodule (tracked)
   - `data/state/` should be `.gitignore`'d (project-specific)
   - `.cpf/` might be `.gitignore`'d (could have secrets)

5. **Clean Updates**:
   - Framework updates: `cd cpf && git pull && ./cpf-update.sh`
   - Updates only touch `cpf/` directory
   - User state and config preserved

6. **Clean Uninstall**:
   - Remove `cpf/` directory
   - Remove `.cpf/` directory (optional)
   - Remove `.git/hooks/` symlinks
   - Remove `data/state/` (optional)
   - Project code untouched

---

## Alternative: Hidden Framework Directory

### Directory Structure (Hidden Framework)

```
my-project/
│
├── .cpf/                             ← Framework directory (HIDDEN)
│   ├── framework/                    ← Actual framework code
│   │   ├── scripts/
│   │   ├── docs/
│   │   └── ...
│   │
│   ├── config/                       ← Project config
│   │   ├── config.json
│   │   └── file_manifest.json
│   │
│   └── state/                        ← Project state
│       ├── master_state.json
│       └── context_tracking.json
│
├── .git/
│   └── hooks/                        ← Symlinks to .cpf/framework/scripts/
│
└── src/                              ← User code
```

**Pros**:
- ✅ Cleaner project root (`ls` shows only project files)
- ✅ Follows convention (.git, .github, .vscode)
- ✅ All framework stuff in one hidden directory

**Cons**:
- ❌ Less discoverable
- ❌ Harder to navigate
- ❌ Doesn't separate framework-from-git vs project-specific-config

**Verdict**: ⚠️ **POSSIBLE** but less clear than separate directories

---

## Script Location: Inside vs Outside Framework Directory

### Option A: Scripts INSIDE Framework Directory (Recommended)

```
cpf/
├── cpf-install.sh        ← Inside framework
├── cpf-update.sh
├── cpf-uninstall.sh
└── scripts/
    └── ...
```

**Usage**:
```bash
# User installs
git submodule add https://github.com/user/CPF.git cpf
cd cpf
./cpf-install.sh
```

**Pros**:
- ✅ Scripts travel with framework
- ✅ Always up-to-date with framework version
- ✅ Clear that scripts are part of framework

**Cons**:
- ❌ Need to `cd` into directory first

**Verdict**: ✅ **RECOMMENDED** (standard pattern, see Oh My Zsh)

---

### Option B: Scripts at Project Root

```
my-project/
├── cpf-install.sh        ← At root
├── cpf-update.sh
├── cpf-uninstall.sh
└── cpf/
    └── ...
```

**Pros**:
- ✅ Easier to run from project root
- ✅ More discoverable

**Cons**:
- ❌ Clutters project root
- ❌ Conflicts possible
- ❌ Not clear these belong to framework

**Verdict**: ❌ **NOT RECOMMENDED** (defeats purpose of separation)

---

## Final Recommendations

### 1. Directory Names ✅

**Framework Directory**: `cpf/` (VISIBLE)
- Lowercase (Unix convention)
- Short (3 chars)
- Clear namespace
- No conflicts

**Project Config**: `.cpf/` (HIDDEN)
- Hidden (infrastructure files)
- Clear namespace
- Separate from framework code

**Project State**: `data/state/` (VISIBLE or HIDDEN as user prefers)
- Traditional location
- Or `.cpf/state/` if prefer everything under .cpf/

---

### 2. Script Names ✅

**Pattern**: `cpf-{action}.sh`

**Scripts**:
- `cpf-install.sh` - Installation
- `cpf-update.sh` - Update from base repo
- `cpf-uninstall.sh` - Clean removal

**Rationale**:
- Prefix `cpf-` groups them alphabetically
- Dash convention (Unix-like)
- Lowercase (standard)
- Clear namespace (no conflicts)

---

### 3. Directory Structure ✅

```
my-project/
├── cpf/                  ← Framework (VISIBLE, from Git)
├── .cpf/                 ← Config (HIDDEN, user-editable)
├── data/state/           ← State (VISIBLE/HIDDEN, mutable)
├── .git/hooks/           ← Git hooks (symlinks to cpf/scripts/)
└── src/                  ← User code (completely separate)
```

---

### 4. Installation Command ✅

```bash
# Clone framework as submodule
git submodule add https://github.com/user/ContextPreservingFramework.git cpf

# Run installer
cd cpf && ./cpf-install.sh && cd ..

# Or one-liner:
git submodule add https://github.com/user/ContextPreservingFramework.git cpf && \
    (cd cpf && ./cpf-install.sh)
```

---

## Comparison Table

| Aspect | Original Design | User's Suggestion | Final Recommendation |
|--------|----------------|-------------------|---------------------|
| Framework dir | `.framework/` | `CPF/` | `cpf/` ✓ (lowercase) |
| Install script | `install.sh` | `install_CPF.sh` | `cpf-install.sh` ✓ |
| Update script | `update.sh` | `update_CPF.sh` | `cpf-update.sh` ✓ |
| Uninstall script | `uninstall.sh` | `uninstall_CPF.sh` | `cpf-uninstall.sh` ✓ |
| Config location | `.claude/` | `CPF/` (mixed) | `.cpf/` ✓ (separate) |
| State location | `data/state/` | (not specified) | `data/state/` ✓ (keep) |
| Visibility | Hidden | Visible | Visible ✓ |
| Conflict risk | HIGH | LOW | NONE ✓ |

---

## Conclusion

**User's observation is correct**: Generic names cause conflicts.

**Recommended Solution**:
1. ✅ Use `cpf/` for framework directory (visible, lowercase)
2. ✅ Use `cpf-*.sh` for scripts (clear namespace, Unix convention)
3. ✅ Use `.cpf/` for project config (hidden, separate from framework)
4. ✅ Keep `data/state/` for project state (traditional location)
5. ✅ Clear separation between framework (from Git) and project-specific files

**Next Steps**:
1. Update architecture diagrams
2. Implement `cpf-install.sh` with new structure
3. Test installation in isolated project
4. Update README.md with new naming

**END OF RESEARCH**
