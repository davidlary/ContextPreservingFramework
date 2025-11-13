# File Organization Policy

**Date**: 2025-11-13
**Version**: 1.0.0
**Purpose**: Define WHERE files go - now and in the future
**Status**: Policy Document (Framework Constitution)

---

## Purpose

This document defines the **file organization system** for the Context-Preserving Framework. It specifies:

1. ✅ Where existing files should be located
2. ✅ Where NEW files should be placed when generated
3. ✅ Rules enforced by the framework itself
4. ✅ Self-consistency requirements

**This is a living policy** - when new file types are created, this document defines where they go.

---

## Principles

1. **Claude Code Compatibility**: Files Claude Code looks for must be at expected locations
2. **Clear Separation**: Framework code vs project config vs project state
3. **No Conflicts**: Framework files namespaced to avoid user project conflicts
4. **Discoverability**: Important files visible, infrastructure hidden
5. **Future-Proof**: Rules apply to files not yet created

---

## File Categories & Locations

### Category 1: Claude Code Activation Files
**Purpose**: Files Claude Code reads to activate and configure
**Must Be**: At project root (Claude Code looks here)

| File | Location | Required | Purpose |
|------|----------|----------|---------|
| `CLAUDE.md` | Project root | YES | Primary activation file |
| `rules/CLAUDE.md` | Project root | NO | Alternative location |
| `.claude/hooks/compliance_enforcement.json` | Project root | YES | Hook configuration |

**Rule**: These files MUST be at project root. Framework cannot move them.

**When Generated**:
- Installation: `cpf-install.sh` copies `.claude/` from framework to project root
- Updates: User maintains `CLAUDE.md`, framework updates `.claude/hooks/`

---

### Category 2: Framework Source Code (Read-Only)
**Purpose**: Framework code distributed from Git repository
**Location**: `cpf/` directory when installed in user project

#### 2A: Root-Level Framework Files
**Location**: `cpf/` (framework root)
**Purpose**: Essential framework entry points

| File | Purpose | Keep at Root? |
|------|---------|---------------|
| `CLAUDE.md` | Instructions for framework development | YES |
| `README.md` | Framework overview | YES |
| `LICENSE` | Legal | YES |
| `cpf-install.sh` | Installation script | YES |
| `cpf-update.sh` | Update script | YES |
| `cpf-uninstall.sh` | Uninstall script | YES |

**Total**: 6 files at framework root (acceptable)

---

#### 2B: Framework Documentation
**Location**: `cpf/docs/` (organized subdirectories)
**Purpose**: All framework documentation

| Subdirectory | Contents | Example Files |
|--------------|----------|---------------|
| `docs/core/` | Core protocol files | `PROTOCOL_CORE_RULES.md`, `CLAUDE_AUTONOMOUS_PROTOCOL.md` |
| `docs/guides/` | User guides | `02_SETUP_GUIDE.md`, `04_CORE_WORKFLOW.md` |
| `docs/rules/` | Individual rule documentation | `RULE_01_ZERO_HARDCODING.md`, `RULE_02_NAMED_FILES.md` |
| `docs/research/` | Research documents | `RESEARCH_*.md` |
| `docs/testing/` | Test reports | `PHASE4_TEST_REPORT_*.md` |
| `docs/releases/` | Release notes | `FRAMEWORK_V*.md` |
| `docs/analysis/` | Framework analysis | `*_ANALYSIS.md`, `*_AUDIT.md` |
| `docs/sessions/` | Development session notes | `SESSION_*.md` |
| `docs/archive/` | Historical documents | `LEGACY_*.md` |

**Rule for New Documentation**:
- Protocol changes → `docs/core/`
- User-facing guides → `docs/guides/`
- New rule documentation → `docs/rules/`
- Research findings → `docs/research/`
- Test reports → `docs/testing/`
- Release notes → `docs/releases/`
- Analysis/audits → `docs/analysis/`
- Session notes → `docs/sessions/`
- Deprecated docs → `docs/archive/`

---

#### 2C: Framework Scripts
**Location**: `cpf/scripts/`
**Purpose**: All enforcement and utility scripts

| Script Type | Naming Pattern | Example |
|-------------|----------------|---------|
| Pre-commit validators | `validate_*.sh` | `validate_semver.sh`, `validate_docs_sync.sh` |
| Master hooks | `*-master.sh` | `pre-commit-master.sh`, `post-commit-master.sh` |
| PreToolUse hooks | `pre_*.sh` | `pre_write_check.sh`, `pre_context_check.sh` |
| PostToolUse hooks | `post_*.sh` | `post_git_validation.sh`, `post_test_validation.sh` |
| Utility scripts | `*.sh` | `setup_project.sh`, `check_compliance.sh` |

