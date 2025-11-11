# Testing Guide - Progressive Validation

**How to validate framework setup with 6 sequential tests**

**Duration**: 10-15 minutes total (2-3 min per test)
**Token cost per test**: ~2K tokens
**When to use**: After framework setup, before starting project work

---

## IMPORTANT: Test One at a Time

**DO NOT run all tests in one session.**

**Pattern**:
1. Run Test 1
2. If pass → proceed to Test 2
3. If fail → fix issue, re-run Test 1
4. Repeat for each test

**Why**: Each test is independent, running all at once wastes context.

---

## Test 1: AUTONOMOUS_MODE Recognition

### Purpose
Verify Claude recognizes AUTONOMOUS_MODE.md and operates autonomously.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 1: Check if AUTONOMOUS_MODE.md exists and is ACTIVE.

Steps:
1. Check if file exists: AUTONOMOUS_MODE.md
2. Read the STATUS line
3. Display status
4. If ACTIVE: Confirm autonomous operation enabled
```

### Expected Output

```
✅ Test 1: AUTONOMOUS_MODE Recognition

File: AUTONOMOUS_MODE.md
Status: ACTIVE
Permission granted: [date]
Scope: [project scope]

✅ AUTONOMOUS_MODE active - operating autonomously
✅ Will not ask for permission for:
   - Creating files in specifications
   - Running tests
   - Git commits
   - Installing packages in requirements

Test 1: PASSED
```

### If Test Fails

**Symptom**: File not found OR STATUS not ACTIVE

**Fix**:
```bash
# Check file exists
ls -la AUTONOMOUS_MODE.md

# If missing, copy template
cp 03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md

