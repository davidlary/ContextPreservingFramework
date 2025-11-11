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

## Project-Type-Specific Validation Criteria

**Purpose**: Define what "passing" means for different project types
**When to use**: After each work unit (module/section/scene/page) completion
**Critical**: Validation must pass before marking unit complete and committing

---

### Coding Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Unit tests | Per module | 100% pass, 0 failures | `pytest tests/` or `npm test` or `cargo test` |
| Linting | Per module | 0 errors (warnings OK) | `pylint file.py` or `eslint file.js` or `clippy` |
| Type checking | Per module (typed languages) | 0 errors | `mypy file.py` or `tsc --noEmit` or `cargo check` |
| Integration tests | Per milestone (3-5 modules) | All scenarios pass | `pytest tests/integration/` |
| Code coverage | Per milestone | ≥80% line coverage | `pytest --cov=core tests/` |
| State integrity | Every checkpoint | JSON validates against schema | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Module)**:
```bash
# 1. Run unit tests
pytest tests/test_module_1_1.py
# Expected: All tests pass

# 2. Run linter
pylint core/module_1_1.py
# Expected: Score ≥8.0/10 (or 0 errors)

# 3. Run type checker (if applicable)
mypy core/module_1_1.py
# Expected: Success: no issues found

# 4. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark module complete, commit
```

---

### Research Paper Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Citation completeness | Per section | All [Author, Year] appear in references | `scripts/check_citations.sh` |
| Word count | Per section | Within ±15% of target | `wc -w section.md` and compare to target |
| Reference formatting | Per section | All match journal style (APA/MLA/etc.) | `scripts/validate_references.sh` (or manual check) |
| Figure references | Per section | All "Figure N" exist in figures/ | `grep "Figure [0-9]" section.md` + verify files |
| Table references | Per section | All "Table N" exist | `grep "Table [0-9]" section.md` + verify files |
| Section coherence | Per section | Outline points addressed (manual) | 30-second review against outline |
| State integrity | Every checkpoint | JSON validates | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Section)**:
```bash
# 1. Check word count
wc -w sections/02_lit_review.md
# Expected: 1000-1500 words (target ±15%)

# 2. Check citations
scripts/check_citations.sh sections/02_lit_review.md references/bibliography.bib
# Expected: All citations found in bibliography

# 3. Check figure references
grep "Figure [0-9]" sections/02_lit_review.md
figures/ ls
# Expected: All referenced figures exist

# 4. Manual coherence check
# Review against outline: Did we cover all points?
# Expected: Yes

# 5. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark section complete, commit
```

---

### Book Writing Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Character consistency | Per scene/chapter | Names, traits match character_db.json | `scripts/check_characters.sh` |
| Timeline consistency | Per scene/chapter | No temporal contradictions | `scripts/check_timeline.sh` (or manual spreadsheet) |
| Word count | Per scene/chapter | Within ±20% of target | `wc -w chapter/scene.md` |
| POV consistency | Per scene | No POV shifts within scene | Manual review (60 seconds) |
| Plot points | Per chapter | All outline points addressed | `scripts/check_outline.sh` |
| Dialogue tags | Per scene | Consistent attribution style | Manual review or grep for patterns |
| State integrity | Every checkpoint | JSON validates | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Scene)**:
```bash
# 1. Check word count
wc -w chapters/ch01/scene02.md
# Expected: 1000-1500 words (target ±20%)

# 2. Check character consistency
scripts/check_characters.sh chapters/ch01/scene02.md data/character_db.json
# Expected: All character mentions match database (names, traits)

# 3. Check timeline
scripts/check_timeline.sh chapters/ch01/scene02.md
# Expected: No date/time contradictions

# 4. Manual POV check
# Read scene: Is it all one POV? No head-hopping?
# Expected: Consistent POV throughout

# 5. Check against outline
scripts/check_outline.sh chapters/ch01/scene02.md docs/outline.md
# Expected: All plot points for this scene addressed

# 6. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark scene complete, commit
```

---