**Rule for New Scripts**:
- Pre-commit validator → `scripts/validate_{what}.sh`
- Claude Code PreToolUse hook → `scripts/pre_{what}_check.sh`
- Claude Code PostToolUse hook → `scripts/post_{what}_validation.sh`
- Master hook → `scripts/{hook-name}-master.sh`
- Utility → `scripts/{purpose}.sh`

**All scripts MUST**:
- Be executable (`chmod +x`)
- Have header comment explaining purpose
- Follow naming convention above

---

#### 2D: Framework Metadata
**Location**: `cpf/.claude/`
**Purpose**: Framework's own Claude Code configuration (template)

| File | Purpose |
|------|---------|
| `.claude/hooks/compliance_enforcement.json` | Hook definitions |
| `.claude/config.json` | Framework config (if needed) |

**Rule**: These are templates. Installation copies to project root `.claude/`

---

#### 2E: Framework Templates
**Location**: `cpf/templates/`
**Purpose**: Templates for user project files

| Template | Copied To | Purpose |
|----------|-----------|---------|
| `CLAUDE_template.md` | Project `CLAUDE.md` | User's CLAUDE.md with framework references |
| `config_template.json` | `.cpf/config.json` | Project configuration |
| `state_template.json` | `.cpf/state/master_state.json` | Initial state |
| `file_manifest_template.json` | `.cpf/file_manifest.json` | Authorized files |

**Rule for New Templates**: Add to `templates/` with `_template` suffix

---

### Category 3: Project Configuration (User-Editable)
**Purpose**: Project-specific framework configuration
**Location**: `.cpf/` (hidden directory)

| File | Purpose | Generated By | Editable? |
|------|---------|--------------|-----------|
| `.cpf/config.json` | Framework settings | Installation | YES |
| `.cpf/file_manifest.json` | Authorized files | Installation | YES |
| `.cpf/AUTONOMOUS_MODE.md` | Autonomous mode | Installation | YES |
| `.cpf/project_rules.md` | Project-specific rules | User | YES |

**Rule for New Config Files**: Place in `.cpf/` root, use lowercase with underscores

---

### Category 4: Project State (Runtime Generated)
**Purpose**: Mutable state that changes during development
**Location**: `.cpf/state/` (hidden subdirectory)

| File | Purpose | Generated By | Frequency |
|------|---------|--------------|-----------|
| `.cpf/state/master_state.json` | Current state | Framework | Every operation |
| `.cpf/state/context_tracking.json` | Context usage | Framework | Every operation |
| `.cpf/state/operation_log.txt` | Operation log | Framework | Every operation |
| `.cpf/state/checkpoints/*.json` | Checkpoint files | Framework | On checkpoint |

**Rule for New State Files**: Place in `.cpf/state/`, use lowercase with underscores

**Git Ignore**: Recommend adding `.cpf/state/` to `.gitignore` (transient data)

---

### Category 5: Project Progress Tracking
**Purpose**: Track development progress, todos, milestones
**Location**: `.cpf/progress/` (hidden subdirectory)

| File | Purpose | Generated By | Editable? |
|------|---------|--------------|-----------|
| `.cpf/progress/todos.json` | Current todo list | Framework | YES |
| `.cpf/progress/milestones.json` | Project milestones | User/Framework | YES |
| `.cpf/progress/session_progress.json` | Session-by-session progress | Framework | NO |

**Rule for New Progress Files**: Place in `.cpf/progress/`, use JSON format

---

### Category 6: Project Logs
**Purpose**: Detailed operational logging
**Location**: `.cpf/logs/` (hidden subdirectory)

| File | Purpose | Generated By | Rotation? |
|------|---------|--------------|-----------|
| `.cpf/logs/operations.log` | Detailed operation log | Framework | YES (daily) |
| `.cpf/logs/errors.log` | Error log | Framework | YES (daily) |
| `.cpf/logs/performance.log` | Performance metrics | Framework | YES (daily) |
| `.cpf/logs/hook_execution.log` | Hook execution details | Framework | YES (daily) |

**Log Rotation**: Keep last 7 days, archive older logs to `.cpf/logs/archive/`

**Rule for New Logs**: Place in `.cpf/logs/`, suffix with `.log`, implement rotation

