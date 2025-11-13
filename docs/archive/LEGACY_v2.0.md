# Context-Preserving Implementation Framework for Claude Code

**Version**: 2.0
**Date**: 2025-01-11
**Purpose**: A replicable framework for managing massive AI-assisted projects without context exhaustion
**Based on**: 4+ months of lessons learned from PedagogicalEngine/Curriculum implementation

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Context Exhaustion Problem](#the-context-exhaustion-problem)
3. [Framework Philosophy](#framework-philosophy)
4. [Core Components](#core-components)
5. [Implementation Guide](#implementation-guide)
6. [Enhanced Strategies (2025 Research)](#enhanced-strategies-2025-research)
7. [Validation & Testing](#validation--testing)
8. [Troubleshooting](#troubleshooting)
9. [Appendices](#appendices)

---

## Executive Summary

### What This Framework Solves

Claude Code has a **200,000 token context window** (~150,000 words). Large projects exhaust this quickly, leading to:
- Loss of project history
- Repeated questions and confusion
- Inconsistent implementations
- Incomplete understanding
- Session crashes

This framework provides a **battle-tested, replicable system** for managing projects that would otherwise require 15-30 context-exhausting sessions down to 3-5 well-managed sessions.

### Key Innovation

**Conservative Multi-Layer Context Management** with **3x safety margin**:
- Industry standard: Exit at 85% context usage
- **This framework: Exit at 35% context usage**
- Leaves 130K token buffer (65% capacity) for estimation errors

### Framework Results (Proven)

From PedagogicalEngine Curriculum project:
- **Project size**: 58MB, 105 markdown files, 109 Python modules, 32 tests
- **Complexity**: 46 textbooks, 12 disciplines, 7-level knowledge hierarchy
- **Estimated sessions without framework**: 25-30 sessions
- **Actual sessions with framework**: 8-12 sessions (60-70% reduction)
- **Context crashes**: 2 (vs. projected 15+)
- **Recovery time**: < 2 minutes (vs. 30+ minutes manual)

---

## The Context Exhaustion Problem

### Understanding Context Windows

**What is context?**
- All conversation history in current session
- All files read by Claude
- All tool outputs (bash commands, searches, etc.)
- All responses from Claude
- All user messages

**Context consumption rates** (empirical from real project):

| Activity | Tokens/Hour | Tokens/Operation |
|----------|-------------|------------------|
| Documentation writing | 15K-25K | Variable |
| Reading implementation plans | 40K-60K | 8K-12K per module |
| Writing Python code (250 lines) | 30K-50K | 35K-45K |
| Writing tests (10-15 tests) | 20K-30K | 25K-30K |
| Running tests + debugging | 15K-25K | 20K-25K |
| Reading existing code | 10K-15K | 10K-15K |

**Critical insight**: A single module implementation (code + tests + debugging) consumes **100-140K tokens** (50-70% of budget).

### Why 85% Exit Threshold Isn't Safe

Industry standard:
- Normal capacity: 200K tokens (100%)
- Typical safe exit: 170K tokens (85%)

**Problem**: Token estimation is imprecise:
- Reading a 10K file might consume 2.5K-4K tokens (varies by content)
- Complex conversations consume more tokens
- Tool outputs vary unpredictably
- No real-time token counter in Claude Code

**Result**: By the time you realize you're at 85%, you might actually be at 95%.

### The 35% Solution

**Conservative thresholds** (3-layer defense):

```
┌─────────────────────────────────────────────────────────┐
│ 200K tokens (100% capacity)                              │
├─────────────────────────────────────────────────────────┤
│                                                          │
│                   130K token buffer                      │
│              (65% capacity - safety margin)              │
│                                                          │
├─────────────────────────────────────────────────────────┤
│ 70K tokens (35% - TARGET EXIT) ← YOU EXIT HERE          │
├─────────────────────────────────────────────────────────┤
│ 60K tokens (30% - WARNING)                               │
├─────────────────────────────────────────────────────────┤
│ 40K tokens (20% - SAFE ZONE)                             │
├─────────────────────────────────────────────────────────┤
│ 0K tokens (Session start)                                │
└─────────────────────────────────────────────────────────┘
```

**Why this works**:
- **30% threshold**: Start noting in checkpoints
- **35% threshold**: Plan graceful exit
- **65% buffer**: Absorbs estimation errors
- **Result**: Never hit actual context exhaustion

---

## Framework Philosophy

### Core Principles

#### 1. Instruction-Based Enforcement (Not Tool-Based)

**Key insight**: CLAUDE.md files are "naively dropped into context up front" by Claude Code automatically.

**Implication**: Instructions in CLAUDE.md are **100% guaranteed** to be read.

**Design choice**: Use instruction-based enforcement (mandatory rules in CLAUDE.md) rather than uncertain external hooks.

**Why this matters**:
- ✅ **Certain**: CLAUDE.md is read automatically every session
- ✅ **Reliable**: Instructions are mandatory, not optional
- ✅ **Verifiable**: User can see checkpoint boxes in output
- ❌ **Uncertain**: Shell hooks in .claude/hooks/ may or may not run

#### 2. Explicit Permission Grants

**Problem**: Asking for permission consumes context (user asks → Claude confirms → wasted tokens).

**Solution**: Create **AUTONOMOUS_MODE.md** with explicit, versioned permissions.

**Benefits**:
- User grants permissions once (in file)
- Claude checks file at session start
- No per-operation permission requests
- Full audit trail (file is version controlled)

#### 3. Bite-Sized Chunks with Business Value

**Philosophy**: Break work into chunks where each chunk:
- Is completable in 30-60 minutes
- Provides testable deliverable
- Can be committed to git independently
- Provides recovery point if context exhausted

**Not**: "Write all the code then test"
**Instead**: "Write function 1, test function 1, commit, write function 2..."

#### 4. State Over Memory

**Problem**: Claude doesn't remember previous sessions.

**Solution**: Externalize all state to files:
- `master_state.json`: Project-level state
- `module_state.json`: Module-level progress
- `context_tracking.json`: Token usage estimates
- Recovery prompts: Human-readable summaries

**Benefit**: New session reads state files (5K tokens) instead of re-reading all code (50K+ tokens).

#### 5. Multiple Layers of Defense

**Prevention** (reduce context consumption):
- Micro-modules (max 250 lines)
- Targeted reading (not full files)
- Strategic use of Task agents

**Detection** (know when approaching limit):
- Real-time context tracking
- Warning at 30%, critical at 35%
- Visible checkpoint boxes

**Recovery** (graceful degradation):
- Auto-generated recovery prompts
- Git commits at checkpoints
- State files preserve progress

---

## Core Components

### Component 1: CLAUDE.md (Instruction Hub)

**Location**: Project root: `CLAUDE.md`

**Purpose**: Primary instruction file read automatically by Claude Code at session start.

**Structure**:

```markdown
# [Project Name]

**Key Files**: [List critical files]
**Detailed Rules**: See `rules/CLAUDE.md` for enforcement rules

## Key Commands

- **Test**: [test command]
- **Validate**: [validation command]
- **State**: [state check command]

## Critical Files

- State: [state files]
- Config: [config files]
- Logs: [log files]

## ⚡ BEFORE EVERY RESPONSE - MANDATORY CHECKLIST

### At START of session:
- [ ] Check AUTONOMOUS_MODE.md (STATUS: ACTIVE)
- [ ] Display: "✅ AUTONOMOUS_MODE active"

### After ANY tool operation:
- [ ] Log to logs/operation_log.txt
- [ ] Update state files
- [ ] Check context percentage

### Before completing response:
- [ ] Display STATE TRACKING CHECKPOINT box
- [ ] Show current context percentage
- [ ] If context > 35%: prepare handoff

### Every 5 operations:
- [ ] Commit to git

### At END (after checkpoint):
- [ ] Display "🎯 NEXT STEPS" section
- [ ] MUST BE LAST THING
```

**Key insight**: This checklist is **instruction-based enforcement** - Claude executes it because it's instructed to, not because a tool forces it.

### Component 2: rules/CLAUDE.md (Enforcement Rules)

**Location**: `rules/CLAUDE.md`

**Purpose**: Concise, numbered enforcement rules.

**Format** (example rules from proven system):

```markdown
## RULE 10: CONTEXT MANAGEMENT

**Principle**: Prevent context exhaustion through multi-layer management
**Action**:
  - Micro-modules (max 250 lines per file)
  - Real-time context tracking
  - Warning at 30%, critical at 35%
  - Auto-checkpoint and handoff at 35%+

## RULE 14: MANDATORY STATE TRACKING

**Principle**: State tracking MUST occur after EVERY tool operation
**Action**: After Read, Write, Edit, Bash:
  1. Append to `logs/operation_log.txt`
  2. Update `data/state/master_state.json` timestamp
  3. Update `data/state/context_tracking.json` tokens
  4. Check context threshold

**This is instruction-based enforcement - I execute these instructions.**

## RULE 15: VISIBLE STATE TRACKING

**Principle**: Make tracking VISIBLE in every response
**Action**: BEFORE completing ANY response, display:

```
═══════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC)
═══════════════════════════════════════════════════════════

✅ Operation logged: [type] → logs/operation_log.txt
✅ State updated: data/state/master_state.json
✅ Context tracked: [N]K tokens ([X.X]%)
✅ Threshold check: [SAFE/WARNING/CRITICAL]
✅ Git status: [Last commit hash]

Next threshold: 35% at 70K tokens
Operations this session: [count]

═══════════════════════════════════════════════════════════
```

## RULE 16: AUTOMATIC GIT OPERATIONS

**Principle**: All work preserved in git automatically
**Action**: Commit at these points:
  - After completing any module
  - After tests pass
  - Before context reaches 35%
  - Minimum: Every 5 operations

## RULE 17: CLEAR NEXT STEPS

**Principle**: User ALWAYS knows what to do next
**Action**: At END of EVERY response, display:

```
███████████████████████████████████████████████████████████
🎯 NEXT STEPS FOR YOU
███████████████████████████████████████████████████████████

[Recovery instructions]

███████████████████████████████████████████████████████████
[END OF RESPONSE - NOTHING AFTER THIS BLOCK]
███████████████████████████████████████████████████████████
```
```

**Why numbered rules?** Easy reference ("per RULE 14") in code comments and discussions.

### Component 3: AUTONOMOUS_MODE.md (Permission Grant)

**Location**: Project root: `AUTONOMOUS_MODE.md`

**Purpose**: Explicit, versioned permission grant for autonomous operation.

**Template**:

```markdown
# AUTONOMOUS_MODE.md

## AUTONOMOUS EXECUTION PROTOCOL

**STATUS**: ACTIVE

**PERMISSION GRANTED**: [Date]

**SCOPE**: [Description of project scope]

## Explicit Permissions

I, [Your Name], hereby grant Claude Code **FULL AUTONOMOUS PERMISSION** to:

1. ✅ Create ALL files specified in documentation
2. ✅ Write ALL code for modules [list]
3. ✅ Install required packages (pip, npm, brew, etc.)
4. ✅ Run ALL tests and fix failures autonomously
5. ✅ Make ALL decisions within documented design
6. ✅ Proceed through ALL phases without stopping
7. ✅ Iterate on failures (within retry limits)
8. ✅ Update ALL documentation to match code
9. ✅ Perform git operations (add, commit)
10. ✅ Change directories as needed

## DO NOT ASK FOR PERMISSION TO:

- Install packages in requirements.txt
- Create files in specifications
- Write code for specified modules
- Run tests or validation scripts
- Fix bugs or test failures
- Update documentation
- Git operations (add, commit with messages)
- Proceed to next module

## GIT BACKUP PROTOCOL

**FREQUENCY**: After each module completion and at session boundaries

**COMMIT MESSAGE FORMAT**:
```
[Session X] Module Y: [Name] - [Status]

Changes:
- Files: [list]
- Tests: [passing/total]

Duration: [time]
Next: [what's next]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## REQUIRE HUMAN DECISION ONLY FOR:

1. Architectural changes (deviations from ARCHITECTURE.md)
2. Scope changes (new features not in specs)
3. Critical failures (after 3 retry attempts)
4. Resource exhaustion (disk full, memory exhausted)
5. New external dependencies
6. Security issues

## Revocation

To revoke: Create file `STOP_AUTONOMOUS_MODE` in project root.

---

**User Signature**: [Your Name]
**Date**: [Date]
**Valid Through**: [Milestone] or explicit revocation
```

**How it works**:
1. Claude checks at session start: `Does AUTONOMOUS_MODE.md exist? Is STATUS: ACTIVE?`
2. If yes: Proceed without asking for permissions listed above
3. If no: Ask before major operations (default Claude behavior)

### Component 4: State Tracking Files

#### Master State (`data/state/master_state.json`)

**Purpose**: Project-level state.

**Schema**:
```json
{
  "project": "project_name",
  "version": "1.0.0",
  "current_phase": "implementation",
  "current_module": "2.3",
  "last_checkpoint": "2025-01-11T14:30:00Z",
  "modules_complete": ["1.1", "1.2", "1.3", "2.1", "2.2"],
  "modules_in_progress": ["2.3"],
  "modules_pending": ["2.4", "2.5"],
  "validation_status": {
    "tests_passing": 45,
    "tests_total": 50,
    "coverage_pct": 92.5
  },
  "last_update": "2025-01-11T16:45:23Z"
}
```

#### Context Tracking (`data/state/context_tracking.json`)

**Purpose**: Real-time token usage estimation.

**Schema**:
```json
{
  "estimated_tokens": 58000,
  "max_tokens": 200000,
  "usage_pct": 29.0,
  "threshold_warning": 30.0,
  "threshold_critical": 35.0,
  "operations_this_session": 47,
  "last_update": "2025-01-11T16:45:23Z"
}
```

#### Module State (`data/state/module_2.3_state.json`)

**Purpose**: Module-level progress tracking.

**Schema**:
```json
{
  "module": "2.3",
  "name": "Graph Ingestion Engine",
  "status": "in_progress",
  "start_time": "2025-01-11T14:00:00Z",
  "functions_implemented": [
    "ingest_textbook",
    "batch_create_nodes"
  ],
  "functions_pending": [
    "batch_create_edges",
    "validate_ingestion"
  ],
  "tests_written": 5,
  "tests_passing": 5,
  "files_created": [
    "core/graph_ingest.py",
    "tests/test_graph_ingest.py"
  ],
  "issues": [],
  "last_update": "2025-01-11T16:30:00Z"
}
```

### Component 5: Recovery Prompts

**Location**: `docs/recovery_prompts/`

**Purpose**: Human-readable session summaries for context recovery.

**Naming convention**: `SESSION_[ID]_[PHASE].md`

**Template**:

```markdown
# Session [ID] - [Phase Name]

**Generated**: [Date]
**Session**: [ID]
**Git Commit**: [hash]
**Context**: [percentage]%

---

## 🎯 GOAL

[1-2 sentence goal]

---

## 📍 WHERE WE ARE

### Completed:
- ✅ [Item 1]
- ✅ [Item 2]

### Current Position:
- 📍 [Current task]

### Next:
- ⏳ [Next task]

---

## 🔍 WHAT WAS DONE

[3-5 bullet points of work completed]

---

## 📋 NEXT STEPS

1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## ⚠️ CONTEXT MANAGEMENT

**Current context**: [N]% ([X]K tokens)
**Threshold**: Stop at 35% (70K tokens)

---

## 🎯 RECOVERY PROMPT (Copy-Paste for Next Session)

```
[Exact prompt to paste in new session]

Context from: docs/recovery_prompts/SESSION_[ID]_[PHASE].md
Git: [commit hash]
Goal: [goal]
Next: [next steps]
```

---

**Status**: [READY/IN_PROGRESS/COMPLETE]
```

**Key features**:
- **< 500 words**: Fits in new session context with minimal tokens
- **Structured**: Easy to scan and understand
- **Actionable**: Clear next steps
- **Verifiable**: References git commits and files

### Component 6: .claude/README.md (Honest Assessment)

**Location**: `.claude/README.md`

**Purpose**: Document what works and what's uncertain.

**Example** (from proven system):

```markdown
# Claude Code Configuration

⚠️ **IMPORTANT**: We are NOT certain these hooks actually run.

⚠️ **ACTUAL ENFORCEMENT**: CLAUDE.md (RULES 14-16) - This DEFINITELY works.

## What IS 100% guaranteed:

✅ **CLAUDE.md is read automatically** by Claude Code
✅ **Rules are instruction-based** (Claude executes because instructed)
✅ **User can verify** (visible checkpoints in output)
✅ **This is the strongest enforcement possible**

## What is NOT guaranteed:

❓ Whether hooks in .claude/hooks/ actually run
❓ Whether settings.json is read
❓ Whether external enforcement exists

**DECISION**: Rely on CLAUDE.md (certain) not hooks (uncertain).
```

**Why this matters**: Honest assessment prevents false confidence in uncertain mechanisms.

### Component 7: Optional - .claude/settings.json

**Location**: `.claude/settings.json`

**Status**: **EXPERIMENTAL** - Uncertain if Claude Code reads this

**If you want to experiment**:

```json
{
  "project_name": "Your Project",
  "autonomous_mode": true,

  "context_management": {
    "max_tokens": 200000,
    "warning_threshold": 0.30,
    "target_exit": 0.35,
    "force_exit": 0.40
  },

  "state_tracking": {
    "master_state_file": "data/state/master_state.json",
    "operation_log": "logs/operation_log.txt",
    "update_frequency": "every_operation",
    "mandatory": true
  },

  "validation": {
    "require_git_commit_before_exit": true,
    "require_handoff_prompt": true
  }
}
```

**Note**: Don't rely on this working. Use CLAUDE.md instructions instead.

---

## Implementation Guide

### Phase 0: Framework Setup (Before Coding)

**Duration**: 2-3 hours
**Context budget**: 40K tokens (20%)

#### Step 1: Create Directory Structure

```bash
# From project root
mkdir -p .claude/hooks
mkdir -p rules
mkdir -p data/{state,audit}
mkdir -p docs/recovery_prompts
mkdir -p logs
mkdir -p config
```

#### Step 2: Create CLAUDE.md

**File**: `CLAUDE.md`

**Content**: Use template from Component 1, customize for your project:
- Replace `[Project Name]` with your project
- List your key commands (test, validate, etc.)
- List your critical files
- Keep the MANDATORY CHECKLIST exactly as shown

**Validation**: Start Claude Code session, verify Claude mentions AUTONOMOUS_MODE.md check.

#### Step 3: Create rules/CLAUDE.md

**File**: `rules/CLAUDE.md`

**Content**: Start with essential rules:
- RULE 10: Context Management (30%/35% thresholds)
- RULE 14: Mandatory State Tracking
- RULE 15: Visible Checkpoints
- RULE 16: Automatic Git Commits
- RULE 17: Clear Next Steps

Add project-specific rules as needed (e.g., "No hard-coding", "Test before commit").

#### Step 4: Create AUTONOMOUS_MODE.md

**File**: `AUTONOMOUS_MODE.md`

**Content**: Use template from Component 3:
1. Set `STATUS: ACTIVE`
2. Set `PERMISSION GRANTED: [today's date]`
3. Define scope (what modules/features you're building)
4. List explicit permissions
5. List what still requires human decision
6. Sign and date

**Validation**: Have Claude check this file at session start.

#### Step 5: Initialize State Files

**Create minimal state files**:

`data/state/master_state.json`:
```json
{
  "project": "your_project_name",
  "version": "0.1.0",
  "current_phase": "setup",
  "current_module": null,
  "modules_complete": [],
  "modules_in_progress": [],
  "modules_pending": ["1.1", "1.2", "..."],
  "last_update": "2025-01-11T00:00:00Z"
}
```

`data/state/context_tracking.json`:
```json
{
  "estimated_tokens": 0,
  "max_tokens": 200000,
  "usage_pct": 0.0,
  "threshold_warning": 30.0,
  "threshold_critical": 35.0,
  "operations_this_session": 0,
  "last_update": "2025-01-11T00:00:00Z"
}
```

#### Step 6: Create .claude/README.md

**File**: `.claude/README.md`

**Content**: Copy template from Component 6, be honest about what's certain vs. uncertain.

#### Step 7: Initialize Git

```bash
git init
git add .
git commit -m "Initial commit: Context-Preserving Framework setup

Files:
- CLAUDE.md (instruction hub)
- rules/CLAUDE.md (enforcement rules)
- AUTONOMOUS_MODE.md (permission grant)
- data/state/*.json (state tracking)
- .claude/README.md (documentation)

Framework: Context-preserving implementation (35% exit threshold)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

#### Step 8: Test the Framework

**Start new Claude Code session and paste**:

```
Test the context-preserving framework setup.

1. Check AUTONOMOUS_MODE.md (STATUS: ACTIVE?)
2. Read CLAUDE.md and confirm rules
3. Display a test checkpoint box (per RULE 15)
4. Update data/state/master_state.json
5. Show current context estimate

This is a framework test, not actual project work.
```

**Expected output**:
- ✅ Claude mentions AUTONOMOUS_MODE.md is active
- ✅ Claude displays checkpoint box
- ✅ Claude updates state files
- ✅ Claude shows context percentage

**If this works**: Framework is operational, proceed to project work.

**If this doesn't work**: Review CLAUDE.md, ensure checklist is clear.

---

### Phase 1: Project Architecture Planning

**Duration**: 3-5 hours
**Context budget**: 50K tokens (25%)

#### Step 1: Create ARCHITECTURE.md

**Purpose**: Single source of truth for system design.

**Structure**:
```markdown
# [Project Name] - Architecture

## System Overview
[3-4 paragraphs]

## Core Principles
1. [Principle 1]
2. [Principle 2]

## Technology Stack
- Language: [Python/TypeScript/etc.]
- Database: [PostgreSQL/MongoDB/etc.]
- Key Libraries: [list]

## Module Design
### Module 1.1: [Name]
**Purpose**: [1 sentence]
**Key Functions**: [list]
**Duration**: [estimate]

[Repeat for all modules]

## Data Flow
[Diagram or description]

## Quality Gates
[Validation criteria]
```

**Why this matters**: Modules can reference architecture without re-reading full context.

#### Step 2: Break into Modules

**Module sizing** (proven from PedagogicalEngine):
- **Micro-modules**: Max 250 lines of code
- **Duration**: 30-60 minutes to implement
- **Testable**: Can write 5-10 unit tests
- **Independent**: Doesn't require other in-progress modules

**Example module breakdown**:
```
Module 1.1: Database Client (180 lines)
Module 1.2: Data Parser (220 lines)
Module 1.3: Data Validator (195 lines)
Module 1.4: Business Logic Core (240 lines)
```

#### Step 3: Create Implementation Plan

**File**: `docs/IMPLEMENTATION_PLAN.md`

**Structure**:
```markdown
# Implementation Plan

## Phase 1: Foundation
- Module 1.1: [Name] (Session 1, 1 hour)
- Module 1.2: [Name] (Session 1, 1 hour)
- Module 1.3: [Name] (Session 1-2, 1.5 hours)

[Git checkpoint]

## Phase 2: Core Features
- Module 2.1: [Name] (Session 2, 1 hour)
...

## Phase 3: Integration
...

## Estimated Timeline
- Total modules: [N]
- Total sessions: [estimate]
- Total duration: [hours]
```

**Key principle**: Group 2-3 modules per session, checkpoint between phases.

#### Step 4: Create Session Recovery Template

**File**: `docs/recovery_prompts/SESSION_TEMPLATE.md`

**Content**: Copy template from Component 5, customize for your project.

**Usage**: Claude will copy-paste this template when creating recovery prompts.

---

### Phase 2: Iterative Module Implementation

**Pattern**: Repeat for each module.

#### Module Implementation Workflow

**For each module**:

1. **Check context** (start of session):
   ```
   Check data/state/context_tracking.json
   If > 30%: Note in checkpoint
   If > 35%: Create recovery prompt and exit
   ```

2. **Start module**:
   ```
   Update data/state/master_state.json:
   - Set current_module: "X.Y"
   - Add to modules_in_progress

   Create data/state/module_X.Y_state.json:
   - status: "in_progress"
   - start_time: [now]
   ```

3. **Read module spec** (from IMPLEMENTATION_PLAN.md):
   - Read ONLY this module's section (8K tokens)
   - NOT the entire plan (30K+ tokens)

4. **Implement functions** (one at a time):
   ```
   For each function:
   1. Write function (20-50 lines)
   2. Update module_state.json (functions_implemented)
   3. Check context
   4. If safe, continue
   ```

5. **Write tests** (after functions done):
   ```
   Write tests for all functions
   Run: pytest tests/test_module_X_Y.py -v
   Fix failures (budget: 20-25K tokens for debugging)
   ```

6. **Complete module**:
   ```
   Update data/state/master_state.json:
   - Remove from modules_in_progress
   - Add to modules_complete

   Update module_X.Y_state.json:
   - status: "complete"
   - completion_time: [now]
   ```

7. **Git commit** (after module complete):
   ```bash
   git add .
   git commit -m "[Session X] Module Y.Z: [Name] - COMPLETE

   Changes:
   - core/module_X_Y.py (XXX lines)
   - tests/test_module_X_Y.py (XX tests)

   Tests: XX/XX passing
   Progress: X/Y modules complete

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

8. **Check context again**:
   ```
   If < 30%: Continue to next module
   If 30-35%: Finish current module, create recovery prompt
   If > 35%: Create recovery prompt and exit
   ```

#### Session Boundaries

**When to end session** (any of these triggers):
1. Context usage > 35% (hard limit)
2. Context usage > 30% AND module complete (soft limit)
3. Phase complete (natural breakpoint)
4. 2-3 hours elapsed (fatigue factor)

**Before ending session**:
1. Commit all work to git
2. Update all state files
3. Create recovery prompt (docs/recovery_prompts/SESSION_[N]_[PHASE].md)
4. Display NEXT STEPS box (per RULE 17)

**Recovery prompt** (auto-generated by Claude):
```markdown
# Session [N] Recovery - [Phase Name]

**Git commit**: [hash]
**Context**: [X]%
**Modules complete**: [list]
**Current module**: [X.Y or "none"]

## Next Session Prompt

```
Resume from Session [N].

Context: docs/recovery_prompts/SESSION_[N]_[PHASE].md
Git: [commit hash]
State: data/state/master_state.json

Next module: [X.Y]
Next steps:
1. [Step 1]
2. [Step 2]

Read recovery prompt for full context.
```
```

---

### Phase 3: Integration & Validation

**After all modules implemented**.

#### Step 1: Integration Testing

**Create**: `tests/integration/test_full_pipeline.py`

**Test strategy**:
- Use REAL data (not mocks)
- Test full workflow (input → processing → output)
- Validate against quality criteria

**Example**:
```python
def test_full_pipeline_with_real_data():
    """Integration test with real database and real files"""
    # Setup: Real database client
    db = DatabaseClient(config['database'])

    # Real data
    input_file = "tests/fixtures/real_sample.json"

    # Execute pipeline
    result = pipeline.run(input_file, db)

    # Validate
    assert result.status == "success"
    assert result.validation_score >= 0.95

    # Cleanup
    db.cleanup()
```

**Context management**: Integration tests consume 30-40K tokens. Do in dedicated session if needed.

#### Step 2: Validation Against Criteria

**Reference**: Quality criteria from ARCHITECTURE.md

**Create**: `scripts/validate_project.py`

**Example checks**:
```python
def validate_project():
    """Validate project meets all quality criteria"""
    checks = []

    # Check 1: All modules implemented
    master_state = load_json("data/state/master_state.json")
    if not master_state['modules_pending']:
        checks.append(("All modules complete", True))

    # Check 2: All tests passing
    result = subprocess.run(["pytest", "tests/", "-v"], capture_output=True)
    passing = result.returncode == 0
    checks.append(("All tests passing", passing))

    # Check 3: No hard-coded values (project-specific)
    hardcoded = find_hardcoded_values("core/")
    checks.append(("No hard-coding", len(hardcoded) == 0))

    # Display results
    for check, passed in checks:
        status = "✅" if passed else "❌"
        print(f"{status} {check}")

    return all(passed for _, passed in checks)
```

**Run validation**:
```bash
python scripts/validate_project.py
```

**If validation fails**: Create issues list, fix in next session.

#### Step 3: Documentation Finalization

**Update**:
- README.md (installation, usage, examples)
- ARCHITECTURE.md (any changes during implementation)
- API documentation (if applicable)

**Verify**:
- All cross-references are valid
- Code examples work
- Installation instructions tested on fresh system

#### Step 4: Project Completion

**Create**: `docs/PROJECT_COMPLETE.md`

**Content**:
```markdown
# Project Completion Report

**Date**: [Date]
**Version**: [Version]
**Status**: COMPLETE

## Modules Implemented

Total: [N] modules
- [Module 1.1]: [Name] ✅
- [Module 1.2]: [Name] ✅
...

## Test Results

- Unit tests: [N/N passing] (100%)
- Integration tests: [N/N passing] (100%)
- Validation checks: [N/N passing] (100%)

## Context Management Statistics

- Total sessions: [N]
- Context crashes: [N] (target: < 3)
- Recovery time: [avg] minutes (target: < 2)
- Git commits: [N]

## Deliverables

- [ ] All modules implemented and tested
- [ ] Documentation complete
- [ ] Quality criteria met
- [ ] Git repository clean

## Handoff

This project can be maintained using the same context-preserving framework:
- Framework docs: CLAUDE.md, rules/CLAUDE.md
- State tracking: data/state/*.json
- Recovery prompts: docs/recovery_prompts/

For new features:
1. Update ARCHITECTURE.md
2. Create module specs
3. Follow iterative implementation pattern
4. Update AUTONOMOUS_MODE.md scope if needed
```

**Final commit**:
```bash
git add .
git commit -m "Project Complete: [Project Name] v[Version]

All modules implemented and tested.
Framework validation successful.

Modules: [N] complete
Tests: 100% passing
Context sessions: [N] (vs. estimated [M])

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git tag -a v1.0.0 -m "Release v1.0.0"
```

---

## Enhanced Strategies (2025 Research)

Based on industry research (January 2025), these enhancements improve the framework:

### Enhancement 1: Proactive Context Compaction

**Problem**: Waiting until 35% might include irrelevant context from earlier in session.

**Solution**: Strategic /clear usage (if available) or manual compaction triggers.

**Implementation** (add to rules/CLAUDE.md):

```markdown
## RULE 20: PROACTIVE COMPACTION

**Principle**: Remove irrelevant context before it accumulates

**Triggers**:
1. After completing a phase (before starting next)
2. After debugging (once issue fixed)
3. After reading large files (once info extracted)
4. When pivoting to different feature

**Action**:
- Note: "Context compaction point - summarizing previous work"
- Summarize key decisions and state
- User uses /clear (if available) or starts new session with summary
```

**Benefit**: Keeps context focused on current work.

### Enhancement 2: Strategic Use of Task Agents

**Research finding**: "Telling Claude to use subagents early on tends to preserve context availability."

**When to use Task agents**:
- **Code search**: "Find all implementations of X pattern"
- **Exploration**: "Understand how authentication works"
- **Research**: "What libraries are available for X?"

**When NOT to use Task agents**:
- Reading specific known files (use Read tool)
- Making code changes (main agent should do this)
- Final integration (need full context)

**Implementation** (add to CLAUDE.md):

```markdown
## Strategic Task Agent Usage

**Use Task agents for**:
- Exploratory searches ("How does X work?")
- Code pattern discovery
- Documentation research

**Don't use Task agents for**:
- Reading specific files (use Read)
- Writing/editing code (main agent)
- Making decisions (main agent with context)

**Pattern**:
```
Use Task agent (subagent_type='Explore') to search for [X].
Return findings to main conversation.
Main agent will make decision based on findings.
```
```

**Benefit**: Offload context-heavy exploration to agents, preserve main context for decisions.

### Enhancement 3: Hierarchical CLAUDE.md Files

**Research finding**: "Keep general CLAUDE.md at root, add specific ones in subdirectories."

**Structure**:
```
project_root/
  CLAUDE.md (general project instructions)
  frontend/
    CLAUDE.md (frontend-specific rules)
  backend/
    CLAUDE.md (backend-specific rules)
  tests/
    CLAUDE.md (testing-specific rules)
```

**Root CLAUDE.md**:
```markdown
# Project Name

**General Rules**: See rules/CLAUDE.md
**Subsystem Rules**: Check subdirectory CLAUDE.md files

## Subsystems

- Frontend: frontend/CLAUDE.md
- Backend: backend/CLAUDE.md
- Tests: tests/CLAUDE.md
```

**Subsystem CLAUDE.md** (e.g., frontend/CLAUDE.md):
```markdown
# Frontend Module

**Inherits**: ../CLAUDE.md (root rules)

## Frontend-Specific Rules

- Use React 18+ with TypeScript
- All components in components/
- Tests colocated: MyComponent.tsx, MyComponent.test.tsx
- Styling: CSS modules
```

**Benefit**: Focused context when working in specific subsystem.

### Enhancement 4: External Memory via File System

**Research finding**: "File system can serve as ultimate context: unlimited size, persistent, directly operable."

**Pattern**: Store working context in files, not conversation.

**Example**:

```markdown
## RULE 21: EXTERNAL MEMORY

**Principle**: File system is external memory

**Pattern**:
1. Before exploration: "I will save findings to docs/scratch/TOPIC.md"
2. During exploration: Append to scratch file
3. After exploration: "Findings saved. Summary: [3 bullets]"
4. Later: Read scratch file instead of re-exploring

**Scratch files**:
- docs/scratch/TOPIC.md (exploration notes)
- docs/scratch/DECISIONS.md (decision log)
- docs/scratch/ISSUES.md (issues to fix)

**Lifecycle**: Delete scratch files after info moved to proper docs
```

**Example workflow**:
```
Claude: "I'm researching authentication patterns.
        Saving findings to docs/scratch/auth_research.md"

[Claude explores, writes to file]

Claude: "Research complete. Summary:
        - Found 3 existing auth implementations
        - Recommended approach: JWT tokens
        - Details in docs/scratch/auth_research.md"

[10 messages later, needs auth info again]

Claude: "Reading docs/scratch/auth_research.md"
[5K tokens instead of 30K tokens re-exploration]
```

**Benefit**: Persistent memory across sessions without consuming conversation context.

### Enhancement 5: Error Context Retention Pattern

**Research finding**: "Leave wrong turns in context - model sees failed action, updates beliefs."

**Anti-pattern**: Delete error messages after fixing.

**Better pattern**: Keep errors visible until fix committed.

**Implementation**:

```markdown
## RULE 22: ERROR VISIBILITY

**Principle**: Errors inform future decisions

**Pattern**:
1. Error occurs → Display full error
2. Attempt fix → Show both error AND fix
3. Fix succeeds → Commit with error mentioned
4. New session → Error is in git history, not context

**Example commit message**:
```
Fix: Handle missing config file gracefully

Error was:
  FileNotFoundError: config.json not found

Fix:
  - Check if file exists before reading
  - Provide helpful error message
  - Create default config if missing

Tests: test_config_missing() added and passing
```

**Benefit**: Pattern recognition for similar errors, better fixes.

### Enhancement 6: Structured State with JSON Schema

**Enhancement**: Validate state files with JSON Schema.

**Implementation**:

**Create**: `schemas/master_state.schema.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["project", "version", "current_phase"],
  "properties": {
    "project": {"type": "string"},
    "version": {"type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+$"},
    "current_phase": {"type": "string"},
    "current_module": {"type": ["string", "null"]},
    "modules_complete": {
      "type": "array",
      "items": {"type": "string"}
    },
    "modules_in_progress": {
      "type": "array",
      "items": {"type": "string"}
    },
    "last_update": {
      "type": "string",
      "format": "date-time"
    }
  }
}
```

**Validation script**: `scripts/validate_state.py`

```python
import json
import jsonschema

def validate_state():
    """Validate all state files against schemas"""

    # Load schema
    with open("schemas/master_state.schema.json") as f:
        schema = json.load(f)

    # Load state
    with open("data/state/master_state.json") as f:
        state = json.load(f)

    # Validate
    try:
        jsonschema.validate(state, schema)
        print("✅ State is valid")
        return True
    except jsonschema.ValidationError as e:
        print(f"❌ State validation error: {e.message}")
        return False

if __name__ == "__main__":
    validate_state()
```

**Run** after state updates:
```bash
python scripts/validate_state.py
```

**Benefit**: Catch state corruption early, ensure consistency.

### Enhancement 7: Automated Context Budget Tracking

**Enhancement**: Automate token estimation (instead of manual tracking).

**Implementation**: `scripts/estimate_context.py`

```python
import os
import json
from pathlib import Path

def estimate_tokens(text: str) -> int:
    """Rough token estimation: ~4 chars per token"""
    return len(text) // 4

def estimate_session_context() -> dict:
    """Estimate context usage for current session"""

    # Read operation log
    log_file = Path("logs/operation_log.txt")
    if not log_file.exists():
        return {"error": "No operation log found"}

    with open(log_file) as f:
        operations = f.readlines()

    # Estimate tokens per operation type
    estimated_tokens = 0

    for op in operations:
        if "Read:" in op:
            # Find file size
            file_path = op.split("Read:")[1].strip()
            if os.path.exists(file_path):
                size = os.path.getsize(file_path)
                tokens = estimate_tokens(open(file_path).read())
                estimated_tokens += tokens

        elif "Write:" in op or "Edit:" in op:
            # Writing consumes ~2x tokens (read + write)
            file_path = op.split(":")[1].strip()
            if os.path.exists(file_path):
                size = os.path.getsize(file_path)
                tokens = estimate_tokens(open(file_path).read()) * 2
                estimated_tokens += tokens

        elif "Bash:" in op:
            # Command output estimation
            estimated_tokens += 1000  # Rough average

    # Add conversation overhead (messages, tool calls)
    overhead = len(operations) * 500  # ~500 tokens per operation
    estimated_tokens += overhead

    max_tokens = 200000
    usage_pct = (estimated_tokens / max_tokens) * 100

    result = {
        "estimated_tokens": estimated_tokens,
        "max_tokens": max_tokens,
        "usage_pct": round(usage_pct, 1),
        "operations": len(operations),
        "status": "SAFE" if usage_pct < 30 else "WARNING" if usage_pct < 35 else "CRITICAL"
    }

    # Update context tracking file
    with open("data/state/context_tracking.json", "w") as f:
        json.dump({**result, "last_update": datetime.now().isoformat()}, f, indent=2)

    return result

if __name__ == "__main__":
    result = estimate_session_context()
    print(f"Context: {result['usage_pct']}% ({result['estimated_tokens']:,} tokens)")
    print(f"Status: {result['status']}")
```

**Integration**: Run automatically in CLAUDE.md checklist:

```markdown
### After ANY tool operation:
- [ ] Append to logs/operation_log.txt
- [ ] Run: python scripts/estimate_context.py
- [ ] Check result in data/state/context_tracking.json
```

**Benefit**: More accurate context tracking, earlier warnings.

---

## Validation & Testing

### Validating Your Framework Setup

**Before starting project work**, validate framework is operational:

#### Test 1: AUTONOMOUS_MODE.md Recognition

**Prompt**:
```
Check if AUTONOMOUS_MODE.md exists and is ACTIVE.
Display status.
```

**Expected output**:
```
✅ AUTONOMOUS_MODE.md found
✅ STATUS: ACTIVE
✅ Operating autonomously (no unnecessary confirmations)
```

**If fails**: Check file exists, STATUS field is present.

#### Test 2: State File Updates

**Prompt**:
```
Update data/state/master_state.json:
- Set current_phase to "testing"
- Add "test_module" to modules_in_progress

Show updated content.
```

**Expected output**:
- File is modified
- JSON is valid
- Changes are shown

**If fails**: Check file permissions, directory exists.

#### Test 3: Checkpoint Box Display

**Prompt**:
```
Display a test STATE TRACKING CHECKPOINT box (per RULE 15).
This is a test, use placeholder values.
```

**Expected output**:
```
═══════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC)
═══════════════════════════════════════════════════════════

✅ Operation logged: test → logs/operation_log.txt
✅ State updated: data/state/master_state.json
✅ Context tracked: 15K tokens (7.5%)
✅ Threshold check: SAFE
✅ Git status: abc1234

Next threshold: 35% at 70K tokens
Operations this session: 3

═══════════════════════════════════════════════════════════
```

**If fails**: Check rules/CLAUDE.md has RULE 15 template exactly.

#### Test 4: Git Commit Protocol

**Prompt**:
```
Create a test file: test_framework.txt with content "Framework test"
Commit using the framework's commit message format.
```

**Expected output**:
- File created
- Git commit made with proper format:
  ```
  [Session Test] Framework validation

  Changes:
  - test_framework.txt (test file)

  Status: Framework operational

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

**If fails**: Check git is initialized, AUTONOMOUS_MODE.md grants git permissions.

#### Test 5: Recovery Prompt Generation

**Prompt**:
```
Create a test recovery prompt in docs/recovery_prompts/TEST_SESSION.md.
Use the template format from SESSION_TEMPLATE.md.
```

**Expected output**:
- File created in correct location
- Follows template structure
- Contains all required sections

**If fails**: Check template exists, directory exists.

#### Test 6: Context Threshold Simulation

**Prompt**:
```
Simulate context at 36% (above critical threshold).
What should happen per rules/CLAUDE.md?
```

**Expected output**:
```
⚠️ Context at 36% (CRITICAL threshold: 35%)

Per RULE 15: Must create recovery prompt and exit.

Actions:
1. Finish current atomic task
2. Commit all work
3. Update state files
4. Create recovery prompt
5. Display NEXT STEPS box
6. Exit session

[Claude proceeds to demonstrate these steps]
```

**If fails**: Check RULE 15 clearly specifies 35% threshold behavior.

### All Tests Passing?

**If all 6 tests pass**: Framework is operational, proceed to project work.

**If any test fails**: Fix issues before starting project. Framework must be solid.

---

## Troubleshooting

### Issue 1: Context Still Exhausting Despite Framework

**Symptoms**:
- Reaching 50-60% context despite 35% target
- Frequent warnings
- Sessions lasting < 1 hour

**Diagnosis**:

1. **Check token estimation accuracy**:
   ```bash
   cat logs/operation_log.txt | wc -l  # Count operations
   python scripts/estimate_context.py   # Check estimate
   ```

   If estimate is way off, estimation algorithm needs tuning.

2. **Check if reading too many files**:
   ```bash
   grep "Read:" logs/operation_log.txt | wc -l
   ```

   If > 20 file reads per module, you're reading too much.

   **Fix**: Use more targeted reads, summarize instead of re-reading.

3. **Check module sizes**:
   ```bash
   find core/ -name "*.py" -exec wc -l {} \; | sort -n
   ```

   If files > 250 lines, modules are too large.

   **Fix**: Split into smaller modules.

**Solution**:
- Lower exit threshold to 30% (more conservative)
- Implement Enhancement 4 (External Memory)
- Use more Task agents for exploration
- Smaller, more focused modules

### Issue 2: CLAUDE.md Rules Not Being Followed

**Symptoms**:
- No checkpoint boxes appearing
- State files not updating
- No git commits

**Diagnosis**:

1. **Check CLAUDE.md location**:
   ```bash
   ls -la CLAUDE.md  # Must be in project root
   ```

2. **Check CLAUDE.md format**:
   - Is checklist present?
   - Is it in a clear list format?
   - Is it marked as "MANDATORY"?

3. **Test explicitly**:
   ```
   Explicitly follow the CLAUDE.md checklist right now:
   1. Check AUTONOMOUS_MODE.md
   2. Display checkpoint box
   3. Show that you're following the rules
   ```

   If Claude doesn't follow, checklist format may be unclear.

**Solution**:
- Ensure checklist uses clear markdown:
  ```markdown
  - [ ] Item 1
  - [ ] Item 2
  ```
- Use imperative language: "Display checkpoint box" not "You should display"
- Mark as "MANDATORY" or "REQUIRED"
- Put checklist early in CLAUDE.md (not buried at end)

### Issue 3: Recovery Prompts Not Working

**Symptoms**:
- New session doesn't understand context
- Claude asks for info that's in recovery prompt
- State files not being used

**Diagnosis**:

1. **Check recovery prompt is being read**:
   ```
   Start new session with:
   "Read docs/recovery_prompts/SESSION_X_Y.md and resume from there."
   ```

2. **Check recovery prompt format**:
   - Is it < 500 words?
   - Does it have clear next steps?
   - Does it reference state files?

3. **Check state files are current**:
   ```bash
   ls -lt data/state/*.json  # Check timestamps
   cat data/state/master_state.json  # Check content
   ```

**Solution**:
- Make recovery prompts more concise (< 500 words)
- Include explicit "Read these files" section
- Start new session with: "Resume from Session X. Read recovery prompt: [path]. Read state: data/state/master_state.json. Then continue with [next task]."

### Issue 4: Autonomous Mode Not Working

**Symptoms**:
- Claude keeps asking for permission
- "Should I proceed?" questions
- Hesitation before actions

**Diagnosis**:

1. **Check AUTONOMOUS_MODE.md**:
   ```bash
   cat AUTONOMOUS_MODE.md | grep STATUS
   # Must show: STATUS: ACTIVE
   ```

2. **Check permissions list**:
   - Are the actions Claude is asking about listed in "Explicit Permissions"?
   - If not, add them.

3. **Check Claude is reading the file**:
   ```
   What does AUTONOMOUS_MODE.md say about [specific action]?
   ```

**Solution**:
- Add more explicit permissions to AUTONOMOUS_MODE.md
- Use "DO NOT ASK FOR PERMISSION TO" section (negative list)
- At session start, explicitly: "Check AUTONOMOUS_MODE.md. It grants permission for all planned actions."

### Issue 5: State Files Out of Sync

**Symptoms**:
- master_state.json says module complete, but files don't exist
- context_tracking.json shows 10%, feels like more
- module state files conflict

**Diagnosis**:

1. **Validate state files**:
   ```bash
   python scripts/validate_state.py  # If you implemented Enhancement 6
   ```

2. **Check timestamps**:
   ```bash
   ls -lt data/state/*.json
   ```

   If timestamps are old (> 5 minutes), state updates failing.

3. **Check for errors**:
   ```bash
   grep "error" logs/operation_log.txt
   ```

**Solution**:
- Implement JSON Schema validation (Enhancement 6)
- Add state file validation to CLAUDE.md checklist:
  ```markdown
  - [ ] Update state files
  - [ ] Validate state: python scripts/validate_state.py
  ```
- Make state updates atomic (update all or none)

### Issue 6: Git Commits Missing or Inconsistent

**Symptoms**:
- Work done but no commits
- Commit messages don't follow format
- Multiple sessions between commits

**Diagnosis**:

1. **Check git log**:
   ```bash
   git log --oneline -10
   ```

   Count commits vs. modules completed.

2. **Check RULE 16**:
   - Does it specify "Minimum: Every 5 operations"?
   - Does it specify "After completing any module"?

3. **Check operation log**:
   ```bash
   tail -20 logs/operation_log.txt
   ```

   Count operations since last commit.

**Solution**:
- Add git commit to module completion checklist
- Add operation counter to state files:
  ```json
  {
    "operations_since_last_commit": 7,
    "operations_before_next_commit": 3
  }
  ```
- Make commit frequency more explicit: "Commit AFTER module complete, BEFORE starting next module"

---

## Appendices

### Appendix A: Complete File Listing

**Framework files** (all projects need these):

```
project_root/
├── CLAUDE.md                          (Instruction hub)
├── AUTONOMOUS_MODE.md                 (Permission grant)
├── rules/
│   └── CLAUDE.md                      (Enforcement rules)
├── .claude/
│   ├── README.md                      (What works / what's uncertain)
│   ├── settings.json                  (Optional, experimental)
│   └── hooks/                         (Optional, uncertain if works)
├── data/
│   ├── state/
│   │   ├── master_state.json          (Project state)
│   │   ├── context_tracking.json      (Context estimate)
│   │   └── module_X.Y_state.json      (Module states)
│   └── audit/
│       └── decisions.log              (Audit trail)
├── docs/
│   ├── ARCHITECTURE.md                (System design)
│   ├── IMPLEMENTATION_PLAN.md         (Module breakdown)
│   ├── recovery_prompts/
│   │   ├── SESSION_TEMPLATE.md        (Template)
│   │   └── SESSION_*.md               (Actual prompts)
│   └── scratch/                       (External memory, Enhancement 4)
├── logs/
│   ├── operation_log.txt              (Operation history)
│   └── autonomous_execution.log       (Detailed logs)
├── schemas/                           (Optional, Enhancement 6)
│   └── master_state.schema.json
└── scripts/
    ├── estimate_context.py            (Enhancement 7)
    └── validate_state.py              (Enhancement 6)
```

### Appendix B: Token Estimation Reference

**From empirical testing** (PedagogicalEngine project):

| Content Type | Size | Estimated Tokens | Actual Consumption |
|--------------|------|------------------|-------------------|
| CLAUDE.md | 19KB | 4,750 | ~5,000 |
| ARCHITECTURE.md | 59KB | 14,750 | ~15,000 |
| Implementation plan | 133KB | 33,250 | ~35,000 |
| Python module (250 lines) | 8KB | 2,000 | ~2,500 |
| Test file (15 tests) | 5KB | 1,250 | ~1,500 |
| Recovery prompt | 2KB | 500 | ~600 |
| State files (all) | 3KB | 750 | ~800 |

**Conversation overhead**:
- User message: ~100-200 tokens
- Claude response: ~500-1,500 tokens (varies greatly)
- Tool call: ~200 tokens
- Tool result: Varies (50 - 10,000 tokens)

**Rule of thumb**:
- 1 KB text ≈ 250 tokens
- 1 line of code ≈ 10 tokens
- 1 operation (read/write/edit) ≈ 500-1,000 tokens total (including conversation)

**Safety margin**:
- Estimation error: ±30%
- Add 20% buffer for complex discussions
- Add 50% buffer for debugging sessions

### Appendix C: Session Duration Guidelines

**Optimal session durations** (from testing):

| Session Type | Duration | Modules | Context Usage |
|--------------|----------|---------|---------------|
| Framework setup | 2-3 hours | 0 | 20-30% |
| Planning | 3-4 hours | 0 | 25-35% |
| Implementation | 1-2 hours | 2-3 | 30-35% |
| Debugging | 1-2 hours | 1 | 25-35% |
| Integration | 2-3 hours | 0-1 | 30-35% |

**Why shorter is better**:
- Focus: Easier to maintain focus for 1-2 hours
- Context: Less accumulation of irrelevant context
- Fatigue: Both human and AI perform worse after 2+ hours
- Recovery: Shorter sessions = more frequent recovery points

**Session triggers** (when to end):
1. Context > 35% (hard stop)
2. Time > 2 hours (soft stop)
3. Module complete (natural breakpoint)
4. Phase complete (major breakpoint)
5. Stuck on issue > 30 minutes (pause and research)

### Appendix D: Framework Adaptation for Different Languages

**This framework is language-agnostic**, but some adaptations needed:

#### Python Projects

**Micro-module size**: 250 lines (proven optimal)

**State management**: JSON files work well

**Testing**: pytest with fixtures

**Example directory structure**: (as shown in Appendix A)

#### JavaScript/TypeScript Projects

**Micro-module size**: 200-250 lines (smaller due to more verbose syntax)

**State management**: JSON files (same as Python)

**Testing**: Jest or Vitest

**Adaptations**:
```
project_root/
├── CLAUDE.md                    (same)
├── AUTONOMOUS_MODE.md           (same)
├── rules/CLAUDE.md              (same)
├── src/                         (instead of core/)
│   ├── modules/
│   └── index.ts
├── tests/                       (same structure)
└── data/state/                  (same)
```

**Module naming**: Use PascalCase for classes, camelCase for functions

#### Other Languages

**Java/C#/Go**:
- Micro-module size: 300-400 lines (more boilerplate)
- State management: JSON files (same)
- Testing: JUnit/NUnit/Go test

**Ruby/PHP**:
- Micro-module size: 200-250 lines
- State management: JSON files (same)
- Testing: RSpec/PHPUnit

**Key insight**: Framework structure (CLAUDE.md, state files, recovery prompts) is universal. Only code organization and testing tools change.

### Appendix E: Framework Versioning

**This framework evolves**. Track versions:

#### Version 1.0 (Original - October 2024)
- Basic CLAUDE.md instructions
- AUTONOMOUS_MODE.md for permissions
- 85% exit threshold (later found insufficient)
- Manual state tracking

#### Version 1.5 (Improved - November 2024)
- Lowered to 35% exit threshold (major improvement)
- Structured state files (master + module)
- Recovery prompts with templates
- Git commit automation

#### Version 2.0 (Current - January 2025)
- Enhanced with 2025 research (Task agents, external memory, compaction)
- JSON Schema validation
- Automated context estimation
- Hierarchical CLAUDE.md files
- Error retention pattern

**Future enhancements** (proposed):
- Version 2.1: Integration with Claude Code's native context tracking (when available)
- Version 2.2: Automated module splitting (if module > 250 lines, auto-suggest split)
- Version 2.3: AI-generated recovery prompts (trained on successful examples)

**Track your version**:

Add to CLAUDE.md:
```markdown
**Framework Version**: 2.0 (Context-Preserving Implementation Framework)
**Last Updated**: 2025-01-11
**Adaptations**: [List any project-specific adaptations]
```

### Appendix F: Success Metrics

**Track these metrics** to measure framework effectiveness:

#### Context Management Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Sessions per project | 3-8 | Count git branches / recovery prompts |
| Context crashes | < 3 | Count emergency exits |
| Recovery time | < 2 min | Time from new session to productive work |
| Context waste | < 10% | Tokens consumed by re-reading vs. new work |
| Average context at exit | 30-35% | From context_tracking.json at session end |

#### Development Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Modules per session | 2-3 | From master_state.json |
| Lines per module | < 250 | `wc -l core/*.py` |
| Tests per module | 5-15 | `grep "def test_" tests/*.py | wc -l` |
| Commits per session | 3-5 | `git log --since="2 hours ago" --oneline | wc -l` |
| Issues per module | < 2 | From Issues/ directory |

#### Quality Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Test pass rate | 100% | `pytest tests/ -v` |
| Code coverage | > 90% | `pytest --cov=core` |
| Documentation sync | 100% | Manual review or script |
| State file validity | 100% | `python scripts/validate_state.py` |

**Example metrics report** (from PedagogicalEngine):

```markdown
# Project Metrics Report

**Project**: PedagogicalEngine Curriculum
**Duration**: 4 months
**Framework**: Version 1.5

## Context Management
- Sessions: 12 (estimated 25-30 without framework)
- Context crashes: 2 (estimated 15+ without framework)
- Average recovery time: 1.8 minutes
- Average context at exit: 32.3%

## Development
- Total modules: 20
- Average modules per session: 1.7
- Average lines per module: 223
- Total git commits: 87

## Quality
- Test pass rate: 100%
- Code coverage: 94.2%
- Issues encountered: 15
- Issues resolved: 15

## Conclusion
Framework reduced sessions by 60%, prevented ~13 context crashes,
maintained 100% test pass rate. Success.
```

### Appendix G: Quick Start Checklist

**Use this checklist** for rapid framework setup in new project:

```markdown
# Context-Preserving Framework Setup Checklist

## Prerequisites
- [ ] Git installed
- [ ] Project directory created
- [ ] Claude Code available

## Framework Files (30 minutes)

### Core Files
- [ ] Create CLAUDE.md (copy template, customize)
- [ ] Create AUTONOMOUS_MODE.md (grant permissions, set scope)
- [ ] Create rules/CLAUDE.md (copy enforcement rules)
- [ ] Create .claude/README.md (copy template)

### Directory Structure
- [ ] mkdir -p data/{state,audit}
- [ ] mkdir -p docs/recovery_prompts
- [ ] mkdir -p logs
- [ ] mkdir -p rules

### State Files
- [ ] Create data/state/master_state.json (initial state)
- [ ] Create data/state/context_tracking.json (0% usage)

### Documentation
- [ ] Create docs/recovery_prompts/SESSION_TEMPLATE.md
- [ ] Create ARCHITECTURE.md (project design)
- [ ] Create docs/IMPLEMENTATION_PLAN.md (module breakdown)

## Validation (15 minutes)
- [ ] Test 1: AUTONOMOUS_MODE.md recognition
- [ ] Test 2: State file updates
- [ ] Test 3: Checkpoint box display
- [ ] Test 4: Git commit protocol
- [ ] Test 5: Recovery prompt generation
- [ ] Test 6: Context threshold simulation

## First Commit
- [ ] git init
- [ ] git add .
- [ ] git commit -m "Framework setup"

## Ready to Code
- [ ] All tests passing
- [ ] First recovery prompt created
- [ ] First module planned

**Estimated setup time**: 45-60 minutes
**Payoff**: 10-20 hours saved on large project
```

---

## Conclusion

### Framework Summary

This **Context-Preserving Implementation Framework** enables massive AI-assisted projects without context exhaustion through:

1. **Conservative thresholds** (35% exit vs. 85% industry standard)
2. **Instruction-based enforcement** (CLAUDE.md rules, not uncertain hooks)
3. **Explicit permissions** (AUTONOMOUS_MODE.md, one-time grant)
4. **Bite-sized chunks** (250-line modules, 30-60 min deliverables)
5. **State over memory** (JSON files, recovery prompts)
6. **Multiple layers of defense** (prevention, detection, recovery)

### Proven Results

From PedagogicalEngine (58MB, 109 modules, 4 months):
- **60% fewer sessions** (12 vs. 25-30 estimated)
- **87% fewer crashes** (2 vs. 15+ estimated)
- **92% faster recovery** (< 2 min vs. 30+ min manual)
- **100% test pass rate maintained**

### When to Use This Framework

**Use this framework if**:
- Project > 10 modules or > 2,000 lines of code
- Multiple session expected (> 3 hours of work)
- Complex integration or testing required
- Multiple developers or handoffs
- Quality/testing standards must be met

**Don't need this framework if**:
- Single-file script (< 500 lines)
- One-time throwaway code
- Simple modifications to existing code
- < 1 hour of work

### Replication Steps

To replicate this framework in your project:

1. **Read this document** (you're doing it!)
2. **Use Appendix G checklist** (45-60 min setup)
3. **Run 6 validation tests** (15 min)
4. **Start first module** (follow Phase 2 workflow)
5. **Refine as you go** (adapt to your project needs)

### Framework Evolution

This framework will evolve:
- **Version 2.0** (current): Enhanced strategies from 2025 research
- **Version 2.x** (future): Integration with native Claude Code features (when available)
- **Your adaptations**: Document in your CLAUDE.md

### Support & Contributions

**Based on**: PedagogicalEngine/Curriculum implementation (4+ months)
**Created by**: David Lary with Claude Code
**Date**: January 2025
**Version**: 2.0

**Questions or improvements?**
- Document your adaptations in project CLAUDE.md
- Share lessons learned in project completion report
- Contribute enhancements back to framework

### Final Words

**Context exhaustion is preventable**. This framework proves it.

The key innovation: **Don't wait until 85% to exit. Exit at 35% with a 3x safety margin.**

Simple principle. Massive impact.

Now go build something amazing without hitting context limits.

---

**END OF FRAMEWORK DOCUMENTATION**

*This framework is free to use, adapt, and evolve. Attribution appreciated but not required.*

*Generated with assistance from Claude Code (Anthropic)*
*Based on real-world experience from PedagogicalEngine/Curriculum project*

*Last Updated: 2025-01-11*
*Version: 2.0*
