# Research: Installable Framework Architecture

**Date**: 2025-11-13
**Purpose**: Deep research on making framework installable across multiple projects with automated rule enforcement and bidirectional updates
**Status**: Research Phase - Evaluation of feasibility and safety

---

## Problem Statement

### The Version Number Incident (Case Study)

**What Happened**: During Session 005, Claude violated semantic versioning:
- Previous version: `v4.1.1`
- Claude's version: `v4.0.0` ❌ (went BACKWARDS)
- Correct version: `v4.2.0`

**Rules Violated**:
1. **RULE 19** (Auto-Documentation): README not updated initially
2. **RULE 20** (Verifiable Claims): False claim about version number
3. **Semantic Versioning**: Basic software engineering principle violated

**Why Existing Enforcement Failed**:
- ✅ Hooks exist for RULE 19 (warns after doc changes)
- ✅ Instructions exist for RULE 20
- ❌ **NO pre-commit validation** for semantic versioning
- ❌ **NO automated detection** of version number errors
- ❌ **NO blocking mechanism** to prevent the commit

**Outcome**: Error caught by user, manually corrected, but demonstrates rules aren't rigorous enough.

### Core Problem

Current framework has:
- ✅ 20 rules defined
- ✅ 14 rules technically enforced (70%)
- ✅ 17 hooks active
- ❌ **Still allows rule violations** (version number incident proves this)
- ❌ **No automated detection** for all violation types
- ❌ **No prevention** before violations occur

### User Requirements

The user wants:
1. **Address persistent rule-breaking issues**
2. **Rigorous enforcement always without exception**
3. **Automated detectors for rule breaking**
4. **Bidirectional update system**: When ANY instance finds/fixes issues, propagate to base framework and all other users
5. **Installation instructions**: Framework should be installable in multiple code directories

---

## Research Questions

### Question 1: Is this possible? (Feasibility)

**Answer**: **YES** - Technically feasible with well-established patterns

### Question 2: Is this a good idea that can be done safely? (Safety)

**Answer**: **YES, with proper safeguards** - Requires careful architecture

---

## Architecture Research

### Model 1: Git Submodules (Most Common)

**How It Works**:
```bash
# User installs framework in their project
cd ~/my-project
git submodule add https://github.com/user/ContextPreservingFramework.git .framework
cd .framework
./install.sh ../  # Sets up hooks in parent project

# User updates framework
cd ~/my-project/.framework
git submodule update --remote
./update.sh ../  # Updates hooks in parent project
```

**Pros**:
- ✅ Standard Git feature
- ✅ Version control built-in
- ✅ Users can pin to specific version
- ✅ Updates are explicit (user pulls)
- ✅ No security risks (user controls updates)

**Cons**:
- ❌ Complex for non-Git users
- ❌ Manual update process
- ❌ Can get out of sync

**Examples**:
- Oh My Zsh (dotfiles framework)
- Prezto (zsh configuration framework)
- Spacemacs (Emacs configuration framework)

**Verdict**: ✅ **RECOMMENDED** - Best balance of control and functionality

---

### Model 2: Git Subtree (Alternative)

**How It Works**:
```bash
# User installs framework
cd ~/my-project
git subtree add --prefix .framework https://github.com/user/ContextPreservingFramework.git main --squash

# User updates framework
git subtree pull --prefix .framework https://github.com/user/ContextPreservingFramework.git main --squash
```

**Pros**:
- ✅ No separate submodule tracking
- ✅ Framework code is part of project
- ✅ Simpler than submodules

**Cons**:
- ❌ More complex to push changes back
- ❌ History can get messy
- ❌ Less clear separation

**Verdict**: ⚠️ **POSSIBLE** - Alternative if submodules too complex

---

### Model 3: Package Manager (Language-Specific)

**How It Works**:
```bash
# Python project
pip install context-preserving-framework

# Node.js project
npm install context-preserving-framework

# Ruby project
gem install context-preserving-framework
```

**Pros**:
- ✅ Familiar to developers
- ✅ Automatic dependency resolution
- ✅ Version management built-in
- ✅ Easy updates

**Cons**:
- ❌ Language-specific (not universal)
- ❌ Requires packaging for each ecosystem
- ❌ Framework is language-agnostic (uses bash, not language-specific)
- ❌ More infrastructure required

