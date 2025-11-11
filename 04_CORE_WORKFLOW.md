# Core Workflow - Daily Implementation Pattern

**How to use the framework for daily coding/writing work**

**Estimated reading time**: 15 minutes
**Token cost**: ~12K tokens (6% context)
**When to read**: Once, then reference specific sections as needed

---

## Table of Contents

1. [Session Start Pattern](#session-start-pattern)
2. [Module Implementation Workflow](#module-implementation-workflow)
3. [Session End Pattern](#session-end-pattern)
4. [Context Management During Work](#context-management-during-work)
5. [Adaptations for Non-Coding Projects](#adaptations-for-non-coding-projects)

---

## Session Start Pattern

### First Session (Framework Setup Complete)

**Step 1**: Verify framework is active
```
Check AUTONOMOUS_MODE.md exists and STATUS: ACTIVE
Display: "✅ AUTONOMOUS_MODE active - operating autonomously"
```

**Step 2**: Review current state
```
Read: data/state/master_state.json
Display:
- Project: [name]
- Current phase: [phase]
- Modules complete: [list]
- Modules pending: [list]
- Last update: [timestamp]
```

**Step 3**: Select first module
```
From: docs/IMPLEMENTATION_PLAN.md
Read ONLY first module section (not entire plan)
Module: 1.1 [Name]
Estimated: 1 hour, 250 lines
```

**Step 4**: Initialize module state
```
Create: data/state/module_1.1_state.json
{
  "module": "1.1",
  "name": "[Module Name]",
  "status": "in_progress",
  "start_time": "[timestamp]",
  "functions_implemented": [],
  "functions_pending": ["func1", "func2", "..."],
  "tests_written": 0,
  "tests_passing": 0
}
```

**Step 5**: Begin implementation
→ Follow [Module Implementation Workflow](#module-implementation-workflow)

---

### Subsequent Sessions (Resuming Work)

**Step 1**: Read recovery prompt
```
Read: docs/recovery_prompts/[LATEST]_RECOVERY.md
Time: 2 minutes, ~2K tokens
```

**Recovery prompt contains**:
- What was completed last session
- What was in progress
- Exact next steps
- Files to check

**Step 2**: Load state
```
Read: data/state/master_state.json
Check: current_module
If null: Start next module from pending list
If not null: Resume that module
```

**Step 3**: Reset context tracking
```
Update: data/state/context_tracking.json
Set: estimated_tokens = 0 (new session)
Set: operations_this_session = 0
```

**Step 4**: Continue work
→ Follow [Module Implementation Workflow](#module-implementation-workflow)

---

## Module Implementation Workflow

### Pattern: Write → Test → Commit → Repeat

**Duration**: 30-60 minutes per module
**Context budget**: 35-50K tokens per module

---

### Phase 1: Implementation (20-30 min, 15-20K tokens)

**Step 1**: Read module specification
```
From: docs/IMPLEMENTATION_PLAN.md
Read: ONLY current module section
Don't: Read entire plan (waste 30K+ tokens)
```

**Step 2**: Implement functions one at a time
```
For each function in module:
  1. Write function (20-50 lines)
  2. Update module_state.json:
     - Move function from functions_pending to functions_implemented
  3. Check context estimate
  4. If context < 30%: Continue to next function
  5. If context ≥ 30%: Note in checkpoint, consider finishing module
```

**Step 3**: Use external memory pattern
```
If exploring/researching:
  1. Create: data/scratch/[TOPIC].md
  2. Write findings to file (not conversation)
  3. Summarize in conversation (3 bullets)
  4. Later: Read scratch file instead of re-exploring
```

**Context check after implementation**:
```
Estimate: ~15-20K tokens consumed
Remaining budget: ~15-18K for tests
```

---

### Phase 2: Testing (15-20 min, 15-20K tokens)

**Step 1**: Write tests
```
For each function:
  1. Write 2-3 unit tests
  2. Cover: normal case, edge case, error case
```

**Step 2**: Run tests
```
Execute: [TEST_COMMAND]  (e.g., pytest tests/)
Capture: Output
```

**Step 3**: Handle failures
```
If tests fail:
  1. Read error message
  2. Fix issue
  3. Re-run tests
  4. Budget: 10-15K tokens for debugging
  5. Max retries: 3 (then escalate to issue)
```

**Step 4**: Update module state
```
Update: module_state.json
{
  "tests_written": [N],
  "tests_passing": [N],
  "status": "testing_complete"
}
```

**Context check after testing**:
```
Total consumed: ~35-40K tokens
Remaining budget: safe for commit
```

---

### Phase 3: Completion (5-10 min, 3-5K tokens)

**Step 1**: Complete module
```
Update: data/state/master_state.json
- Remove from modules_in_progress
- Add to modules_complete

Update: module_state.json
- status: "complete"
- completion_time: [timestamp]
```

**Step 2**: Git commit
```
git add .
git commit -m "[Session N] Module X.Y: [Name] - COMPLETE

Changes:
- [file1] ([N] lines)
- [file2] ([N] tests)

Tests: [N]/[N] passing
Progress: [X]/[Y] modules complete

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Step 3**: Check context
```
Read: data/state/context_tracking.json
If < 30%: Continue to next module
If 30-35%: Finish current work, prepare exit
If ≥ 35%: Create recovery prompt, exit
```

---

### Work Unit Sizing Edge Cases

**Purpose**: Handle scenarios where standard sizing rules (250 lines, 1 hour) don't apply cleanly
**When to use**: Encountered unusual module characteristics or uncertain estimation

---

#### Edge Case 1: Module Inherently >250 Lines

**Scenario**: Algorithm is complex and cannot be split without breaking logic

**Examples**:
- Dynamic programming algorithm (requires complete state table)
- State machine implementation (all states must be defined together)
- Parser implementation (grammar rules interconnected)

**Solution**:
1. **First session**: Implement core structure + placeholders (~200 lines)
   ```python
   def complex_algorithm(data):
       # Main structure
       result = initialize()
       result = step1_placeholder(result)  # Implement next session
       result = step2_placeholder(result)  # Implement next session
       return result
   ```
2. **Write tests** for placeholders (expected behavior)
3. **Checkpoint** (core structure complete)
4. **Next session**: Implement placeholders one at a time (~50-100 lines each)
5. **Maximum single-session**: 350 lines (absolute limit, checkpoint anyway)

---

#### Edge Case 2: Module Too Small (<100 Lines)

**Scenario**: Work unit is tiny, would result in excessive checkpointing

**Examples**:
- Simple utility function (20-30 lines)
- Configuration file (50 lines)
- Data model with few fields (40 lines)

**Solution**:
1. **Combine with related module**: Merge modules 1.1 + 1.2 into single unit
2. **Still checkpoint** after combined unit complete
3. **Minimum viable unit**: ~150 lines OR 1 complete feature (whichever is more meaningful)
4. **Update IMPLEMENTATION_PLAN.md**: Note combined modules

---

#### Edge Case 3: Uncertain Size Estimation

**Scenario**: Don't know how large module will be beforehand

**Examples**:
- Exploratory implementation (trying different approaches)
- Integration with unfamiliar API (unknown complexity)
- Refactoring existing code (unclear scope)

**Solution - Dynamic Assessment**:
1. **Start implementation** (begin work)
2. **At 200 lines**: Assess remaining work
   - If <50 lines remaining: Finish module (total ~250 lines)
   - If 50-100 lines remaining: Decide based on context percentage
     - Context <25%: Finish module (total ~300 lines, acceptable)
     - Context ≥25%: Checkpoint now, continue next session
   - If >100 lines remaining: Checkpoint now (module needs decomposition)
3. **Re-estimate** for next session based on actual complexity observed

---

#### Edge Case 4: Context Approaching Limit Mid-Module

**Scenario**: Started module with 20% context, now at 32% and module only 60% complete

**Decision logic** (see [Checkpoint Decision Algorithm](#checkpoint-decision-algorithm) for full details):

**At 32% context**:
- **If <50 lines remaining** in module: Finish module, then checkpoint
- **If ≥50 lines remaining**: Stop at next function boundary, checkpoint now

**At 35% context**:
- **Stop immediately** at current function boundary
- **Checkpoint** with module marked "in_progress"
- **Resume** next session from exact stopping point

**At 38%+ context** (emergency):
- **Force checkpoint** immediately (even mid-function if necessary)
- **Add comment**: `# INCOMPLETE: Resume here - [description]`
- **Mark module**: `"status": "incomplete"` in module_state.json

---

#### Edge Case 5: Data Analysis (No Clear "Lines of Code" Metric)

**Scenario**: Jupyter notebook, exploratory data analysis, visualization work

**Solution - Redefine Work Unit**:
- **Work unit** = 1 analysis question OR 1 visualization
- **Size metric**: ~1 hour OR 3-5 notebook cells
- **Examples**:
  - "What is the distribution of variable X?" → 1 unit (plot + summary stats)
  - "Do variables X and Y correlate?" → 1 unit (correlation analysis + scatter plot)
  - "Train baseline model" → 1 unit (model code + evaluation metrics)
- **Checkpoint after**: Each analysis question answered
- **State tracking**: `questions_answered` instead of `modules_complete`

---

#### Edge Case 6: Non-Coding Work Units

**For research papers, books, documentation** (non-coding projects):

**Standard sizing**:
- **Research section**: 1,000-1,500 words OR 1 complete argument
- **Book scene**: 1,000-1,500 words OR 1 complete scene/chapter
- **Documentation page**: 800-1,200 words OR 1 complete concept

**Edge cases**:
- **Section too long** (>2,000 words needed):
  - Split into Part 1 and Part 2 (e.g., "Literature Review Part 1", "Part 2")
  - Checkpoint after each part
- **Section too short** (<500 words):
  - Combine with next section if thematically related
  - Minimum: 700 words per checkpoint
- **Uncertain length**:
  - Start writing
  - At 1,000 words: Assess if argument is complete
  - If yes: Finish section and checkpoint
  - If no: Checkpoint at 1,500 words, continue next session

---

## Session End Pattern

### When to End Session

**Trigger any of these**:
1. Context usage ≥ 35% (hard limit)
2. Context usage ≥ 30% AND module complete (soft limit)
3. Natural phase boundary (all modules in current phase done)
4. Time elapsed > 2 hours (fatigue factor)

---

### Checkpoint Decision Algorithm

**Purpose**: Deterministic logic for when to checkpoint (removes ambiguity)
**Input**: current_context_pct, module_completion_pct, current_task_status

---

#### Decision Tree (Follow This Exactly)

```
INPUTS:
  - current_context_pct: float (0-100)
  - module_completion_pct: float (0-100)
  - current_task_status: enum (not_started, in_middle_of_function, at_function_boundary, module_complete)

DECISION LOGIC:

IF current_context_pct >= 40:
  ────────────────────────────────────────────────────────────────
  EMERGENCY EXIT (Force checkpoint immediately)
  ────────────────────────────────────────────────────────────────
  ACTION:
    1. IF current_task_status == "in_middle_of_function":
         - Add comment: # INCOMPLETE: Resume here - [exact next step]
         - Save work as-is
    2. Git commit everything immediately (even if incomplete)
    3. Update master_state.json:
         - Mark current module as "incomplete"
         - Add "emergency_stop": true
    4. Create recovery prompt with "EMERGENCY INCOMPLETE" flag
    5. Exit session NOW

  RESUME NEXT SESSION:
    - Read recovery prompt
    - Resume at exact stopping point
    - Complete incomplete work first
  ────────────────────────────────────────────────────────────────

ELSE IF current_context_pct >= 35:
  ────────────────────────────────────────────────────────────────
  FORCE EXIT (Critical threshold reached)
  ────────────────────────────────────────────────────────────────
  ACTION:
    1. IF current_task_status == "in_middle_of_function":
         - Finish ONLY current function (max +50 lines)
         - If function would exceed +50 lines: Stop immediately, mark incomplete
    2. Else: Checkpoint immediately
    3. Git commit all completed work
    4. Update master_state.json with current progress
    5. Create recovery prompt
    6. Exit session

  DO NOT:
    - Start new function
    - Continue to "finish module" if >25% remains
  ────────────────────────────────────────────────────────────────

ELSE IF current_context_pct >= 30:
  ────────────────────────────────────────────────────────────────
  PREPARE EXIT (Warning threshold)
  ────────────────────────────────────────────────────────────────

  IF module_completion_pct >= 90:
    ACTION: Continue to complete module
    RATIONALE: <50 lines remaining, finish it
    CONDITION: Monitor context, abort if hits 35%

  ELSE IF module_completion_pct >= 75:
    ASSESS: How much work remains?

    IF <100 lines remaining AND current_task_status == "at_function_boundary":
      ACTION: Continue to complete module
      RATIONALE: Nearly done, finish it

    ELSE:
      ACTION: Checkpoint now
      RATIONALE: Too much work remains, risky to continue

  ELSE (module_completion_pct < 75):
    ACTION: Checkpoint now
    RATIONALE: Module <75% done, too risky to continue

  ────────────────────────────────────────────────────────────────

ELSE (current_context_pct < 30):
  ────────────────────────────────────────────────────────────────
  SAFE ZONE (No checkpoint pressure)
  ────────────────────────────────────────────────────────────────
  ACTION:
    - Continue normal work
    - Checkpoint only when module complete
    - No need to rush
  ────────────────────────────────────────────────────────────────

OUTPUT:
  - should_checkpoint: boolean
  - checkpoint_reason: string
  - resume_instructions: string (for recovery prompt)
```

---

#### Example Scenarios

**Scenario 1**: Context 28%, Module 95% complete, at function boundary
```
Decision: Continue to complete module
Reason: <30% threshold, nearly done
Action: Finish last function, write tests, commit
```

**Scenario 2**: Context 32%, Module 60% complete, in middle of function
```
Decision: Finish current function, then checkpoint
Reason: 30-35% threshold, <75% complete module
Action: Complete function (~40 lines), checkpoint, exit
```

**Scenario 3**: Context 36%, Module 50% complete, at function boundary
```
Decision: Checkpoint immediately
Reason: ≥35% threshold, must exit
Action: Commit work as-is, mark "in_progress", exit
```

**Scenario 4**: Context 41%, Module 80% complete, in middle of function
```
Decision: Emergency checkpoint
Reason: ≥40% threshold, emergency
Action: Add "INCOMPLETE" comment, commit, mark emergency_stop, exit
```

**Scenario 5**: Context 31%, Module 78% complete, 80 lines remaining
```
Decision: Assess remaining work
Sub-decision: 80 lines > 50 lines → Checkpoint now
Reason: 30-35% threshold, 75-90% complete, but too much work remains
Action: Checkpoint at current function boundary, exit
```

**Scenario 6**: Context 33%, Module 85% complete, 40 lines remaining
```
Decision: Finish module
Reason: 30-35% threshold, >75% complete, <50 lines remaining
Action: Complete module, checkpoint, exit
```

---

#### Checkpoint Execution Steps

**When checkpoint decision == TRUE**:

1. **Finish atomic task** (if safe):
   - If at function boundary: Checkpoint now
   - If mid-function and context <38%: Finish function (max +50 lines)
   - If mid-function and context ≥38%: Add INCOMPLETE comment, stop now

2. **Commit all work**:
   ```bash
   git add .
   git commit -m "[Session N] Module X.Y: [Name] - [COMPLETE/IN_PROGRESS]

   Status: [% complete]
   Context: [N]%
   Reason: [checkpoint_reason]"
   ```

3. **Update state files**:
   - `master_state.json`: Update current_module, modules_complete/in_progress
   - `module_[X.Y]_state.json`: Update status, completion_pct
   - `context_tracking.json`: Record final context percentage

4. **Generate recovery prompt**:
   - Use template from `03_TEMPLATES/recovery_prompt.template`
   - Include exact resume point
   - List completed functions, pending functions
   - Add specific next steps

5. **Display checkpoint box** (per RULE 15)

6. **Display next steps** (per RULE 17)

7. **Exit session** (stop all work)

---

### Exit Procedure (5 min)

**Step 1**: Ensure all work committed
```
git status
If changes: git add . && git commit
```

**Step 2**: Update all state files
```
Update: data/state/master_state.json
Update: data/state/context_tracking.json
Update: data/state/module_[current]_state.json (if in progress)
```

**Step 3**: Create recovery prompt
```
Generate: docs/recovery_prompts/SESSION_[N]_[PHASE].md

Content:
- Git commit: [hash]
- Context: [X]%
- Completed: [list]
- In progress: [current module if any]
- Next steps: [what to do]
- Recovery instructions: [exact prompt for next session]
```

**Step 4**: Display checkpoint box
```
═══════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC)
═══════════════════════════════════════════════════════

✅ All work committed: git [hash]
✅ State files updated: [timestamp]
✅ Context: [N]K tokens ([X]%)
✅ Recovery prompt: SESSION_[N]_[PHASE].md

Session summary:
- Modules completed: [list]
- Tests: [N]/[N] passing
- Next: [next module]

═══════════════════════════════════════════════════════
```

**Step 5**: Display NEXT STEPS (MANDATORY)
```
███████████████████████████████████████████████████████
🎯 NEXT STEPS FOR YOU
███████████████████████████████████████████████████████

When you start next session:

1. Open Claude Code in this directory

2. Paste this prompt:
   ```
   Resume from Session [N].

   Recovery prompt: docs/recovery_prompts/SESSION_[N]_[PHASE].md
   Git: [commit hash]

   Next module: [X.Y]
   Continue implementation per 04_CORE_WORKFLOW.md
   ```

3. Verify state is correct:
   - ✅ Modules complete: [list]
   - ✅ Git clean: no uncommitted changes

4. Continue with Module [X.Y]: [Name]

███████████████████████████████████████████████████████
[END OF RESPONSE - NOTHING AFTER THIS]
███████████████████████████████████████████████████████
```

---

## Context Management During Work

### Real-Time Monitoring

**After every operation**:
```
1. Append to logs/operation_log.txt:
   "[timestamp] [operation_type] [file_path]"

2. Run: scripts/estimate_context.py (auto-update)

3. Check: data/state/context_tracking.json
   - estimated_tokens
   - usage_pct

4. Display in checkpoint (if > 30%)
```

---

### Context-Saving Techniques

**Technique 1: Targeted Reading**
```
Bad:  Read entire IMPLEMENTATION_PLAN.md (30K tokens)
Good: Read only Module 1.1 section (8K tokens)
Savings: 22K tokens (11% of budget)
```

**Technique 2: External Memory**
```
Bad:  Re-explore codebase for same info (15K tokens)
Good: Read data/scratch/exploration_notes.md (2K tokens)
Savings: 13K tokens (6.5% of budget)
```

**Technique 3: Strategic Task Agents**
```
Use Task agents for:
- "Search codebase for pattern X" (exploration)
- "Find all usages of function Y" (grep-heavy)
- "Understand how auth works" (understanding)

Don't use Task agents for:
- Reading specific known files
- Making code changes
- Final decisions
```

**Technique 4: Micro-Modules**
```
Bad:  1,000-line monolithic file (consume 50K tokens to understand)
Good: 4 × 250-line files (consume 12K tokens per file, read only what needed)
```

---

### Emergency Procedures

**If context unexpectedly hits 35%**:
1. Finish current atomic task (current function or test)
2. Commit all work immediately
3. Create emergency recovery prompt
4. Exit session
5. Resume in new session (< 2 min recovery)

**If context hits 40% (force exit)**:
1. Commit everything immediately (even if incomplete)
2. Create recovery prompt with "INCOMPLETE" marker
3. Exit
4. Resume and complete incomplete work

---

## Adaptations for Non-Coding Projects

### Terminology Mapping

| Coding Project | Non-Coding Project |
|----------------|-------------------|
| Module | Section/Chapter |
| Function | Paragraph/Subsection |
| Test | Review/Validation |
| Commit | Draft version |
| Bug fix | Revision |

---

### Research Paper Workflow

**Phase 1: Writing Section (20-30 min)**
```
1. Read: outline for current section
2. Write: section content (1,000-1,500 words)
3. As you write:
   - Track: references in data/scratch/refs_needed.md
   - Note: figures needed in data/scratch/figures_todo.md
4. Update: section_state.json
   - word_count: [N]
   - references_cited: [N]
   - status: "draft"
```

**Phase 2: Reviewing Section (15-20 min)**
```
1. Check: citations are complete
2. Check: section adheres to outline
3. Check: word count within target
4. Run: scripts/check_citations.sh
5. Update: section_state.json
   - status: "reviewed"
```

**Phase 3: Completion (5-10 min)**
```
1. Move: section from drafts/ to sections/
2. Update: master_state.json
   - sections_complete: [list]
3. Git commit:
   "Section [N]: [Title] - COMPLETE

   Word count: [N]
   References: [N]
   Figures: [N]

   Progress: [X]/[Y] sections complete"
```

---

### Book Writing Workflow

**Phase 1: Writing Scene (30-40 min)**
```
1. Read: chapter outline, scene summary
2. Write: scene (~1,000-1,500 words)
3. Track: character appearances, plot points
4. Update: scene_state.json
   - word_count: [N]
   - characters_present: [list]
   - plot_points_addressed: [list]
```

**Phase 2: Consistency Check (10-15 min)**
```
1. Check: character consistency (names, traits, history)
2. Check: plot consistency (timeline, causality)
3. Check: style consistency (voice, tense, POV)
4. Run: scripts/check_consistency.sh
```

**Phase 3: Completion (5 min)**
```
1. Update: chapter_state.json
2. Git commit with scene summary
```

---

## Summary

### Daily Workflow in 3 Steps

**1. Start**:
- Read recovery prompt (if resuming)
- Load state
- Select module/section

**2. Work**:
- Implement in small chunks
- Test/review after each chunk
- Commit when chunk complete
- Monitor context continuously

**3. End**:
- Commit all work
- Update state files
- Create recovery prompt
- Display checkpoint and next steps

**Key**: Never exceed 35% context. Exit gracefully, resume quickly.

---

**Next Steps**:

**For coding**: Start implementing Module 1.1 following this workflow
**For non-coding**: Start writing Section 1 following adaptations
**For scripts**: Implement automation per `06_SCRIPTS_GUIDE.md`

---

**Workflow version**: 3.0
**Last updated**: January 2025
