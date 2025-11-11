# Troubleshooting Guide

**When things go wrong with the Context-Preserving Framework**

**Token cost**: ~10K tokens (5% context)
**Usage**: Look up your specific issue

---

## Table of Contents

1. [Issue 1: Context Still Exhausting Despite Framework](#issue-1-context-still-exhausting-despite-framework)
2. [Issue 2: CLAUDE.md Rules Not Followed](#issue-2-claudemd-rules-not-followed)
3. [Issue 3: Recovery Prompts Not Working](#issue-3-recovery-prompts-not-working)
4. [Issue 4: Autonomous Mode Not Working](#issue-4-autonomous-mode-not-working)
5. [Issue 5: State Files Out of Sync](#issue-5-state-files-out-of-sync)
6. [Issue 6: Git Commits Missing](#issue-6-git-commits-missing)
7. [Issue 7: Sessions Too Short](#issue-7-sessions-too-short)
8. [Issue 8: Template Setup Failed](#issue-8-template-setup-failed)

---

## Issue 1: Context Still Exhausting Despite Framework

### Symptoms

- Reaching 50-60% context despite 35% target
- Frequent context warnings
- Sessions lasting < 1 hour
- Running out of context mid-module

### Diagnosis

**Step 1**: Check what's consuming context

```bash
# List files currently in context (estimate)
ls -lh CLAUDE.md ARCHITECTURE.md data/state/*.json

# Check file sizes
du -sh *
```

**Step 2**: Identify the problem

Common causes:
1. **Large files in project** (> 50KB each)
2. **Reading too many files at once**
3. **Architecture doc too detailed** (> 20KB)
4. **Not using external memory** for reference material
5. **Loading entire codebase** instead of modules

### Solution

**Solution 1**: Break up large files

```bash
# If ARCHITECTURE.md > 20KB, split it
mkdir docs/architecture
mv ARCHITECTURE.md docs/architecture/overview.md

# Create lightweight ARCHITECTURE.md
cat > ARCHITECTURE.md << 'EOF'
# Architecture - See docs/architecture/ for details

Quick reference:
- Module structure: docs/architecture/modules.md
- Data models: docs/architecture/data.md
- API design: docs/architecture/api.md

For detailed architecture, read specific docs as needed.
EOF
```

**Solution 2**: Use external memory

```bash
# Move reference material out of main context
mkdir memory/
mv docs/detailed_specs.md memory/
mv docs/api_reference.md memory/

# Reference via search instead of loading
grep "authentication" memory/*.md
```

**Solution 3**: Implement micro-modules

```
Instead of:
- Module 1: All features (1000 lines, 25K tokens)

Do this:
- Module 1.1: Feature A (250 lines, 6K tokens)
- Module 1.2: Feature B (250 lines, 6K tokens)
- Module 1.3: Feature C (250 lines, 6K tokens)
- Module 1.4: Feature D (250 lines, 6K tokens)
```

**Solution 4**: Check context estimation

```bash
# Use context estimation script
python scripts/estimate_context.py

# If not installed, see 05_ENHANCEMENTS/context_estimation.md
```

### Prevention

1. Keep ARCHITECTURE.md < 20KB
2. Keep CLAUDE.md < 10KB
3. Use external memory for reference docs
4. Limit modules to 250 lines each
5. Track context after each operation

---

## Issue 2: CLAUDE.md Rules Not Followed

### Symptoms

- Claude not checking context regularly
- Missing state tracking checkpoint boxes
- No "Next Steps" section at end
- Git commits not happening
- Rules in CLAUDE.md being ignored

### Diagnosis

**Step 1**: Verify CLAUDE.md exists and is read

```bash
# Check file exists
ls -l CLAUDE.md

# Check it's in project root (not subdirectory)
pwd
ls CLAUDE.md

# Verify content
head -20 CLAUDE.md
```

**Step 2**: Check rule format

Rules must be:
- Clear and explicit
- Written as instructions, not suggestions
- Use "MUST" not "should"
- Include specific actions

### Solution

**Solution 1**: Fix CLAUDE.md format

**Bad** (not followed):
```markdown
You should try to check context occasionally.
```

**Good** (will be followed):
```markdown
## Context Tracking (MANDATORY)

After EVERY tool operation, I MUST:
1. Log operation to logs/operation_log.txt
2. Update data/state/master_state.json
3. Check context percentage
4. If ≥ 30%: Warn user
5. If ≥ 35%: Exit session immediately
```

**Solution 2**: Add explicit checkpoint template

Add this to CLAUDE.md:
```markdown
## Response Template (MANDATORY)

BEFORE completing ANY response, I MUST display:

```
═══════════════════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC)
═══════════════════════════════════════════════════════════════════════

✅ Operation logged: [type] → logs/operation_log.txt
✅ State updated: [file] (timestamp: HH:MM:SS)
✅ Context: [N]K tokens ([X.X]%)
✅ Status: [SAFE/WARNING/CRITICAL]

═══════════════════════════════════════════════════════════════════════
```

THIS CHECKPOINT IS MANDATORY - I CANNOT SKIP IT.
```

**Solution 3**: Reference rules template

Copy from framework:
```bash
cp ~/ContextPreservingFramework/03_TEMPLATES/rules_CLAUDE.md.template ./rules_CLAUDE.md

# Review rules and add project-specific ones
vi rules_CLAUDE.md
```

### Prevention

1. Use template rules from framework
2. Make rules explicit and mandatory
3. Include examples in rules
4. Reference rules_CLAUDE.md from CLAUDE.md
5. Test rules with Claude before starting work

---

## Issue 3: Recovery Prompts Not Working

### Symptoms

- Starting new session, context is lost
- Claude doesn't remember what was done
- Has to re-read all files
- Work duplicated
- No continuity between sessions

### Diagnosis

**Step 1**: Check if recovery prompt exists

```bash
# Check for recovery prompts
ls -l docs/recovery_prompts/
ls -l data/recovery/

# Check most recent
ls -lt docs/recovery_prompts/ | head -5
```

**Step 2**: Check prompt quality

A good recovery prompt includes:
- Exact git commit hash
- List of completed work
- Current task in progress
- Next steps (specific and actionable)
- Files to read for context

**Bad recovery prompt**:
```
Continue working on the project.
```

**Good recovery prompt**:
```
Resume project_name - Session 2

Git commit: abc123
Completed: Modules 1.1, 1.2 (tests passing)
In progress: Module 1.3 (half done)

Next steps:
1. Read data/state/master_state.json
2. Read src/module1_3.py (current implementation)
3. Complete remaining functions: process_data(), validate_input()
4. Write tests in tests/test_module1_3.py
5. Run: pytest tests/test_module1_3.py
```

### Solution

**Solution 1**: Create better recovery prompts

Use the template:
```bash
cp ~/ContextPreservingFramework/03_TEMPLATES/recovery_prompt.template docs/recovery_prompts/session_2.md

# Fill in with specific information
vi docs/recovery_prompts/session_2.md
```

**Solution 2**: Include context files in prompt

```markdown
## Recovery Prompt - Session 2

**Context to Read**:
1. data/state/master_state.json - Current state
2. src/module1.py - Recently completed
3. tests/test_module1.py - Passing tests
4. src/module2.py (first 50 lines) - Current work

**Exact Instructions**:
1. Read above 4 files
2. Verify tests passing: `pytest tests/test_module1.py`
3. Continue Module 2: Implement process() function (lines 51-75)
4. Write tests for process()
5. Run tests
6. Commit if passing
```

**Solution 3**: Auto-generate recovery prompts

Create script:
```bash
#!/bin/bash
# scripts/create_recovery_prompt.sh

SESSION_NUM=$1
GIT_HASH=$(git rev-parse HEAD)
COMPLETED=$(grep "modules_complete" data/state/master_state.json)
IN_PROGRESS=$(grep "current_module" data/state/master_state.json)

cat > docs/recovery_prompts/session_${SESSION_NUM}.md << EOF
# Recovery Prompt - Session ${SESSION_NUM}

**Git commit**: ${GIT_HASH}
**Completed**: ${COMPLETED}
**In progress**: ${IN_PROGRESS}

[Rest of template...]
EOF
```

### Prevention

1. Create recovery prompt at end of EVERY session
2. Test prompt immediately (paste it back to Claude)
3. Include specific file paths and line numbers
4. Reference git commits
5. Make instructions actionable (not general)

---

## Issue 4: Autonomous Mode Not Working

### Symptoms

- Claude asks permission for everything
- Stops and waits for approval
- Not proceeding automatically
- Doesn't follow AUTONOMOUS_MODE.md

### Diagnosis

**Step 1**: Check AUTONOMOUS_MODE.md exists

```bash
# File must exist in project root
ls -l AUTONOMOUS_MODE.md

# Check STATUS line
grep "STATUS:" AUTONOMOUS_MODE.md
```

Must show:
```
STATUS: ACTIVE
```

**Step 2**: Check permissions are explicit

File must include:
```markdown
## DO NOT ASK FOR PERMISSION TO:

- Create files listed in specifications
- Write code for specified modules
- Install packages in requirements.txt
- Run tests
- Git operations (commit, add)
- [etc.]
```

### Solution

**Solution 1**: Fix STATUS

```bash
# Edit file
vi AUTONOMOUS_MODE.md

# Change this:
STATUS: INACTIVE

# To this:
STATUS: ACTIVE
```

**Solution 2**: Add explicit permissions

```markdown
## Explicit Permissions

I, [Your Name], hereby grant Claude Code FULL AUTONOMOUS PERMISSION to:

1. ✅ Create ALL files specified in ARCHITECTURE.md without asking
2. ✅ Write ALL code for modules 1.1 through 1.9
3. ✅ Install required packages (pip install, npm install)
4. ✅ Run ALL tests and fix failures autonomously
5. ✅ Make ALL decisions within documented design
6. ✅ Git operations: init, add, commit (NOT push without asking)
7. ✅ Proceed through all phases without stopping

## DO NOT ASK FOR PERMISSION TO:

[Be very specific about what doesn't need approval]
```

**Solution 3**: Remind Claude at session start

In your prompt:
```
Start project_name implementation

IMPORTANT: AUTONOMOUS_MODE.md is ACTIVE
Proceed without asking permission for items in whitelist.
See AUTONOMOUS_MODE.md for full permissions.
```

### Prevention

1. Use template: `03_TEMPLATES/AUTONOMOUS_MODE.md.template`
2. Set STATUS: ACTIVE explicitly
3. List ALL permitted actions
4. Reference at session start
5. Update scope as project evolves

---

## Issue 5: State Files Out of Sync

### Symptoms

- master_state.json shows different status than reality
- Tests count doesn't match actual passing tests
- Modules marked complete but files don't exist
- Context percentage wrong
- Timestamps are old

### Diagnosis

**Step 1**: Check state vs. reality

```bash
# What state says
cat data/state/master_state.json | grep modules_complete

# What actually exists
ls src/

# What tests say
pytest --collect-only | grep test_

# Compare
```

**Step 2**: Find last valid state

```bash
# Check git history
git log --all --full-history -- data/state/master_state.json

# View old version
git show abc123:data/state/master_state.json
```

### Solution

**Solution 1**: Manual sync

```bash
# Count actual tests
PASSING=$(pytest --tb=no -q | grep "passed" | cut -d' ' -f1)
TOTAL=$(pytest --collect-only -q | wc -l)

# Update state
python << EOF
import json

with open('data/state/master_state.json', 'r+') as f:
    state = json.load(f)
    state['tests_passing'] = $PASSING
    state['tests_total'] = $TOTAL
    state['last_update'] = '$(date -Iseconds)'
    f.seek(0)
    json.dump(state, f, indent=2)
    f.truncate()
EOF
```

**Solution 2**: Use schema validation

```bash
# Install validator
pip install jsonschema

# Validate state
python scripts/validate_state.py

# Fix errors found
```

**Solution 3**: Reset from known-good state

```bash
# Revert to last good commit
git checkout abc123 -- data/state/master_state.json

# Update manually from there
vi data/state/master_state.json
```

### Prevention

1. Update state after EVERY operation
2. Validate state before commits (use schema validation)
3. Add git hook to validate state
4. Include state updates in CLAUDE.md rules
5. Never manually edit state files (use scripts)

---

## Issue 6: Git Commits Missing

### Symptoms

- Hours of work with no commits
- Can't track progress
- No recovery points
- Lost work when something breaks

### Diagnosis

**Step 1**: Check commit history

```bash
# Recent commits
git log --oneline -10

# Commits today
git log --since="today" --oneline

# Check if any commits
git rev-list --count HEAD
```

**Step 2**: Check why commits aren't happening

Common causes:
1. CLAUDE.md doesn't mandate commits
2. AUTONOMOUS_MODE.md doesn't include git permissions
3. No reminder to commit
4. Commit frequency not specified

### Solution

**Solution 1**: Add commit rules to CLAUDE.md

```markdown
## Git Commit Protocol (MANDATORY)

I MUST commit at these points:
1. After completing any module
2. After tests pass
3. Before context reaches 35%
4. Every 5 significant operations
5. Minimum: Every 30 minutes of active work

Commit format:
```
[Session X] Module Y: Description - STATUS

Changes:
- Files: [list]
- Tests: [passing/total]

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
```
```

**Solution 2**: Add git permissions to AUTONOMOUS_MODE.md

```markdown
## Explicit Permissions

10. ✅ Git operations: git add, git commit (descriptive messages)

## DO NOT ASK FOR PERMISSION TO:

- Stage changes: git add .
- Commit with descriptive messages
- Create git backups after each module
```

**Solution 3**: Create commit checklist

After each module:
```markdown
## Module Completion Checklist

- [ ] Code complete
- [ ] Tests passing
- [ ] Documentation updated
- [ ] **Git commit created**
- [ ] State files updated
- [ ] Recovery prompt created (if ending session)
```

### Prevention

1. Specify commit frequency in CLAUDE.md
2. Grant git permissions explicitly
3. Include commit in module checklist
4. Track commits in session_info
5. Review commit history at end of session

---

## Issue 7: Sessions Too Short

### Symptoms

- Sessions ending after 30-45 minutes
- Only completing 1-2 modules per session
- Reaching context limit too quickly
- Spending more time on recovery than work

### Diagnosis

**Step 1**: Identify what's consuming context

```bash
# Estimate context
python scripts/estimate_context.py

# Check file sizes
find . -type f -name "*.md" -exec wc -c {} + | sort -n
```

**Step 2**: Common causes

1. Architecture doc too large (> 20KB)
2. Loading too many files at once
3. Modules too large (> 300 lines)
4. No external memory for references
5. Detailed documentation in main context

### Solution

**Solution 1**: Implement micro-modules

```
Current: Module 1 (800 lines) = 20K tokens

Better:
- Module 1.1 (200 lines) = 5K tokens
- Module 1.2 (200 lines) = 5K tokens
- Module 1.3 (200 lines) = 5K tokens
- Module 1.4 (200 lines) = 5K tokens

Result: Complete 4-5 micro-modules per session instead of 1 large module
```

**Solution 2**: Use external memory

```bash
# Move detailed docs out of main context
mkdir memory/
mv docs/detailed_api.md memory/
mv docs/specifications.md memory/

# Keep only summary in main context
cat > docs/api_summary.md << 'EOF'
# API Summary

For detailed API: see memory/detailed_api.md

Quick reference:
- Authentication: /auth/* endpoints
- Users: /users/* endpoints
[etc.]
EOF
```

**Solution 3**: Lazy-load documentation

Instead of loading all docs at start:
```markdown
# In CLAUDE.md

## Documentation Access

DO NOT load these at start:
- memory/ (only load specific sections when needed)
- docs/detailed_* (only when implementing that feature)

ONLY load:
- CLAUDE.md
- AUTONOMOUS_MODE.md
- master_state.json
- Current module specification
```

### Prevention

1. Keep all docs < 20KB each
2. Split large modules into micro-modules (< 250 lines)
3. Use external memory for references
4. Lazy-load documentation
5. Track context after each operation

---

## Issue 8: Template Setup Failed

### Symptoms

- Error copying template files
- Files in wrong locations
- Missing required files
- Template variables not replaced

### Diagnosis

**Step 1**: Check what's missing

```bash
# Required files
ls -l CLAUDE.md AUTONOMOUS_MODE.md ARCHITECTURE.md

# Check template directory exists
ls ~/ContextPreservingFramework/03_TEMPLATES/
```

**Step 2**: Verify file contents

```bash
# Check for unreplaced placeholders
grep "\[PROJECT" CLAUDE.md
grep "\[YOUR_NAME\]" AUTONOMOUS_MODE.md
```

### Solution

**Solution 1**: Manual setup (robust)

```bash
cd /path/to/your/project

# Copy templates
cp ~/ContextPreservingFramework/03_TEMPLATES/CLAUDE.md.template ./CLAUDE.md
cp ~/ContextPreservingFramework/03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md

# Replace placeholders
sed -i '' 's/\[PROJECT_NAME\]/myproject/g' CLAUDE.md
sed -i '' 's/\[YOUR_NAME\]/John Doe/g' AUTONOMOUS_MODE.md
sed -i '' 's/\[DATE\]/2025-01-15/g' AUTONOMOUS_MODE.md

# Create directories
mkdir -p data/state logs docs/recovery_prompts

# Copy state template
cp ~/ContextPreservingFramework/03_TEMPLATES/project_types/coding/master_state_coding.json ./data/state/master_state.json

# Edit state file
vi data/state/master_state.json  # Replace placeholders
```

**Solution 2**: Use setup script

```bash
# If script exists
python ~/ContextPreservingFramework/scripts/setup_framework.py --interactive

# Follow prompts
```

**Solution 3**: Copy entire directory and clean up

```bash
# Copy framework to new project
cp -r ~/ContextPreservingFramework /path/to/myproject/.framework

# Copy needed files
cd /path/to/myproject
cp .framework/03_TEMPLATES/CLAUDE.md.template ./CLAUDE.md
cp .framework/03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md

# Customize
vi CLAUDE.md
vi AUTONOMOUS_MODE.md

# Remove framework copy
rm -rf .framework
```

### Prevention

1. Use setup script if available
2. Keep checklist of required files
3. Validate setup before starting work
4. Test with small task first
5. Document your setup process for future projects

---

## General Troubleshooting Tips

### When Something Goes Wrong

1. **Check git history**: Find last known-good state
   ```bash
   git log --oneline
   git diff abc123 HEAD
   ```

2. **Validate state files**: Ensure they're not corrupted
   ```bash
   python scripts/validate_state.py
   jq . data/state/master_state.json  # Check JSON is valid
   ```

3. **Review recent operations**: Check what was done
   ```bash
   tail -50 logs/operation_log.txt
   ```

4. **Estimate context**: See if that's the problem
   ```bash
   python scripts/estimate_context.py
   ```

5. **Read CLAUDE.md**: Verify rules are correct
   ```bash
   less CLAUDE.md
   ```

### Prevention Checklist

Use this checklist for new projects:

- [ ] CLAUDE.md in root (< 10KB)
- [ ] AUTONOMOUS_MODE.md in root, STATUS: ACTIVE
- [ ] ARCHITECTURE.md (< 20KB) or docs/architecture/ for details
- [ ] data/state/master_state.json exists and valid
- [ ] Git repository initialized
- [ ] Commit rules in CLAUDE.md
- [ ] Context tracking rules in CLAUDE.md
- [ ] Recovery prompt template exists
- [ ] External memory/ directory for references
- [ ] Scripts/ directory with estimate_context.py

---

## Edge Cases and Rare Scenarios

**Purpose**: Handle unusual situations not covered by standard workflow
**When to use**: Encountered scenario not in main documentation

---

### Edge Case 1: Module Cannot Be Decomposed to 250 Lines

**Scenario**: Algorithm is inherently complex, cannot be split without breaking logic

**Common in**:
- Dynamic programming algorithms (requires complete state table)
- State machine implementations (all states must be defined together)
- Parser implementations (grammar rules interconnected)
- Complex mathematical algorithms (steps tightly coupled)

**Symptoms**:
- Planning phase identifies module that must be >250 lines
- Breaking it up would obscure algorithm logic
- All functions highly interdependent

**Diagnosis**:
```bash
# Review module plan
cat docs/IMPLEMENTATION_PLAN.md | grep -A 10 "Module [X.Y]"
# Estimated lines: >300
```

**Solution**:

**Approach A**: Placeholder Pattern (Recommended)
1. **Session 1**: Implement core structure + placeholders (~200 lines)
   ```python
   def complex_algorithm(data):
       """Complex DP algorithm - see design doc"""
       # Initialize state table
       result = initialize_state_table(data)

       # Placeholder for step 1 (implement next session)
       result = _step1_process(result)  # TODO: Implement

       # Placeholder for step 2 (implement next session)
       result = _step2_optimize(result)  # TODO: Implement

       return finalize(result)

   def _step1_process(result):
       raise NotImplementedError("Implement in next session")

   def _step2_optimize(result):
       raise NotImplementedError("Implement in next session")
   ```
2. Write tests for placeholders (expected behavior, can mock for now)
3. Checkpoint (core structure complete)
4. **Session 2**: Implement `_step1_process` (~100 lines), test, checkpoint
5. **Session 3**: Implement `_step2_optimize` (~100 lines), test, checkpoint

**Approach B**: Extended Session (Use Sparingly)
1. Allow up to **350 lines** (absolute maximum)
2. Monitor context continuously (check every 30 minutes)
3. If context hits 33%, stop and checkpoint (even if incomplete)
4. Mark in IMPLEMENTATION_PLAN.md as "Large Module" (2 sessions allocated)

**Approach C**: Redesign (Last Resort)
1. If algorithm truly cannot be decomposed AND exceeds 350 lines:
2. Question: Is there architectural refactor that could help?
3. Example: Extract initialization, finalization into separate modules
4. Consult with human if stuck

**Prevention**:
- During planning, flag any module estimated >250 lines
- Apply decomposition strategy during planning, not during implementation

---

### Edge Case 2: Context Hits 35% Mid-Function

**Scenario**: Writing critical function, context suddenly at 36%, function half-done

**Symptoms**:
- Checkpoint box shows context 35-38%
- Currently in middle of writing function (not at natural stopping point)
- Function is partially written, incomplete

**Diagnosis**:
```bash
# Check exact context
python scripts/estimate_context.py
# Output: Context: 36.2%

# Check what happened
tail -20 logs/operation_log.txt
# Look for: Unexpected large operations (big file reads, exploration)
```

**Solution - Immediate Actions**:

1. **Stop writing immediately** (even mid-line if at 38%+)
2. Add inline comment:
   ```python
   def critical_function(data):
       # Process step 1
       result = step1(data)

       # INCOMPLETE: Resume here
       # NEXT: Process step 2 - apply transformation using result
       # NEXT: Validate result meets criteria X
       # NEXT: Return processed result
   ```
3. Commit incomplete work:
   ```bash
   git add .
   git commit -m "[Session N] Module X.Y: INCOMPLETE (context hit 36%)

   Status: Function 'critical_function' partially implemented
   Resume at: Line 45, step 2 processing
   Context: 36%"
   ```
4. Update module_state.json:
   ```json
   {
     "status": "incomplete",
     "incomplete_function": "critical_function",
     "resume_at": "line 45 - step 2 processing",
     "reason": "context_exceeded"
   }
   ```
5. Create detailed recovery prompt:
   ```markdown
   ## INCOMPLETE WORK - Resume Point

   **Function**: critical_function in core/module_1_3.py
   **Line**: 45
   **What's done**:
   - Step 1: Process input data
   - Result variable contains processed data

   **What remains**:
   - Step 2: Apply transformation using result
   - Step 3: Validate result meets criteria X
   - Step 4: Return processed result

   **Estimated**: ~20-30 lines remaining

   **To Resume**:
   1. Open core/module_1_3.py
   2. Find comment "# INCOMPLETE: Resume here"
   3. Continue implementation from that point
   ```
6. Exit session

**Next Session**:
1. Read recovery prompt (2K tokens)
2. Open file, find resume marker
3. Complete function (~20-30 lines)
4. Test immediately
5. Checkpoint

**Root Cause Analysis**:
- Why did context jump unexpectedly?
- Common causes:
  - Large file read without using external memory
  - Extensive debugging/exploration
  - Reading documentation instead of using scratch files
- Fix: Implement better context tracking

**Prevention**:
- Check context after EVERY function (not just after module)
- Use `scripts/estimate_context.py` continuously
- If context >30%, be extra careful (prepare to checkpoint any time)

---

### Edge Case 3: Git Not Available

**Scenario**: Working in environment without git (cloud IDE, restricted system, corporate policy)

**Symptoms**:
- `git` command fails: "command not found"
- No .git directory can be created
- Company policy blocks git usage
- Cloud IDE doesn't provide git access

**Diagnosis**:
```bash
# Test git
which git
# Output: (empty) or "not found"

git --version
# Output: Error
```

**Solution - Manual Versioning**:

**Step 1**: Replace git with filesystem snapshots
```bash
# In project root, create versions directory
mkdir -p versions/

# After each module completion (instead of git commit):
VERSION=$(date +%Y%m%d_%H%M%S)
mkdir -p versions/v_$VERSION
cp -r . versions/v_$VERSION/
echo "Module X.Y complete" > versions/v_$VERSION/VERSION_NOTES.txt
```

**Step 2**: Update CLAUDE.md:
```markdown
## Git Protocol (Modified - No Git Available)

After each module completion:
1. Create version snapshot: `./scripts/create_version.sh`
2. Version stored in: versions/v_YYYYMMDD_HHMMSS/
3. Add notes: Edit VERSION_NOTES.txt in version directory
```

**Step 3**: Create helper script:
```bash
# scripts/create_version.sh
#!/bin/bash
VERSION=$(date +%Y%m%d_%H%M%S)
mkdir -p versions/v_$VERSION
cp -r . versions/v_$VERSION/
rm -rf versions/v_$VERSION/versions  # Don't copy versions into versions
echo "Version: v_$VERSION" > versions/v_$VERSION/VERSION_NOTES.txt
echo "Created version: v_$VERSION"
```

**Step 4**: Update rules/CLAUDE.md:
- Change RULE 16 "Git Commit Protocol" to "Versioning Protocol"
- Replace `git commit` instructions with `./scripts/create_version.sh`

**Step 5**: Update recovery prompts:
- Instead of "Git commit: abc123"
- Use "Version: v_20250111_143000"

**Limitations**:
- No branching
- No push/pull (versions are local only)
- Disk space grows faster (use cleanup script)

**Cleanup script**:
```bash
# scripts/cleanup_old_versions.sh
# Keep only last 10 versions
cd versions/
ls -t | tail -n +11 | xargs rm -rf
```

**If git becomes available later**:
```bash
# Initialize git
git init

# Import version history
for dir in versions/v_*; do
  VERSION=$(basename $dir)
  cp -r $dir/* .
  git add .
  git commit -m "Import $VERSION"
done
```

---

### Edge Case 4: Tests Fail After 3 Retries

**Scenario**: Implemented module, wrote tests, tests fail, fixed issue, repeat 3x, still failing

**Symptoms**:
- Module implementation looks correct
- Tests consistently fail
- Already attempted 3 fixes
- Each fix changes something but tests still fail

**Diagnosis**:
```bash
# Run tests with verbose output
pytest tests/test_module_x_y.py -vv

# Check test output carefully
# Look for:
# - Consistent error pattern
# - Environmental issues
# - Dependency problems
```

**Common Root Causes**:

**Cause 1**: Architecture Problem (not just bug)
- Example: Module assumes synchronous, but system is async
- Example: Module doesn't handle database transactions correctly
- Fix: Requires architectural refactor, not simple bug fix

**Cause 2**: Environment/Dependency Issue
- Example: Test passes locally, fails in framework environment
- Example: Missing environment variable
- Example: Database not seeded with test data
- Fix: Setup issue, not code issue

**Cause 3**: Test is Wrong (not code)
- Example: Test has incorrect assertions
- Example: Test expectations don't match actual requirements
- Fix: Update test, not code

**Solution - Escalation Protocol**:

1. **Stop autonomous fixes** (after 3 attempts)
2. Create issue file:
   ```markdown
   # issues/ISSUE_MODULE_X_Y_TESTS_FAILING.md

   ## Problem
   Module X.Y tests failing after 3 fix attempts

   ## Module Details
   - Module: X.Y [Name]
   - File: core/module_x_y.py
   - Test: tests/test_module_x_y.py
   - Lines: ~250

   ## Test Output
   ```
   [Paste full test output here]
   ```

   ## Fix Attempts

   ### Attempt 1
   - What was tried: [description]
   - Rationale: [why we thought this would fix it]
   - Result: [still failed, error changed/same]

   ### Attempt 2
   - What was tried: [description]
   - Rationale: [why we thought this would fix it]
   - Result: [still failed, error changed/same]

   ### Attempt 3
   - What was tried: [description]
   - Rationale: [why we thought this would fix it]
   - Result: [still failed, error changed/same]

   ## Hypothesis
   [Best guess at root cause after 3 attempts]
   - [ ] Architecture problem?
   - [ ] Environment issue?
   - [ ] Test is incorrect?
   - [ ] Dependency missing?

   ## Current State
   - Code committed: [git hash or version]
   - Module status: "blocked_on_tests"
   - Context: [N]%

   ## Next Steps
   - [ ] Human review required
   - [ ] Possible architecture refactor needed
   - [ ] Or: Skip module, continue with others, return later
   ```

3. Update master_state.json:
   ```json
   {
     "modules_blocked": ["X.Y"],
     "issues": ["ISSUE_MODULE_X_Y_TESTS_FAILING"]
   }
   ```

4. **Decision Point**: Continue or Stop?
   - **Option A**: Move to next module (come back to blocked module later)
   - **Option B**: Escalate to human (stop autonomous work)
   - Recommendation: Option A if other modules don't depend on this one

5. Create recovery prompt noting blocked module

**When Human Reviews**:
- Read issue file
- Review all 3 fix attempts
- Identify actual root cause
- Provide guidance or architectural refactor
- Mark issue resolved

**Prevention**:
- Better planning (identify architecture risks early)
- Write tests before implementation (TDD approach)
- Validate test assertions are correct

---

### Edge Case 5: Hybrid Project (Code + Writing)

**Scenario**: Project has BOTH significant code AND significant writing (e.g., ML research = training code + paper)

**Symptoms**:
- Need to implement model training (code)
- Need to write research paper (writing)
- Neither dominates (40/60 or 60/40 split)
- Unclear which framework template to use

**Diagnosis**:
```bash
# Assess project composition
find . -name "*.py" | xargs wc -l | tail -1
# Code: ~1,500 lines

find . -name "*.md" -path "*/paper/*" | xargs wc -w | tail -1
# Writing: ~6,000 words

# Conclusion: Both substantial → Hybrid project
```

**Solution - Separate Projects Approach**:

**Rationale**: Mixing coding and writing templates creates confusion. Separate projects maintain clarity.

**Step 1**: Restructure directories
```bash
# Create parent directory
mkdir -p my_research_project/
cd my_research_project/

# Two sub-projects
mkdir -p code/       # Coding project (ML training)
mkdir -p paper/      # Writing project (research paper)
mkdir -p shared/     # Shared resources
```

**Step 2**: Set up coding project
```bash
cd code/

# Copy coding templates
cp -r ~/ContextPreservingFramework/03_TEMPLATES/project_types/coding/* .
cp ~/ContextPreservingFramework/03_TEMPLATES/CLAUDE.md.template ./CLAUDE.md
cp ~/ContextPreservingFramework/03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md

# Customize
# - Project type: CODING
# - Language: Python
# - Modules: data loading, model training, evaluation, etc.

# Initialize
mkdir -p core tests data/state logs
git init
```

**Step 3**: Set up paper project
```bash
cd ../paper/

# Copy non-coding templates
cp -r ~/ContextPreservingFramework/03_TEMPLATES/project_types/non_coding/* .
cp ~/ContextPreservingFramework/03_TEMPLATES/CLAUDE.md.template ./CLAUDE.md
cp ~/ContextPreservingFramework/03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md

# Customize
# - Project type: RESEARCH
# - Domain: Machine learning
# - Sections: intro, related work, methods, results, discussion

# Initialize
mkdir -p sections references figures data/state logs
git init
```

**Step 4**: Link shared resources
```bash
cd code/
ln -s ../shared/data ./data/shared
ln -s ../shared/results ./results

cd ../paper/
ln -s ../shared/results ./figures/from_code
ln -s ../shared/data ./references/datasets
```

**Step 5**: Workflow
```bash
# Phase 1: Code implementation (work in code/)
cd code/
# - Implement data loading (Module 1.1)
# - Implement model training (Module 1.2)
# - Generate results → ../shared/results/
# - Checkpoint, exit

# Phase 2: Paper writing (work in paper/)
cd ../paper/
# - Write methods section (reference ../shared/results/)
# - Write results section (import figures from ../shared/results/)
# - Checkpoint, exit
```

**Benefits**:
- ✅ Clean separation of concerns
- ✅ Appropriate templates for each (coding vs research)
- ✅ Appropriate validation (tests for code, citations for paper)
- ✅ Can work on both in parallel (different sessions)
- ✅ No template confusion

**State Tracking**:
- `code/data/state/master_state.json` (modules_complete, tests_passing)
- `paper/data/state/master_state.json` (sections_complete, word_count, references_cited)
- Independent recovery prompts for each

**Git Options**:
- **Option A**: Separate repos (code/.git, paper/.git)
- **Option B**: Single repo with prefixes:
  ```bash
  git commit -m "[CODE] Module 1.1: Data loading"
  git commit -m "[PAPER] Section 3: Methods"
  ```

**Alternative** (if one dominates >70%):
- Code-heavy: Use CODING templates, treat paper as "documentation module"
- Writing-heavy: Use RESEARCH templates, treat code as "analysis scripts"

---

## Getting Help

If you're still stuck:

1. **Review framework docs**: See README.md, 01_PHILOSOPHY.md, 02_SETUP_GUIDE.md
2. **Check examples**: 09_EXAMPLES/ for working examples
3. **Validate setup**: Compare your setup to examples
4. **Start fresh**: Copy template exactly, modify minimally
5. **Test incrementally**: One small task to verify framework works

---

**Common Success Pattern**:

1. Start with exact templates (don't modify yet)
2. Test with one small module
3. Verify context tracking works
4. Verify recovery prompts work
5. Then customize for your project

**Most common mistake**: Over-customizing before verifying basics work

---

## Quick Reference: Essential Commands

```bash
# Check context
python scripts/estimate_context.py

# Validate state
python scripts/validate_state.py

# Check git status
git status
git log --oneline -5

# View state
cat data/state/master_state.json | jq .

# Check what's in context
ls -lh CLAUDE.md AUTONOMOUS_MODE.md ARCHITECTURE.md data/state/*.json

# Estimate total context usage
find . -name "*.md" -o -name "*.json" | xargs wc -c | tail -1
```

---

For additional help, see:
- 02_SETUP_GUIDE.md - Complete setup instructions
- 04_CORE_WORKFLOW.md - Daily workflow
- 09_EXAMPLES/ - Working examples
- 10_REFERENCE/ - Quick reference tables
