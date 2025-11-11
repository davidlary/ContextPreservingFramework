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

## Session End Pattern

### When to End Session

**Trigger any of these**:
1. Context usage ≥ 35% (hard limit)
2. Context usage ≥ 30% AND module complete (soft limit)
3. Natural phase boundary (all modules in current phase done)
4. Time elapsed > 2 hours (fatigue factor)

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