**Verdict**: ❌ **NOT RECOMMENDED** - Framework is language-agnostic

---

### Model 4: Install Script (Simplest)

**How It Works**:
```bash
# User installs framework
cd ~/my-project
curl -sSL https://raw.githubusercontent.com/user/ContextPreservingFramework/main/install.sh | bash

# OR clone first
git clone https://github.com/user/ContextPreservingFramework.git .framework
cd .framework && ./install.sh ../
```

**Pros**:
- ✅ Very simple for users
- ✅ No Git knowledge required
- ✅ Can auto-update

**Cons**:
- ❌ Security risk (running remote script)
- ❌ No version control
- ❌ Hard to track what version installed

**Verdict**: ⚠️ **SUPPLEMENTARY** - Good for getting started, but should use Git for updates

---

## Recommended Architecture: Hybrid Git + Scripts

### Installation System

**Components**:
1. **Base Framework Repository** (this repo)
   - Contains all rules, scripts, hooks, documentation
   - Git repository on GitHub
   - Releases with semantic versioning

2. **Installation Script** (`install.sh`)
   - Copies necessary files to user project
   - Sets up Git hooks in user's `.git/hooks/`
   - Creates `.claude/` directory structure
   - Initializes state files

3. **Update Script** (`update.sh`)
   - Pulls latest changes from base repo
   - Updates hooks in user project
   - Migrates state files if schema changed
   - Validates compatibility

4. **Uninstall Script** (`uninstall.sh`)
   - Removes hooks cleanly
   - Optionally removes state files
   - Reverts to clean state

### Directory Structure

**User Project After Installation**:
```
my-project/
├── .framework/                    # Git submodule or clone
│   ├── .git/                      # Framework's own git
│   ├── scripts/                   # All enforcement scripts
│   ├── .claude/                   # Framework metadata
│   ├── install.sh                 # Installation script
│   ├── update.sh                  # Update script
│   ├── uninstall.sh              # Uninstall script
│   └── README.md                  # Installation instructions
├── .git/
│   └── hooks/                     # User project's hooks
│       ├── pre-commit             # Symlink to .framework/scripts/pre-commit-master.sh
│       ├── post-commit            # Symlink to .framework/scripts/post-commit-master.sh
│       └── pre-push               # Symlink to .framework/scripts/pre-push-master.sh
├── .claude/
│   └── hooks/
│       └── compliance_enforcement.json  # Copied from .framework
├── data/
│   └── state/                     # User project's state (NOT in .framework)
│       ├── master_state.json
│       └── context_tracking.json
└── ... (user's project files)
```

**Key Principles**:
- `.framework/` contains the **framework code** (read-only, from Git)
- `.git/hooks/` contains **symlinks** to framework scripts
- `data/state/` contains **user project state** (not part of framework)
- Framework updates don't touch user state

---

## Automated Rule Violation Detection

### Current Gaps