**Git Ignore**: Recommend adding `.cpf/logs/` to `.gitignore` (can grow large)

---

### Category 7: Issue Tracking
**Purpose**: Track detected issues, rule violations, warnings
**Location**: `.cpf/issues/` (hidden subdirectory)

| File | Purpose | Generated By | Retention |
|------|---------|--------------|-----------|
| `.cpf/issues/violations.log` | Rule violations detected | Framework | Until resolved |
| `.cpf/issues/warnings.log` | Warnings (non-blocking) | Framework | Until resolved |
| `.cpf/issues/active_issues.json` | Currently active issues | Framework | Until resolved |
| `.cpf/issues/resolved/` | Historical issues | Framework | Archive (30 days) |

**Issue Lifecycle**:
1. Issue detected → Logged to `violations.log` or `warnings.log`
2. Added to `active_issues.json`
3. When resolved → Moved to `resolved/` with timestamp
4. After 30 days → Archived or deleted

**Rule for New Issue Types**: Place in `.cpf/issues/`, use structured format (JSON or log)

**Git Ignore**: Optional - user may want to track violations in Git

---

### Category 8: Test Files
**Purpose**: Framework test suite (if we add one)
**Location**: `cpf/tests/`

| File Type | Location | Example |
|-----------|----------|---------|
| Unit tests | `tests/unit/` | `test_semver_validator.sh` |
| Integration tests | `tests/integration/` | `test_install_flow.sh` |
| Fixtures | `tests/fixtures/` | `sample_project/` |

**Rule for New Tests**: Follow testing framework conventions, group by type

---

## Rules for Future File Generation

### When Framework Generates New Files

#### Rule Documentation (New Rules Added)

**Scenario**: Framework adds RULE 21

**Actions Required**:
1. ✅ Create `docs/rules/RULE_21_{NAME}.md` (detailed documentation)
2. ✅ Update `docs/core/PROTOCOL_CORE_RULES.md` (add to list)
3. ✅ Update `.claude/hooks/compliance_enforcement.json` (add enforcement if technical)
4. ✅ Create enforcement script (if needed): `scripts/pre_{rule}_check.sh` or `scripts/post_{rule}_validation.sh`
5. ✅ Add to `docs/releases/FRAMEWORK_V{X.Y.Z}_SUMMARY.md` (release notes)
6. ✅ Update `README.md` (mention new rule count)

**Self-Consistency Check**:
- [ ] Rule documented in `docs/rules/`
- [ ] Rule added to core rules list
- [ ] Enforcement implemented (if technical)
- [ ] Release notes updated
- [ ] Tests added for rule (if testable)
- [ ] README updated

---

#### Enforcement Scripts (New Validators)

**Scenario**: Need new validator for detecting X

**Actions Required**:
1. ✅ Create script: `scripts/validate_x.sh` (if pre-commit) OR `scripts/pre_x_check.sh` (if PreToolUse) OR `scripts/post_x_validation.sh` (if PostToolUse)
2. ✅ Make executable: `chmod +x scripts/validate_x.sh`
3. ✅ Add header comment explaining purpose, version, usage
4. ✅ Register in `.claude/hooks/compliance_enforcement.json` (if Claude Code hook)
5. ✅ OR register in `scripts/pre-commit-master.sh` (if Git hook)
6. ✅ Document in `docs/core/ENFORCEMENT_MECHANISMS.md`
7. ✅ Add test for script in `tests/`

**Self-Consistency Check**:
- [ ] Script created with proper naming
- [ ] Script executable
- [ ] Script has header documentation
- [ ] Script registered in appropriate hook
- [ ] Enforcement documented
- [ ] Tests added

---

#### Test Reports (New Test Results)

**Scenario**: Run comprehensive testing, generate report

**Actions Required**:
1. ✅ Create report: `docs/testing/{PHASE_OR_TYPE}_TEST_REPORT_v{VERSION}.md`
2. ✅ Follow standard format (see existing reports)
3. ✅ Link from `docs/testing/README.md` (if we create one)
4. ✅ Update `docs/releases/FRAMEWORK_V{X.Y.Z}_SUMMARY.md` (mention test results)

**Naming Convention**: `{DESCRIPTIVE_NAME}_TEST_REPORT_v{VERSION}.md`

---

#### Research Documents (New Research)

**Scenario**: Research new capability, document findings

**Actions Required**:
1. ✅ Create document: `docs/research/RESEARCH_{TOPIC}.md`
2. ✅ Follow research document format (problem, analysis, recommendations)
3. ✅ Link from `docs/research/README.md` (if we create one)
4. ✅ Reference in relevant guide if results in implementation

