# Analysis: Claude Code File Locations

**Date**: 2025-11-13
**Purpose**: Determine which files MUST be at project root for Claude Code to find them
**Critical**: User is correct - Claude Code configuration files need specific locations

---

## Problem Statement

### User's Concern (CORRECT)

> "Perhaps some of the Claude Code configuration markdown files need to be in the root directory though, that is why we need to think hard about it"

**User is absolutely right.** Claude Code looks for configuration files in specific locations. We can't just move everything to `cpf/docs/` without breaking Claude Code functionality.

---

## Files Claude Code Looks For

### According to Claude Code Documentation

Claude Code looks for project instructions in this order:

1. **Primary**: `CLAUDE.md` at project root
2. **Secondary**: `rules/CLAUDE.md`
3. **Tertiary**: `.claude/` directory (for hooks, etc.)

**If these files are not in the expected locations, Claude Code won't find them.**

---

## Scenario Analysis

### Scenario 1: Framework Repository Itself

**This Repository** (ContextPreservingFramework):
```
ContextPreservingFramework/
├── CLAUDE.md                     ← Instructions for developing THE FRAMEWORK ⭐
├── PROTOCOL_CORE_RULES.md        ← Framework protocol
├── .claude/                      ← Framework hooks
│   └── hooks/
│       └── compliance_enforcement.json
├── docs/                         ← Documentation about the framework
└── scripts/                      ← Framework scripts
```

**Purpose of CLAUDE.md here**: Tells Claude how to work on the framework repository itself (e.g., "follow these rules when developing the framework")

---

### Scenario 2: User Project with Framework Installed

**User's Project**:
```
my-project/
├── CLAUDE.md                     ← User's project instructions ⭐
│   # Could include:
│   # 1. Project-specific rules
│   # 2. Reference to framework: "See cpf/docs/core/ for framework rules"
│   # 3. OR symlink to framework's rules
│
├── .claude/                      ← User's project Claude config
│   └── hooks/
│       └── compliance_enforcement.json  ← Copied/symlinked from framework
│
├── cpf/                          ← Framework (installed)
│   ├── CLAUDE.md                 ← Framework's own instructions
│   ├── docs/                     ← Framework documentation
│   │   └── core/
│   │       └── PROTOCOL_CORE_RULES.md
│   └── scripts/
│
└── src/                          ← User's code
```

**Key Question**: What should `my-project/CLAUDE.md` contain?

---

## Options for User Project's CLAUDE.md

### Option A: Symlink to Framework

```bash
# my-project/CLAUDE.md is symlink
my-project/CLAUDE.md → cpf/CLAUDE.md
```

**Pros**:
- ✅ Auto-updates with framework
- ✅ Single source of truth

**Cons**:
- ❌ No way to add project-specific instructions
- ❌ Symlinks might not work on all systems (Windows)

---

### Option B: Copy from Framework (Installation)

```bash
# cpf-install.sh copies framework CLAUDE.md to project root
cp cpf/CLAUDE.md ./CLAUDE.md
```

**Pros**:
- ✅ Works on all systems
- ✅ User can edit for project-specific needs

**Cons**:
- ❌ Gets out of sync with framework updates
- ❌ Conflicts if project already has CLAUDE.md

---

### Option C: Composite (Recommended) ⭐

**User's project CLAUDE.md** (short, references framework):
```markdown
# My Project - Claude Code Instructions

## Project-Specific Instructions

[User's project-specific instructions here]

## Context-Preserving Framework

This project uses the Context-Preserving Framework.

**Framework Documentation**: See [cpf/docs/](cpf/docs/)
**Framework Rules**: See [cpf/docs/core/PROTOCOL_CORE_RULES.md](cpf/docs/core/PROTOCOL_CORE_RULES.md)

For framework usage in this project, follow the rules in the framework documentation.
```

**Framework's CLAUDE.md** (in `cpf/`):
```markdown
# Context-Preserving Framework - Development Instructions

[Instructions for developing the framework itself]

For using this framework in a project, see [docs/guides/02_SETUP_GUIDE.md](docs/guides/02_SETUP_GUIDE.md)
```

**Pros**:
- ✅ User keeps control of project CLAUDE.md
- ✅ Can add project-specific instructions
- ✅ Clear reference to framework docs
- ✅ No conflicts
- ✅ Works on all systems

**Cons**:
- ❌ User needs to maintain their CLAUDE.md

**Verdict**: ✅ **RECOMMENDED** - Most flexible

---

## Critical Files That MUST Be at Project Root

### For Claude Code to Function