**Violations NOT Currently Detected**:
1. ❌ Semantic versioning violations (version number going backwards)
2. ❌ Documentation out of sync with code (RULE 19 warns but doesn't block)
3. ❌ State files out of date (RULE 14 checks but timing issues)
4. ❌ Missing Co-Authored-By line in commits (RULE 16 warns after commit, too late)
5. ❌ Context threshold violations before they happen (RULE 10 checks but reactive)

### Proposed: Enhanced Pre-Commit Validation

**New Script**: `pre-commit-master.sh` (runs BEFORE commit is created)

**Validations** (blocking, must pass):
1. **Semantic Versioning Validator**
   - Reads last version from git tags or README
   - Validates new version in staged files
   - Blocks if version goes backwards
   - Blocks if version skips numbers (v1.0.0 → v3.0.0)

2. **Documentation Sync Validator**
   - Detects code changes in staged files
   - Checks if README.md also staged
   - Blocks if code changed but docs not updated
   - Exception: Changes to tests only

3. **State File Freshness Validator**
   - Checks timestamps of state files
   - Blocks if state files not updated in last 5 minutes
   - Ensures state reflects current operation

4. **Placeholder Detector** (already exists but strengthen)
   - Scans staged files for TODO/FIXME/PLACEHOLDER
   - Blocks commit if found
   - No exceptions

5. **Hardcoding Detector**
   - Scans staged code files for hardcoded values
   - Warns about URLs, passwords, API keys
   - **Blocks** if high-severity patterns found (passwords, secrets)

6. **Commit Message Validator**
   - Validates format before commit created
   - Ensures Co-Authored-By line present
   - Ensures descriptive message (not just "fix" or "update")
   - Blocks if invalid

### Example: Semantic Version Validator

```bash
#!/bin/bash
# pre-commit-semver-validator.sh

# Get last version from git tags
LAST_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Extract versions from staged files
NEW_VERSION=$(git diff --cached README.md | grep "^+\*\*Version\*\*" | sed 's/.*v\([0-9.]*\).*/\1/')

if [ -n "$NEW_VERSION" ]; then
    # Parse versions
    LAST_MAJOR=$(echo "$LAST_VERSION" | cut -d. -f1 | tr -d 'v')
    LAST_MINOR=$(echo "$LAST_VERSION" | cut -d. -f2)
    LAST_PATCH=$(echo "$LAST_VERSION" | cut -d. -f3)

    NEW_MAJOR=$(echo "$NEW_VERSION" | cut -d. -f1)
    NEW_MINOR=$(echo "$NEW_VERSION" | cut -d. -f2)
    NEW_PATCH=$(echo "$NEW_VERSION" | cut -d. -f3)

    # Validate: new version must be >= last version
    if [ "$NEW_MAJOR" -lt "$LAST_MAJOR" ]; then
        echo "❌ BLOCKED: Semantic versioning violation"
        echo "Last version: $LAST_VERSION"
        echo "New version: v$NEW_VERSION"
        echo "ERROR: Major version cannot go backwards"
        exit 1
    fi

    if [ "$NEW_MAJOR" -eq "$LAST_MAJOR" ] && [ "$NEW_MINOR" -lt "$LAST_MINOR" ]; then
        echo "❌ BLOCKED: Semantic versioning violation"
        echo "Last version: $LAST_VERSION"
        echo "New version: v$NEW_VERSION"
        echo "ERROR: Minor version cannot go backwards"
        exit 1
    fi

    if [ "$NEW_MAJOR" -eq "$LAST_MAJOR" ] && [ "$NEW_MINOR" -eq "$LAST_MINOR" ] && [ "$NEW_PATCH" -le "$LAST_PATCH" ]; then
        echo "❌ BLOCKED: Semantic versioning violation"
        echo "Last version: $LAST_VERSION"
        echo "New version: v$NEW_VERSION"
        echo "ERROR: Patch version must increase"
        exit 1
    fi

    echo "✅ Version validation passed: $LAST_VERSION → v$NEW_VERSION"
fi

exit 0
```

**This Would Have Prevented the v4.0.0 Error!**

---

## Bidirectional Update System

### The Challenge

User wants: When ANY user project detects and fixes a rule violation, that fix should:
1. Update the **base framework repository**
2. Propagate to **all other user installations**

This is a **distributed learning system** - the framework gets smarter as more people use it.

### Architecture Options

#### Option A: Manual Contribution (Safest)

**Flow**:
1. User project detects violation (e.g., semver error)
2. Framework logs violation locally
3. Framework suggests: "This violation could help improve the framework. Create PR?"
4. If user agrees, framework helps create PR to base repo
5. Maintainer reviews and merges PR
6. Other users update via `update.sh`

**Pros**:
- ✅ Safe (manual review)
- ✅ Maintains quality
- ✅ Standard open-source workflow

**Cons**:
- ❌ Slow (requires manual PR)
- ❌ Not automatic

**Verdict**: ✅ **RECOMMENDED** - Safest approach

---

#### Option B: Automated PR Creation

**Flow**:
1. User project detects violation
2. Framework automatically creates PR to base repo
3. PR includes: violation details, suggested fix, test case
4. Maintainer reviews (automated tests run)
5. If approved, merged and released
6. Users notified of update

**Implementation**:
```bash
# scripts/contribute-fix.sh
#!/bin/bash
# Creates automated PR when violation detected

VIOLATION_TYPE="$1"
VIOLATION_DETAILS="$2"
FIX_CODE="$3"

# Create feature branch
git checkout -b "fix/${VIOLATION_TYPE}-$(date +%s)"

# Apply fix
echo "$FIX_CODE" > "scripts/fix_${VIOLATION_TYPE}.sh"

# Commit
git add .
git commit -m "AUTO-FIX: ${VIOLATION_TYPE} violation detected

Violation Details:
${VIOLATION_DETAILS}

This fix was automatically generated when the violation was detected.

Generated by: User Project Instance
Date: $(date)
"

# Push and create PR via GitHub CLI
gh pr create --title "AUTO-FIX: ${VIOLATION_TYPE}" --body "..."
```

**Pros**:
- ✅ Fast feedback loop
- ✅ Automatic contribution
- ✅ Scales well

**Cons**:
- ❌ Requires GitHub token
- ❌ Could spam with PRs
- ❌ Quality control harder

**Verdict**: ⚠️ **POSSIBLE** - With rate limiting and quality checks

---

#### Option C: Telemetry + Central Intelligence (Advanced)

**Flow**:
1. User project detects violation (opt-in telemetry)
2. Framework sends anonymous violation report to central server
3. Central server aggregates violations from all users
4. ML model learns patterns
5. Central server generates improved rules
6. Users pull updated rules

**Pros**:
- ✅ Learning from all users
- ✅ Can detect patterns
- ✅ Centralized intelligence

**Cons**:
- ❌ Privacy concerns
- ❌ Requires infrastructure (server, ML)
- ❌ Central point of failure
- ❌ Opt-in required (GDPR compliance)

**Verdict**: ❌ **NOT RECOMMENDED** - Too complex, privacy issues

---

### Recommended: Hybrid Manual + Optional Automation

**Phase 1 (MVP)**: Manual Contributions
- Violation logger records issues locally
- Framework provides PR template
- User manually creates PR if desired
- Standard review process

**Phase 2 (Future)**: Assisted Automation
- Framework can auto-create PR (with user permission)
- Rate limiting (max 1 PR per day)
- Quality checks before PR creation
- Still requires maintainer review

**Phase 3 (Long-term)**: Smart Updates
- Framework tracks common violations
- Suggests improvements based on patterns
- Users can subscribe to automatic updates (opt-in)
- Version pinning for stability

---

## Safety and Security Analysis

### Security Risks

#### Risk 1: Malicious Code in Framework Updates

**Scenario**: Base repo compromised, malicious code pushed
**Impact**: All user projects could execute malicious scripts
**Severity**: CRITICAL

**Mitigations**:
1. ✅ **Signed Commits**: Require GPG-signed commits
2. ✅ **Protected Branches**: main branch requires review
3. ✅ **Version Pinning**: Users can pin to specific version
4. ✅ **Code Review**: All PRs require review
5. ✅ **Audit Trail**: Git history shows all changes
6. ✅ **Checksum Validation**: Verify integrity of downloaded files

**Verdict**: ✅ **MITIGATED** - Standard open-source security practices

---

#### Risk 2: Accidental Breaking Changes

**Scenario**: Framework update breaks user projects
**Impact**: Projects stop working after update
**Severity**: HIGH

**Mitigations**:
1. ✅ **Semantic Versioning**: Breaking changes = major version bump
2. ✅ **Changelog**: Document all changes
3. ✅ **Backwards Compatibility**: Maintain for at least 1 major version
4. ✅ **Migration Scripts**: Auto-migrate old projects
5. ✅ **Rollback Capability**: Easy to revert to previous version
6. ✅ **Testing**: Framework has its own test suite

**Verdict**: ✅ **MITIGATED** - Standard software practices

---

#### Risk 3: Privacy Leaks

**Scenario**: Framework sends user data to central server
**Impact**: Private code or data exposed
**Severity**: HIGH

**Mitigations**:
1. ✅ **No Telemetry by Default**: Opt-in only
2. ✅ **Anonymous Data**: If telemetry enabled, no PII
3. ✅ **Local-First**: All processing local by default
4. ✅ **Transparent**: Show exactly what would be sent
5. ✅ **User Control**: Can disable all network activity

**Verdict**: ✅ **MITIGATED** - Privacy by design

---

#### Risk 4: Dependency Vulnerabilities

**Scenario**: Framework depends on vulnerable tool (jq, bash, etc.)
**Impact**: Users exposed to CVEs
**Severity**: MEDIUM

**Mitigations**:
1. ✅ **Minimal Dependencies**: Use only standard tools
2. ✅ **Version Checks**: Warn if tool version has known CVE
3. ✅ **Fallbacks**: Provide alternatives for critical tools
4. ✅ **Documentation**: List all dependencies clearly

**Verdict**: ✅ **MITIGATED** - Minimal dependencies

---

### Is This Safe Overall?

**Answer**: **YES, with proper implementation**

The proposed architecture is:
- ✅ Based on proven patterns (Git submodules, install scripts)
- ✅ Uses standard security practices (signed commits, code review)
- ✅ Privacy-respecting (local-first, opt-in telemetry)
- ✅ Provides user control (version pinning, rollback)
- ✅ Transparent (open source, auditable)

**Comparable Systems**:
- Oh My Zsh: 160k+ stars, millions of users, similar architecture
- Homebrew: 38k+ stars, widely trusted, install script model
- Rustup: Official Rust toolchain, similar update mechanism

**Verdict**: ✅ **SAFE** if implemented with standard best practices

---

## Implementation Roadmap

### Phase 1: Installation System (Week 1)

**Goals**:
- Create install.sh, update.sh, uninstall.sh
- Update README.md with installation instructions
- Test installation in fresh project

**Deliverables**:
- `install.sh` (handles setup)
- `update.sh` (handles updates)
- `uninstall.sh` (clean removal)
- Updated README.md with instructions

---

### Phase 2: Enhanced Validation (Week 2)

**Goals**:
- Implement pre-commit-master.sh with ALL validators
- Add semantic version validator
- Add documentation sync validator
- Test blocking mechanisms

**Deliverables**:
- `pre-commit-master.sh` (comprehensive validation)
- `validate-semver.sh` (semantic version checking)
- `validate-docs-sync.sh` (documentation sync checking)
- Test suite for validators

---

### Phase 3: Violation Detection & Logging (Week 3)

**Goals**:
- Create violation logger
- Log all detected violations
- Generate reports
- Create PR templates for contributions

**Deliverables**:
- `log-violation.sh` (records violations)
- `violation-report.md` (template)
- PR template for contributing fixes

---

### Phase 4: Contribution System (Week 4)

**Goals**:
- Create automated PR generation (optional)
- Add rate limiting
- Add quality checks
- Test contribution flow

**Deliverables**:
- `contribute-fix.sh` (creates PRs)
- Contribution guide
- CI/CD for auto-PR validation

---

## Recommendations

### Short-Term (Immediate)

1. **Update README.md** with installation instructions
2. **Implement semantic version validator** (prevents version number errors)
3. **Create install.sh** (basic installation)
4. **Test in fresh project** (validate installation works)

### Medium-Term (Next Sprint)

1. **Implement all enhanced validators**
2. **Create update.sh** (framework updates)
3. **Add violation logger**
4. **Write contribution guide**

### Long-Term (Future)

1. **Automated PR creation** (optional)
2. **Telemetry system** (opt-in)
3. **Migration to package managers** (if demand exists)
4. **Web dashboard** (show framework stats)

---

## Conclusion

### Feasibility: ✅ YES

The proposed architecture is:
- Technically feasible with proven patterns
- Based on Git submodules + install scripts
- Similar to many successful open-source frameworks
- No major technical blockers

### Safety: ✅ YES (with safeguards)

The system can be safe if:
- Using standard security practices
- Maintaining user control over updates
- Privacy-respecting (local-first)
- Transparent and auditable

### Recommendation: ✅ PROCEED

**Next Steps**:
1. Create installation system (install.sh, update.sh)
2. Implement enhanced validation (semantic version validator)
3. Update README.md with installation guide
4. Test in isolated environment
5. Gradually roll out contribution system

**This will address all user concerns**:
- ✅ Rigorous enforcement (enhanced validators)
- ✅ Automated detection (pre-commit hooks)
- ✅ Bidirectional updates (contribution system)
- ✅ Multi-project support (installation system)
- ✅ Safe and secure (standard practices)

---

**Research Status**: COMPLETE
**Recommendation**: PROCEED with Phase 1 implementation
**Next Action**: Implement installation system

**END OF RESEARCH**