**Naming Convention**: `RESEARCH_{TOPIC}.md` (all caps, underscores)

---

#### Session Notes (Development Sessions)

**Scenario**: Complete development session, create summary

**Actions Required**:
1. ✅ Create summary: `docs/sessions/SESSION_{NNN}_{TOPIC}.md`
2. ✅ Include: what was done, decisions made, next steps
3. ✅ Link previous and next sessions for continuity

**Naming Convention**: `SESSION_{NNN}_{BRIEF_TOPIC}.md` where NNN is session number

---

#### Release Notes (New Versions)

**Scenario**: Release new version

**Actions Required**:
1. ✅ Create summary: `docs/releases/FRAMEWORK_V{X.Y.Z}_SUMMARY.md`
2. ✅ Include: version number, changes, breaking changes, migration guide
3. ✅ Update `docs/releases/README.md` (if we create one) with version list
4. ✅ Git tag: `git tag v{X.Y.Z}`
5. ✅ Update root `README.md` with new version number

**Self-Consistency Check**:
- [ ] Release summary created
- [ ] Version number updated in README.md
- [ ] Version number updated in compliance_enforcement.json
- [ ] Git tag created
- [ ] CHANGELOG updated (if we add one)

---

## Self-Consistency Requirements

### When Files Are Moved

**Required Updates**:
1. ✅ Update all markdown links pointing to moved files
2. ✅ Update all script paths in hooks
3. ✅ Update all documentation references
4. ✅ Update installation scripts (if they reference moved files)
5. ✅ Test all hooks still work
6. ✅ Test installation flow still works
7. ✅ Verify no broken links

**Validation Script**: Create `scripts/validate_links.sh` to check for broken references

---

### When New Rules Are Added

**Required Updates**:
1. ✅ Core rules document (`docs/core/PROTOCOL_CORE_RULES.md`)
2. ✅ Detailed rule doc (`docs/rules/RULE_{N}_{NAME}.md`)
3. ✅ Enforcement mechanism (script + hook registration)
4. ✅ Hook configuration (`.claude/hooks/compliance_enforcement.json`)
5. ✅ Release notes (`docs/releases/FRAMEWORK_V{X.Y.Z}_SUMMARY.md`)
6. ✅ README.md (rule count update)
7. ✅ Tests for new rule

**Validation**: Run all existing tests, ensure no regressions

---

### When Scripts Are Added/Moved

**Required Updates**:
1. ✅ Hook configuration (`.claude/hooks/compliance_enforcement.json` or `scripts/pre-commit-master.sh`)
2. ✅ Documentation (`docs/core/ENFORCEMENT_MECHANISMS.md`)
3. ✅ Installation script (`cpf-install.sh` if creates symlinks)
4. ✅ Tests for script

**Validation**: Test hooks execute correctly, test installation creates correct symlinks

---

## Enforcement of This Policy

### How to Ensure Compliance

1. **Documentation Detector** - New validator script:
   ```bash
   # scripts/validate_file_organization.sh
   # Checks that files are in correct locations per this policy
   ```

2. **Pre-Commit Hook** - Add to `scripts/pre-commit-master.sh`:
   ```bash
   # Validator 6: File Organization
   # Ensures files being committed are in correct locations
   ```

3. **New File Template** - When generating new files, reference this policy:
   ```markdown
   # Location: As per FILE_ORGANIZATION_POLICY.md section X.Y
   ```

4. **Code Review Checklist** - For PRs:
   - [ ] New files follow organization policy?
   - [ ] Self-consistency updates made?
   - [ ] Documentation updated?

---

## Migration Plan for Existing Files

### Phase 1: Create Directory Structure
```bash
mkdir -p docs/{core,guides,rules,research,testing,releases,analysis,sessions,archive}
mkdir -p templates
mkdir -p tests
```