1. **CLAUDE.md** (or `rules/CLAUDE.md`)
   - **Location**: Project root
   - **Purpose**: Claude Code reads this for project instructions
   - **Solution**: User creates/maintains their own, references framework

2. **.claude/hooks/compliance_enforcement.json**
   - **Location**: Project root `.claude/` directory
   - **Purpose**: Claude Code reads this for hook configuration
   - **Solution**: `cpf-install.sh` copies from framework to project `.claude/`

---

## Files That Can Be in `cpf/docs/`

### Documentation (Not Read by Claude Code Automatically)

All these can be in `cpf/docs/`:
- ✅ PROTOCOL_CORE_RULES.md
- ✅ CLAUDE_AUTONOMOUS_PROTOCOL.md
- ✅ Research documents
- ✅ Test reports
- ✅ Release notes
- ✅ Guides

**Why**: These are documentation files. Claude Code doesn't automatically look for them. They're referenced explicitly when needed.

---

## Revised Architecture

### Framework Repository (This Repo)

```
ContextPreservingFramework/
│
├── CLAUDE.md                     ← Instructions for framework development ⭐
├── README.md                     ← Short overview
├── LICENSE
│
├── docs/                         ← All documentation (moved here)
│   ├── README.md
│   ├── core/                     ← Core protocol
│   │   ├── CLAUDE_AUTONOMOUS_PROTOCOL.md
│   │   ├── PROTOCOL_CORE_RULES.md
│   │   ├── COMPLETION_INSTRUCTIONS.md
│   │   └── ...
│   ├── guides/                   ← User guides
│   ├── research/                 ← Research docs
│   ├── testing/                  ← Test reports
│   ├── releases/                 ← Release notes
│   ├── analysis/                 ← Analysis docs
│   ├── sessions/                 ← Session notes
│   └── archive/                  ← Historical docs
│
├── .claude/                      ← Framework's hooks (template)
│   └── hooks/
│       └── compliance_enforcement.json
│
├── scripts/                      ← All scripts
│
├── templates/                    ← Templates for user projects
│   ├── CLAUDE_template.md        ← Template for user's CLAUDE.md
│   ├── config_template.json
│   └── state_template.json
│
├── cpf-install.sh                ← Installation script
├── cpf-update.sh
└── cpf-uninstall.sh
```

**Key Point**: Only `CLAUDE.md` stays at root (for framework development). Everything else moves to `docs/`.

---

### User Project (After Installation)

```
my-project/
│
├── CLAUDE.md                     ← User's project instructions ⭐
│   # References framework: "See cpf/docs/core/"
│
├── .claude/                      ← Copied from cpf/.claude/ ⭐
│   └── hooks/
│       └── compliance_enforcement.json
│
├── .cpf/                         ← Project config (hidden)
│   ├── config.json
│   ├── file_manifest.json
│   └── state/
│
├── cpf/                          ← Framework (visible)
│   ├── CLAUDE.md                 ← Framework development instructions
│   ├── README.md
│   ├── docs/                     ← Framework documentation
│   │   ├── core/
│   │   │   ├── PROTOCOL_CORE_RULES.md
│   │   │   └── ...
│   │   └── guides/
│   ├── scripts/
│   └── ...
│
├── .git/hooks/                   ← Symlinks to cpf/scripts/
│
├── README.md                     ← User's project README
└── src/                          ← User's code
```

---

## Installation Script Behavior

### What `cpf-install.sh` Does

1. ✅ Creates `.cpf/` directory
2. ✅ Copies `templates/config_template.json` → `.cpf/config.json`
3. ✅ Creates `.cpf/state/` directory
4. ✅ **Copies `cpf/.claude/` to project `.claude/`** ⭐
   - This ensures hooks configuration is at project root