### Documentation Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Code examples | Per page | All code blocks runnable, 0 errors | `scripts/test_examples.sh page.md` |
| Link validity | Per page | No broken links (internal & external) | `scripts/check_links.sh page.md` |
| Image references | Per page | All images exist in images/ | `grep "!\[.*\]" page.md` + verify files |
| API accuracy | Per page | API examples match latest version | `scripts/validate_api_calls.sh` (calls API) |
| Spelling/grammar | Per page | 0 critical errors (minor OK) | `aspell check page.md` or Grammarly CLI |
| Heading structure | Per page | Proper H1-H6 hierarchy | `scripts/check_headings.sh page.md` |
| State integrity | Every checkpoint | JSON validates | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Page)**:
```bash
# 1. Test all code examples
scripts/test_examples.sh docs/getting_started.md
# Expected: All code blocks execute successfully

# 2. Check links
scripts/check_links.sh docs/getting_started.md
# Expected: All links return 200 OK (or valid internal links)

# 3. Check images
grep "!\[.*\]" docs/getting_started.md | grep -o "images/[^)]*"
ls images/
# Expected: All referenced images exist

# 4. Spell check
aspell check docs/getting_started.md
# Expected: No spelling errors (or manually reviewed)

# 5. Check API examples
scripts/validate_api_calls.sh docs/getting_started.md
# Expected: All API calls return expected responses

# 6. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark page complete, commit
```

---

### Data Analysis Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Notebook execution | Per analysis unit | All cells run without error | `jupyter nbconvert --execute notebook.ipynb` |
| Data integrity | Per data load | No missing/corrupt values | `scripts/check_data_integrity.py` |
| Reproducibility | Per analysis | Same inputs → same outputs | Re-run analysis, compare results |
| Visualization validity | Per plot | No NaN/Inf in plotted data | Check data before plotting |
| Results documentation | Per analysis | Findings saved to results/ | Verify output files created |
| State integrity | Every checkpoint | JSON validates | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Analysis)**:
```bash
# 1. Execute notebook
jupyter nbconvert --execute --to notebook --inplace notebooks/analysis_01.ipynb
# Expected: All cells execute, no errors

# 2. Check data integrity
python scripts/check_data_integrity.py data/processed/dataset.csv
# Expected: No missing values, no corrupt entries

# 3. Verify reproducibility
python scripts/compare_results.py results/analysis_01_run1.json results/analysis_01_run2.json
# Expected: Results match (within numerical precision)

# 4. Check visualizations
python -c "import pandas as pd; df = pd.read_csv('results/analysis_01.csv'); print(df.isnull().sum())"
# Expected: No NaNs in result data

# 5. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark analysis complete, commit
```

---

### How to Use These Validation Tables

**Step 1**: Identify your project type
- Coding, Research, Book, Documentation, or Data Analysis

**Step 2**: After completing each work unit (module/section/scene/page/analysis):
1. Run all "Automated Check" commands for your project type (in order)
2. Perform any "manual" checks (typically <2 minutes total)
3. Record results (all must PASS)

**Step 3**: If ANY test FAILS:
1. **Do NOT mark unit complete**
2. **Do NOT commit** to git
3. Fix the issue immediately
4. Re-run ALL tests for that unit
5. Maximum 3 fix attempts before escalating to issue file

**Step 4**: When ALL tests PASS:
1. Update state files (mark unit complete)
2. Git commit with test results in message
3. Continue to next unit OR checkpoint if context ≥30%

---

### Creating Validation Scripts

**Note**: Many validation checks require scripts. If script doesn't exist:

**Option 1**: Implement script following `06_SCRIPTS_GUIDE.md` pattern
```bash
# Example: scripts/check_citations.sh
#!/bin/bash
# Extract citations from markdown
# Compare against bibliography
# Report missing citations
```

**Option 2**: Manual validation (acceptable for small projects)
```bash
# Instead of: scripts/check_citations.sh section.md
# Manually: grep '\[.*[0-9]\{4\}\]' section.md and verify each
```

**Option 3**: Use existing tools
```bash
# Link checking: use existing tool
npm install -g broken-link-checker
blc docs/page.md

# Spell checking: use aspell
aspell check page.md
```

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