### Phase 2: Move Documentation Files
```bash
# Core protocol files
git mv CLAUDE_AUTONOMOUS_PROTOCOL.md docs/core/
git mv PROTOCOL_CORE_RULES.md docs/core/
git mv COMPLETION_INSTRUCTIONS.md docs/core/
git mv AUTONOMOUS_MODE.md templates/AUTONOMOUS_MODE_template.md
git mv ENFORCEMENT_MECHANISMS.md docs/core/
git mv RULE_PRIORITIES_AND_CONFLICTS.md docs/core/

# Existing guides (if in root)
# Note: guides/ already exists, may need to move to docs/guides/
git mv guides docs/ # If guides/ not already inside docs/

# Research documents
git mv RESEARCH_*.md docs/research/
git mv *_ANALYSIS.md docs/analysis/
git mv CRITICAL_GAPS_ANALYSIS.md docs/research/
git mv FALSE_CLAIM_ANALYSIS.md docs/research/
git mv ENHANCEMENT_OPPORTUNITIES_2025.md docs/research/

# Test reports
git mv *TEST*.md docs/testing/
git mv PHASE*.md docs/testing/
git mv FINAL_VERIFICATION_REPORT.md docs/testing/

# Release notes
git mv FRAMEWORK_V*.md docs/releases/
git mv V4_*.md docs/releases/
git mv PARADIGM_SHIFT_v4.0.md docs/releases/
git mv FRAMEWORK_STATUS.md docs/releases/

# Framework analysis
git mv COMPREHENSIVE_EVALUATION_*.md docs/analysis/
git mv FRAMEWORK_ANALYSIS_*.md docs/analysis/
git mv RULE_ENFORCEMENT_AUDIT_*.md docs/analysis/
git mv *_INTEGRATION_ANALYSIS.md docs/analysis/
git mv *_FIX_SUMMARY.md docs/analysis/

# Session notes
git mv SESSION_*.md docs/sessions/
git mv NEXT_SESSION_QUICKSTART.md docs/sessions/
git mv GIT_AUTOMATION_REQUIREMENTS.md docs/sessions/

# Legacy
git mv LEGACY_*.md docs/archive/
```

### Phase 3: Create Documentation Indices
```bash
# Create docs/README.md (main index)
# Create docs/rules/README.md (rule list)
# Create docs/research/README.md (research list)
# Create docs/releases/README.md (version history)
```

### Phase 4: Update All References
```bash
# Script to find and update links
scripts/update_links.sh

# Manual verification of critical links
# Test hooks still work
# Test installation still works
```

### Phase 5: Commit Migration
```bash
git add -A
git commit -m "REORGANIZE: Implement file organization policy (cleans root, organizes docs, prepares for installation)"
```

---

## Future Evolution

### This Policy Is Living

As framework evolves:
- ✅ New file types → Add to this policy
- ✅ Better organization discovered → Update policy
- ✅ Conflicts found → Revise policy

**Policy Version History**:
- v1.0.0 (2025-11-13): Initial policy based on user research feedback

**How to Update This Policy**:
1. Propose changes in docs/research/
2. Discuss and validate
3. Update this file
4. Increment version number
5. Communicate changes to users
6. Update enforcement scripts

---

## Summary

### File Locations Quick Reference

| File Type | Location | Example |
|-----------|----------|---------|
| Claude Code activation | Project root | `CLAUDE.md`, `.claude/` |
| Framework docs | `cpf/docs/{category}/` | `docs/core/PROTOCOL_CORE_RULES.md` |
| Framework scripts | `cpf/scripts/` | `scripts/validate_semver.sh` |
| Project config | `.cpf/` | `.cpf/config.json` |
| Project state | `.cpf/state/` | `.cpf/state/master_state.json` |
| Progress tracking | `.cpf/progress/` | `.cpf/progress/todos.json` ⭐ |
| Logs | `.cpf/logs/` | `.cpf/logs/operations.log` ⭐ |
| Issues | `.cpf/issues/` | `.cpf/issues/violations.log` ⭐ |
| Templates | `cpf/templates/` | `templates/config_template.json` |
| Tests | `cpf/tests/` | `tests/unit/test_validator.sh` |

### Root Directory Files (Framework Repo)

**Only these 6 files at root**:
1. `CLAUDE.md` - Framework development instructions
2. `README.md` - Framework overview
3. `LICENSE` - Legal
4. `cpf-install.sh` - Installation
5. `cpf-update.sh` - Update
6. `cpf-uninstall.sh` - Uninstall

Everything else organized in subdirectories.

### Root Directory Files (User Project)

**Only these at root**:
1. `CLAUDE.md` - User's project instructions (references framework)
2. `.claude/` - Claude Code configuration (copied from framework)
3. `cpf/` - Framework directory (contains everything else)
4. `.cpf/` - Hidden config/state (framework data)
5. User's own files (README.md, src/, etc.)

---

**END OF POLICY**

**Version**: 1.0.0
**Last Updated**: 2025-11-13
**Status**: Active Policy - Enforced by Framework