# Edit file, set:
STATUS: ACTIVE
PERMISSION GRANTED: [today's date]
```

**Re-run Test 1** after fix.

---

## Test 2: State File Updates

### Purpose
Verify Claude can update state files correctly.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 2: Update data/state/master_state.json

Steps:
1. Read current master_state.json
2. Update current_phase to "testing"
3. Add "test_module" to modules_in_progress
4. Update last_update timestamp
5. Display updated content
6. Verify JSON is valid
```

### Expected Output

```
✅ Test 2: State File Updates

Before:
{
  "current_phase": "setup",
  "modules_in_progress": [],
  ...
}

After:
{
  "current_phase": "testing",
  "modules_in_progress": ["test_module"],
  "last_update": "2025-01-11T16:45:00Z",
  ...
}

✅ File updated successfully
✅ JSON is valid
✅ Timestamp is current

Test 2: PASSED
```

### If Test Fails

**Symptom**: File not found OR JSON invalid OR update failed

**Fix**:
```bash
# Check file exists
cat data/state/master_state.json

# If missing or invalid, recreate from template
# For coding project:
cat > data/state/master_state.json <<EOF
{
  "project": "test_project",
  "version": "0.1.0",
  "project_type": "coding",
  "current_phase": "setup",
  "current_module": null,
  "modules_complete": [],
  "modules_in_progress": [],
  "modules_pending": [],
  "last_update": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Verify valid JSON
python -m json.tool data/state/master_state.json
```

**Re-run Test 2** after fix.

---

## Test 3: Checkpoint Box Display

### Purpose
Verify Claude displays state tracking checkpoint boxes (RULE 15).

### Instructions for Claude Code

**Prompt to paste**:
```
Test 3: Display a STATE TRACKING CHECKPOINT box per RULE 15.

Use these placeholder values:
- Operation: "test_operation"
- Context: 15K tokens (7.5%)
- Status: SAFE
- Git: test123
- Operations: 3

Display the checkpoint box exactly as specified in rules/CLAUDE.md RULE 15.
```

### Expected Output

```
═══════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC)
═══════════════════════════════════════════════════════════

✅ Operation logged: test_operation → logs/operation_log.txt
✅ State updated: data/state/master_state.json (timestamp: 16:45:23)
✅ Context tracked: 15K tokens (7.5%)
✅ Threshold check: SAFE
✅ Git status: test123

Next threshold: 35% at 70K tokens
Operations this session: 3

═══════════════════════════════════════════════════════════

✅ Test 3: PASSED
```

### If Test Fails

**Symptom**: No checkpoint box OR wrong format OR missing elements

**Fix**:
```
Check rules/CLAUDE.md RULE 15 has the exact template.

If RULE 15 is missing or wrong:
1. Copy from 03_TEMPLATES/rules_CLAUDE.md.template
2. Ensure RULE 15 section is complete
3. Save file
```

**Re-run Test 3** after fix.

---

## Test 4: Git Commit Protocol

### Purpose
Verify git commits follow framework format.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 4: Create test file and commit with framework format.

Steps:
1. Create file: test_framework.txt with content "Framework test"
2. Git add file
3. Git commit using the framework's commit message format from RULE 16
   Message should include:
   - Session/module identifier
   - Changes description
   - Progress indicator
   - Claude Code attribution
   - Co-authored-by line
4. Display commit message
5. Show git log entry
```

### Expected Output

```
✅ Test 4: Git Commit Protocol

File created: test_framework.txt

Commit message:
─────────────────────────────────────────
[Test Session] Framework validation

Changes:
- test_framework.txt (test file)

Status: Framework operational
Progress: Testing in progress

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
─────────────────────────────────────────

Git log:
abc1234 [Test Session] Framework validation

✅ Commit successful
✅ Format follows RULE 16
✅ Attribution included

Test 4: PASSED
```

### If Test Fails

**Symptom**: Commit failed OR wrong format OR missing attribution

**Fix**:
```bash
# Check git is initialized
git status

# If not initialized:
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Check RULE 16 in rules/CLAUDE.md has commit template
# If missing, copy from template
```

**Re-run Test 4** after fix.

---

## Test 5: Recovery Prompt Generation

### Purpose
Verify Claude can create recovery prompts.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 5: Create test recovery prompt.

Steps:
1. Generate recovery prompt in: docs/recovery_prompts/TEST_SESSION.md
2. Use template from: docs/recovery_prompts/SESSION_TEMPLATE.md
3. Include all required sections:
   - Session ID
   - Git commit
   - Context percentage
   - Completed items
   - Next steps
   - Recovery instructions
4. Display created prompt
5. Verify file exists
```

### Expected Output

```
✅ Test 5: Recovery Prompt Generation

Created: docs/recovery_prompts/TEST_SESSION.md

Content:
─────────────────────────────────────────
# Test Session Recovery

**Git commit**: abc1234
**Context**: 7.5%
**Status**: Testing

## Completed:
- Test 1-4 passed

## Next:
- Test 5-6

## Recovery Instructions:
Paste in next session:
```
Resume testing from Test 5.
Recovery prompt: docs/recovery_prompts/TEST_SESSION.md
```
─────────────────────────────────────────

✅ File created: docs/recovery_prompts/TEST_SESSION.md
✅ Template structure followed
✅ All sections present

Test 5: PASSED
```

### If Test Fails

**Symptom**: File not created OR wrong structure OR missing sections

**Fix**:
```bash
# Check directory exists
ls -la docs/recovery_prompts/

# If missing:
mkdir -p docs/recovery_prompts

# Check template exists
cat docs/recovery_prompts/SESSION_TEMPLATE.md

# If template missing, copy from 03_TEMPLATES/
```

**Re-run Test 5** after fix.

---

## Test 6: Context Threshold Simulation

### Purpose
Verify Claude responds correctly to high context usage.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 6: Simulate context at 36% (above 35% critical threshold).

Question: What should happen per rules/CLAUDE.md when context exceeds 35%?

Display:
1. What RULE 15 says about this
2. What actions are required
3. Simulate those actions (don't actually exit, just show what would happen)
```

### Expected Output

```
✅ Test 6: Context Threshold Simulation

Context: 36% (CRITICAL - exceeds 35% threshold)

Per RULE 15:
"If context > 35%: prepare handoff and exit"

Required actions:
1. ✅ Finish current atomic task
2. ✅ Commit all work to git
3. ✅ Update all state files
4. ✅ Create recovery prompt
5. ✅ Display checkpoint box
6. ✅ Display NEXT STEPS section
7. ✅ Exit session

Simulation (what would happen):

[Would display checkpoint box showing 36% context]

[Would create recovery prompt]

[Would display NEXT STEPS with exact recovery instructions]

✅ Claude understands 35% threshold
✅ Correct procedures identified
✅ Would execute graceful exit

Test 6: PASSED
```

### If Test Fails

**Symptom**: Claude doesn't know threshold OR wrong actions

**Fix**:
```
Check rules/CLAUDE.md has:
- RULE 10: Mentions 35% threshold
- RULE 15: Mentions context > 35% behavior
- RULE 17: Mentions NEXT STEPS requirement

If rules missing or incomplete, copy from template.
```

**Re-run Test 6** after fix.

---

## Validation Summary

### After All 6 Tests Pass

**Display summary**:
```
════════════════════════════════════════════════════════════
✅ FRAMEWORK VALIDATION COMPLETE
════════════════════════════════════════════════════════════

Tests passed: 6/6

✅ Test 1: AUTONOMOUS_MODE Recognition
✅ Test 2: State File Updates
✅ Test 3: Checkpoint Box Display
✅ Test 4: Git Commit Protocol
✅ Test 5: Recovery Prompt Generation
✅ Test 6: Context Threshold Simulation

Framework is operational and ready for use.

════════════════════════════════════════════════════════════

Next steps:
1. Read: 04_CORE_WORKFLOW.md (understand daily workflow)
2. Define: Your modules in docs/IMPLEMENTATION_PLAN.md
3. Start: Implement Module 1.1 following workflow
```

### If Any Test Failed

**Do NOT proceed until all tests pass.**

**Pattern**:
1. Identify which test failed
2. Read "If Test Fails" section for that test
3. Apply fix
4. Re-run that test only
5. Continue to next test once passed

---

## Testing Checklist

**Before starting project work**:
- [ ] Test 1: AUTONOMOUS_MODE Recognition - PASSED
- [ ] Test 2: State File Updates - PASSED
- [ ] Test 3: Checkpoint Box Display - PASSED
- [ ] Test 4: Git Commit Protocol - PASSED
- [ ] Test 5: Recovery Prompt Generation - PASSED
- [ ] Test 6: Context Threshold Simulation - PASSED

**All passed?** → Framework ready, proceed to project work

**Any failed?** → Fix and re-test before proceeding

---

## Next Steps After Validation

**Framework is validated!** Now:

1. **Read**: `04_CORE_WORKFLOW.md` - Understand daily workflow
2. **Implement**: Scripts per `06_SCRIPTS_GUIDE.md` (optional but recommended)
3. **Start**: Begin Module 1.1 implementation

Or:

- **See examples**: `09_EXAMPLES/` for your project type
- **Get help**: `08_TROUBLESHOOTING.md` if issues arise

---

**Testing guide version**: 3.0
**Last updated**: January 2025