5. ✅ Creates symlinks in `.git/hooks/`
6. ✅ **Optionally creates `CLAUDE.md` from template** (if doesn't exist)
   - If user already has `CLAUDE.md`: Don't touch it
   - If user doesn't have `CLAUDE.md`: Copy template with framework references
7. ✅ Displays success message

---

## User's Second Point: Self-Consistent Updates

### What This Means

If we reorganize files, we must update:

1. ✅ All internal markdown links
   - Example: If `PROTOCOL_CORE_RULES.md` moves to `docs/core/`, all links to it must update
2. ✅ All script paths in hooks
   - `.claude/hooks/compliance_enforcement.json` references `scripts/*.sh`
   - Must verify paths still correct
3. ✅ All documentation references
   - `README.md` links to docs
   - Guides link to other guides
4. ✅ Installation scripts
   - `cpf-install.sh` references file locations
   - Must update for new structure
5. ✅ Test that nothing breaks
   - Run hooks manually
   - Verify all links work
   - Test installation flow

---

## Migration Strategy (Self-Consistent)

### Phase 1: Create Structure + Move Files

```bash
# Create docs structure
mkdir -p docs/{core,guides,research,testing,releases,analysis,sessions,archive}

# Move files (preserves history)
git mv CLAUDE_AUTONOMOUS_PROTOCOL.md docs/core/
git mv PROTOCOL_CORE_RULES.md docs/core/
git mv COMPLETION_INSTRUCTIONS.md docs/core/
# ... (move all except CLAUDE.md, README.md, LICENSE)

# Move existing guides
git mv guides/* docs/guides/

# KEEP at root:
# - CLAUDE.md (for framework development)
# - README.md (framework overview)
# - LICENSE
# - cpf-*.sh scripts
```

### Phase 2: Update All Links

```bash
# Find all markdown files
find . -name "*.md" -type f

# For each file, search for links to moved files
# Example: Search for links to PROTOCOL_CORE_RULES.md
grep -r "PROTOCOL_CORE_RULES.md" *.md docs/*.md scripts/*.sh

# Update each link:
# Before: [Rules](PROTOCOL_CORE_RULES.md)
# After:  [Rules](docs/core/PROTOCOL_CORE_RULES.md)

# Or relative from docs:
# Before: [Rules](../PROTOCOL_CORE_RULES.md)
# After:  [Rules](core/PROTOCOL_CORE_RULES.md)
```

### Phase 3: Update Scripts

```bash
# Check scripts reference correct paths
grep -r "PROTOCOL_CORE_RULES" scripts/*.sh

# Update any hardcoded paths
```

### Phase 4: Update Hooks Configuration

```bash
# Check .claude/hooks/compliance_enforcement.json
# Verify all script paths are relative and still correct
jq '.hooks' .claude/hooks/compliance_enforcement.json

# Script paths like "scripts/pre_write_check.sh" should still work
# (they're relative to framework root)
```

### Phase 5: Create Documentation Index

```bash
# Create docs/README.md with navigation
cat > docs/README.md <<'EOF'
# Framework Documentation

## Core Protocol
- [Full Protocol](core/CLAUDE_AUTONOMOUS_PROTOCOL.md)
- [Core Rules](core/PROTOCOL_CORE_RULES.md)
- [Completion Instructions](core/COMPLETION_INSTRUCTIONS.md)

## Guides
- [Setup Guide](guides/02_SETUP_GUIDE.md)
- [All Guides](guides/)

## Research
- [Installable Architecture](research/RESEARCH_INSTALLABLE_FRAMEWORK_ARCHITECTURE.md)
- [All Research](research/)

## Testing & Releases
- [Testing Reports](testing/)
- [Release Notes](releases/)
EOF
```

### Phase 6: Test Everything

```bash
# Test 1: Verify no broken links
# Use markdown link checker or manually click all links

# Test 2: Test hooks still work
bash scripts/pre-commit-master.sh

# Test 3: Test installation in fresh project
mkdir /tmp/test-project
cd /tmp/test-project
git init
git submodule add <framework-url> cpf
cd cpf && ./cpf-install.sh && cd ..
# Verify installation worked

# Test 4: Verify Claude Code still finds files
# Check that .claude/hooks/compliance_enforcement.json at project root
# Check that hooks reference correct script paths
```

---

## Final Recommendations

### Files at Root (Framework Repository)

**MUST stay at root**:
1. ✅ `CLAUDE.md` - For framework development (Claude Code looks for this)
2. ✅ `README.md` - Entry point
3. ✅ `LICENSE` - Legal requirement
4. ✅ `cpf-install.sh`, `cpf-update.sh`, `cpf-uninstall.sh` - Install scripts

**Everything else** → `docs/` subdirectories

---

### Files at Root (User Project After Installation)

**MUST be at user project root**:
1. ✅ `CLAUDE.md` - User's project instructions (references framework)
2. ✅ `.claude/` - Claude Code configuration (copied from framework)

**Framework files** → `cpf/` directory (subdirectory of user project)

---

## Conclusion

### User is Correct

1. ✅ **Some files must be at root** - Claude Code looks for them
2. ✅ **Changes must be self-consistent** - Update all references

### Solution

1. ✅ Keep `CLAUDE.md` at framework root (for framework development)
2. ✅ Install script copies `.claude/` to user project root
3. ✅ User maintains their own `CLAUDE.md` (can reference framework)
4. ✅ Move all other docs to `docs/` subdirectories
5. ✅ Update all links, paths, references self-consistently
6. ✅ Test thoroughly before committing

### Next Step

Execute migration carefully with self-consistent updates to all references.

**END OF ANALYSIS**
