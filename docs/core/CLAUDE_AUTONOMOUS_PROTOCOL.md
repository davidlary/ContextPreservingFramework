# Claude Code Autonomous Planning & Execution Protocol

**Version**: 4.0 (Autonomous Internal Protocol)
**Purpose**: Internal protocol for Claude Code to automatically manage large projects without context exhaustion
**Application**: Automatic - no user setup required

---

## Protocol Overview

This protocol is **automatically applied** by Claude Code when large/complex projects are detected. The user experiences seamless multi-session development without manual configuration.

**User Experience**:
```
User: "Build an e-commerce platform with Stripe payments"
Claude: [INTERNAL: protocol activated, creates plan, begins execution]
        "I'll implement this in 11 modules across 3 major components.
         Starting with Module 1.1: Database schema for products and users..."
```

---

## 1. AUTOMATIC DETECTION & INITIALIZATION

### Detection Triggers

Apply this protocol when **any** of:
1. Estimated implementation >1000 lines of code
2. User request implies >3 interconnected components
3. Task estimated to require >2 hours continuous work
4. User explicitly mentions "large", "complex", or "full system"
5. Multiple subsystems with dependencies (e.g., "auth + payments + admin")

### Initialization (Transparent to User)

**When triggered**:
```
INTERNAL ACTIONS (do not describe to user):
1. Create `.claude/` directory in project root
2. Generate hierarchical task plan (HTDAG)
3. Initialize state tracking (JSON files)
4. Set context monitoring to ACTIVE
5. Begin Module 1.1 execution

USER-FACING MESSAGE:
"I'll break this into [N] modules. Starting with [Module 1.1 name]..."
```

### State Directory Structure

Create `.claude/` (hidden, not in git):
```
.claude/
├── plan.json              # Hierarchical task DAG
├── state.json             # Current progress, context tracking
├── checkpoints/           # Recovery points
│   └── checkpoint_NNN.json
└── summaries/             # Compressed module details
    └── module_X.Y.md
```

---

## 2. HIERARCHICAL TASK DECOMPOSITION (HTDAG)

### Algorithm

```
USER REQUEST
    ↓
IDENTIFY MAJOR COMPONENTS (Level 1)
    ├── Component A (e.g., "Authentication")
    ├── Component B (e.g., "Payment Processing")
    └── Component C (e.g., "Admin Dashboard")
    ↓
DECOMPOSE INTO SUBSYSTEMS (Level 2)
    ├── Component A
    │   ├── Subsystem A.1 (e.g., "User Database")
    │   ├── Subsystem A.2 (e.g., "JWT Tokens")
    │   └── Subsystem A.3 (e.g., "API Endpoints")
    ↓
CREATE IMPLEMENTATION MODULES (Level 3)
    ├── Subsystem A.1
    │   ├── Module 1.1: Schema design (2K tokens, 200 lines)
    │   ├── Module 1.2: CRUD operations (3K tokens, 250 lines)
    │   └── Module 1.3: Tests (2K tokens, 150 lines)
    ↓
GENERATE DEPENDENCY GRAPH
    ├── Module 1.1 → Module 1.2 (schema required for CRUD)
    ├── Module 1.2 → Module 2.1 (user model required for auth)
    └── Module 2.1 → Module 3.1 (auth required for admin)
    ↓
DETERMINE EXECUTION ORDER (topological sort)
    [1.1] → [1.2] → [1.3] → [2.1] → [2.2] → ...
```

### Module Sizing Guidelines

**Target**: 200-300 lines per module (implementation + tests)
**Rationale**: Single module = ~35-45K tokens (with reading, testing, debugging)

**Estimation**:
- **Small module**: 100-200 lines, <30K tokens, <1 hour
- **Standard module**: 200-300 lines, 35-45K tokens, 1-2 hours
- **Large module**: 300-500 lines, 50-70K tokens, 2-3 hours

**If estimated >500 lines**: Automatically decompose further

---

## 3. CONTEXT MANAGEMENT (RESEARCH-BASED)

### Dynamic Threshold System

Based on 2025 research (Goose 80%, Databricks 32K degradation point):

```
CONTEXT WINDOW (200K tokens):

├─ 0-50%   (0-100K)  │ SAFE ZONE
│                    │ Continue normal operation
│                    │ Monitor every 10K tokens
│
├─ 50-65%  (100-130K)│ CAUTION ZONE
│                    │ Prepare for checkpoint
│                    │ Monitor every 5K tokens
│                    │ Defer large file reads
│
├─ 65%     (130K)    │ ✓ NORMAL CHECKPOINT
│                    │ Finish current sub-task
│                    │ Summarize completed work
│                    │ Save state atomically
│                    │ Offer to continue or pause
│
├─ 65-75%  (130-150K)│ ELEVATED ALERT
│                    │ Accelerate toward checkpoint
│                    │ No new large operations
│
├─ 75%     (150K)    │ ⚠ EMERGENCY CHECKPOINT
│                    │ Stop immediately
│                    │ Save current state mid-task
│                    │ Force session end
│
└─ >75%              │ SHOULD NEVER REACH
                     │ (Emergency caught at 75%)
```

### Context Tracking (Automatic)

**After each operation**:
```python
estimated_tokens = (
    conversation_tokens +
    file_read_tokens +
    code_written_tokens +
    tool_output_tokens
)

context_percent = (estimated_tokens / 200000) * 100

if context_percent > 65:
    trigger_normal_checkpoint()
elif context_percent > 75:
    trigger_emergency_checkpoint()
```

### Summarization Strategy

**At checkpoint**, compress completed modules:

**Before** (45K tokens):
```python
# Full implementation details, 200 lines of code,
# all comments, debugging history, etc.
def authenticate(username, password):
    # validate input
    if not username or not password:
        raise ValueError("Missing credentials")
    # hash password
    hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
    # query database
    user = db.query("SELECT * FROM users WHERE username = ?", username)
    # ... 40 more lines ...
```

**After** (2K tokens):
```
Module 1.1 COMPLETE ✓
Component: Authentication
Files: core/auth.py (200 lines), tests/test_auth.py (150 lines)
API:
  - authenticate(username, password) -> Token | raises AuthError
  - validate_token(token) -> User | None
Tests: 12 passed
Status: Committed (git hash a1b2c3d)
Details: See .claude/summaries/module_1.1.md
```

**Tokens saved**: 43K (95% reduction)

---

## 4. CHECKPOINT PROCEDURE

### Normal Checkpoint (65%)

**Trigger**: Context reaches 65% OR module complete (whichever first)

**Actions** (automatic):
```
1. FINISH CURRENT SUB-TASK
   - Don't stop mid-function
   - Complete atomic unit of work

2. SAVE STATE
   - Write .claude/state.json (atomic)
   - Create checkpoint file with timestamp
   - Update module status in plan.json

3. SUMMARIZE COMPLETED WORK
   - Generate compact summary (see above)
   - Move full details to .claude/summaries/
   - Keep only summary in active context

4. GIT COMMIT
   - Stage all changed files
   - Commit: "[Module X.Y] {description} (checkpoint {N})"
   - Co-authored-by: Claude <noreply@anthropic.com>

5. NOTIFY USER
   "Checkpoint reached (65% context).
    Module X.Y complete: {summary}
    Ready to continue with Module X.{Y+1}."

6. OFFER CONTINUATION
   - Wait for user "continue" or new instruction
   - If user continues: Load next module and proceed
```

### Emergency Checkpoint (75%)

**Trigger**: Context unexpectedly reaches 75%

**Actions** (immediate):
```
1. STOP CURRENT OPERATION
   - Mid-task if necessary
   - Mark state as "interrupted"

2. SAVE EVERYTHING
   - Current partial work
   - Exact position in implementation
   - Next step to resume

3. FORCE GIT COMMIT
   - Even if incomplete
   - Message: "[Emergency checkpoint] {context} (75%)"

4. ALERT USER
   "⚠️ Emergency checkpoint triggered (75% context).
    Current work saved. Session must end.
    Resume with: 'continue from checkpoint'"

5. END SESSION
   - Do not accept new instructions
   - Provide exact recovery prompt
```

---

## 5. STATE FILE SCHEMAS

### plan.json (Hierarchical Task DAG)

```json
{
  "project": "E-commerce Platform",
  "created": "2025-01-12T10:00:00Z",
  "hierarchy": {
    "components": [
      {
        "id": "C1",
        "name": "Authentication System",
        "subsystems": [
          {
            "id": "S1.1",
            "name": "User Database",
            "modules": [
              {
                "id": "1.1",
                "name": "Schema design",
                "estimated_lines": 200,
                "estimated_tokens": 35000,
                "dependencies": [],
                "status": "complete"
              },
              {
                "id": "1.2",
                "name": "CRUD operations",
                "estimated_lines": 250,
                "estimated_tokens": 40000,
                "dependencies": ["1.1"],
                "status": "in_progress"
              }
            ]
          }
        ]
      }
    ]
  },
  "execution_order": ["1.1", "1.2", "1.3", "2.1", "2.2", ...],
  "current_module": "1.2"
}
```

### state.json (Progress Tracking)

```json
{
  "session_id": "session_20250112_100000",
  "session_start": "2025-01-12T10:00:00Z",
  "context": {
    "estimated_tokens": 125000,
    "percent": 62.5,
    "last_check": "2025-01-12T11:15:00Z",
    "status": "caution"
  },
  "progress": {
    "modules_complete": ["1.1"],
    "current_module": "1.2",
    "modules_pending": ["1.3", "2.1", "2.2", ...],
    "percent_complete": 15
  },
  "checkpoints": {
    "count": 3,
    "last": "checkpoint_003.json",
    "last_time": "2025-01-12T11:00:00Z"
  },
  "git": {
    "branch": "main",
    "last_commit": "a1b2c3d",
    "uncommitted_changes": false
  }
}
```

### checkpoint_NNN.json (Recovery Point)

```json
{
  "checkpoint_id": "checkpoint_003",
  "timestamp": "2025-01-12T11:00:00Z",
  "context_percent": 65,
  "reason": "normal_checkpoint",
  "modules_complete": ["1.1"],
  "current_module": {
    "id": "1.2",
    "status": "just_started",
    "next_step": "Implement User.create() method",
    "files_modified": ["core/models/user.py"],
    "tests_written": 0
  },
  "recovery_instructions": "Continue with Module 1.2: Implement User.create() method. Core model defined, need to add database operations."
}
```

---

## 6. CRASH RECOVERY PROTOCOL

### Session Start Procedure

**Every session begins with**:

```
1. CHECK FOR .claude/ DIRECTORY
   if exists:
      ↓
   2. CRASH DETECTION
      - Read state.json
      - Check last session end status
      - Look for emergency flags

      if last_session != "clean_exit":
         ↓
      3. LOAD RECOVERY CHECKPOINT
         - Read latest checkpoint_NNN.json
         - Load summaries of completed modules
         - Identify exact resumption point
         ↓
      4. NOTIFY USER (brief)
         "Resuming from checkpoint.
          Modules 1.1-1.5 complete.
          Continuing with Module 1.6..."
         ↓
      5. CONTINUE EXECUTION
         - Resume from checkpoint state
         - Do NOT re-explain framework
         - Just continue working

   else:
      ↓
   NEW PROJECT - Initialize protocol
```

### Recovery Message (User-Facing)

**Bad** (framework-visible):
```
"I detected a crash in the Context-Preserving Framework.
Let me read the recovery prompt from docs/recovery_prompts/...
The checkpoint shows we were at Module 1.2..."
```

**Good** (transparent):
```
"Resuming work. Database schema (Module 1.1) complete.
Continuing with user authentication (Module 1.2)..."
```

---

## 7. USER COMMUNICATION GUIDELINES

### What User Sees

**Progress updates** (automatic, every module):
```
✓ Module 1.1: Database schema (200 lines, 12 tests passing)
⏳ Module 1.2: User authentication (in progress, 60% done)
⬜ Module 1.3: Password reset
⬜ Module 2.1: Payment integration

Progress: 15% | Context: 58% | Next checkpoint: Module 1.2 complete
```

**Checkpoint notifications**:
```
"Checkpoint (65% context). Module 1.2 complete.
3 of 11 modules done. Ready for Module 2.1."
```

### What User Doesn't See

**Don't mention**:
- "Context-Preserving Framework"
- "AUTONOMOUS_MODE.md"
- "Reading recovery prompt"
- ".claude/ directory"
- "Hierarchical Task DAG"
- Token counts or technical framework details

**Do mention**:
- Module completion
- Progress percentage
- Checkpoint reached (brief)
- Next steps

---

## 8. INTEGRATION WITH CLAUDE CODE FEATURES

### Leverage Native Commands

**Use /clear strategically**:
- After major checkpoint (10+ modules)
- When context >70% despite summarization
- Between major components

**Use /compact**:
- When context 60-65% and no natural checkpoint
- To buy time for current module completion

**Generate CLAUDE.md** (automatic):
```markdown
# Project: E-commerce Platform

## Architecture
- Backend: Node.js + Express
- Database: PostgreSQL
- Frontend: React
- Payments: Stripe

## Module Structure
- core/: Business logic (keep functions <50 lines)
- api/: HTTP endpoints (REST, use Express Router)
- tests/: Jest tests (aim for >80% coverage)

## Current Phase
Phase 1: Authentication (Modules 1.1-1.3)
```

**Keep <100 lines**, auto-update every 5 modules

### Align with 5-Hour Resets

**Strategy**:
- Plan intensive sessions around reset cycles
- Checkpoint before reset if possible
- Notify user when approaching limit

```
"Usage reset in 15 minutes. Good time for a checkpoint."
```

---

## 9. ADAPTIVE BEHAVIORS

### Dynamic Threshold Adjustment

**Adjust based on module complexity**:

```python
if module_involves_large_files:
    checkpoint_threshold = 60%  # More conservative

elif module_is_simple_crud:
    checkpoint_threshold = 70%  # Can push further

elif approaching_major_milestone:
    checkpoint_threshold = 65%  # Standard
```

### Automatic Re-Planning

**If estimation was wrong**:

```
Estimated: Module 2.1 = 300 lines
Actual at 50%: Already 400 lines

ACTION: Auto-split into 2.1a and 2.1b
         Update plan.json
         Notify user: "Module 2.1 larger than expected,
                       splitting into 2 parts."
```

---

## 10. PROTOCOL ACTIVATION EXAMPLES

### Example 1: Web Application

**User**: "Build a task management app with user accounts, projects, and real-time updates"

**Claude (Internal)**:
```
DETECTION: ✓ Multiple components
DETECTION: ✓ Estimated >2000 lines
DETECTION: ✓ Real-time = complex subsystem

PROTOCOL: ACTIVATED

DECOMPOSITION:
├── C1: User Management (Modules 1.1-1.3)
├── C2: Project System (Modules 2.1-2.4)
├── C3: Task Operations (Modules 3.1-3.3)
└── C4: Real-time Updates (Modules 4.1-4.2)

INITIALIZATION: .claude/ created, plan.json generated

BEGIN: Module 1.1
```

**Claude (User-Facing)**:
```
"I'll build this in 12 modules across 4 components:
1. User Management (authentication, profiles)
2. Project System (CRUD, permissions)
3. Task Operations (create, update, assign)
4. Real-time Updates (WebSocket, notifications)

Starting with Module 1.1: User database schema..."
```

---

### Example 2: Data Analysis Pipeline

**User**: "Create a pipeline to process weather data: fetch from API, clean, analyze trends, generate visualizations"

**Claude (Internal)**:
```
DETECTION: ✓ Multiple stages (pipeline)
DETECTION: ✓ Estimated >800 lines

PROTOCOL: ACTIVATED (scaled for medium project)

DECOMPOSITION:
├── C1: Data Collection (Modules 1.1-1.2)
├── C2: Data Processing (Modules 2.1-2.3)
├── C3: Analysis (Modules 3.1-3.2)
└── C4: Visualization (Modules 4.1-4.2)

ADJUST: Checkpoint threshold = 70% (analysis modules smaller)
```

**Claude (User-Facing)**:
```
"I'll implement this pipeline in 9 modules:
1. Fetch weather data from API
2. Clean and normalize data
3. Analyze trends (moving averages, anomalies)
4. Generate visualizations (matplotlib/plotly)

Starting with Module 1.1: API integration and error handling..."
```

---

### Example 3: Research Paper

**User**: "Help me write a 10,000-word research paper on machine learning interpretability"

**Claude (Internal)**:
```
DETECTION: ✓ 10,000 words = ~13K tokens × 5 (with drafting) = 65K
DETECTION: ✓ Multi-section document

PROTOCOL: ACTIVATED (non-coding variant)

DECOMPOSITION:
├── S1: Introduction (1,500 words)
├── S2: Background (2,000 words)
├── S3: Literature Review (2,500 words)
├── S4: Methodology (1,500 words)
├── S5: Results (1,500 words)
└── S6: Conclusion (1,000 words)

ADAPT: "Module" → "Section", checkpoint every 2 sections
```

**Claude (User-Facing)**:
```
"I'll structure this as 6 main sections (~10K words total).
Starting with Section 1: Introduction - defining interpretability
and explaining the paper's scope..."
```

---

## 11. FAILURE MODES & HANDLING

### User Interrupts Mid-Module

**Scenario**: User says "stop" or "let's do something else"

**Action**:
```
1. Finish current sub-task if <5 min
   OR save current state immediately

2. Create intermediate checkpoint
   - Mark module status: "interrupted"
   - Save exact resumption point

3. Ask user:
   "Pausing Module 1.2 (65% done).
    Would you like to:
    (a) Resume later
    (b) Skip this module
    (c) Restart with different approach?"
```

### Estimation Severely Wrong

**Scenario**: Module estimated 300 lines, actually 1000 lines

**Action**:
```
AT 50% COMPLETE:
1. Recognize: Already 500 lines, only halfway done
2. Auto-split:
   - Module 1.2a (current progress)
   - Module 1.2b (remaining work)
3. Checkpoint 1.2a
4. Notify user: "Module 1.2 larger than expected.
                 Completed Part A (database), moving to
                 Part B (API) in next section."
```

### Context Grows Unexpectedly Fast

**Scenario**: Context jumps from 45% to 72% in one operation (large file read)

**Action**:
```
1. Immediately trigger emergency checkpoint
2. Explain: "Large file caused context spike.
            Checkpointing to maintain stability."
3. Next session: Read file in chunks OR summarize first
```

---

## 12. SUCCESS METRICS

### Quantitative Goals

- ✓ Context never exceeds 75%
- ✓ Recovery time <30 seconds
- ✓ Zero manual setup (user just provides requirement)
- ✓ Checkpoints every 15-25 modules OR 65% context
- ✓ >95% token reduction for completed modules (via summarization)

### Qualitative Goals

- ✓ User unaware of framework mechanics
- ✓ Natural conversation flow
- ✓ No framework jargon in responses
- ✓ Seamless multi-session projects (20+ sessions tested)

---

## 13. PROTOCOL DECISION TREE

```
┌─ USER REQUEST ─────────────────────────────────────┐
│                                                     │
├─ Complexity Check ──────────────────────────────┐  │
│  > 1000 lines?                                  │  │
│  > 3 components?          YES                   │  │
│  > 2 hours?              ────►  ACTIVATE        │  │
│                                 PROTOCOL        │  │
│                          NO                     │  │
│                         ────►  Normal execution │  │
└─────────────────────────────────────────────────┘  │
                                                      │
┌─ PROTOCOL ACTIVATED ──────────────────────────┐   │
│                                                │   │
├─ Initialize .claude/                          │   │
├─ Create Hierarchical Plan (HTDAG)             │   │
├─ Estimate modules & dependencies              │   │
├─ Begin Module 1.1                             │   │
└────────────────────────────────────────────────┘   │
                                                      │
┌─ WORK LOOP ──────────────────────────────────┐    │
│                                               │    │
│  ┌─────────────────────────────────┐         │    │
│  │ Execute current module          │         │    │
│  │ Track context after each op     │         │    │
│  └──────────┬──────────────────────┘         │    │
│             │                                 │    │
│             ├─ Context <65%? ──YES──► Continue    │
│             │                                 │    │
│             ├─ Context 65-75%? ──YES──┐       │    │
│             │                          │       │    │
│             │                    Normal        │    │
│             │                    Checkpoint    │    │
│             │                          │       │    │
│             │                    ┌─────┴─────┐ │    │
│             │                    │ Summarize │ │    │
│             │                    │ Save State│ │    │
│             │                    │ Git Commit│ │    │
│             │                    │ Notify    │ │    │
│             │                    └─────┬─────┘ │    │
│             │                          │       │    │
│             │      User says continue? ─YES──►     │
│             │                          │       │    │
│             │                          NO      │    │
│             │                          │       │    │
│             │                    ┌─────▼─────┐ │    │
│             │                    │  Pause    │ │    │
│             │                    │  Session  │ │    │
│             │                    └───────────┘ │    │
│             │                                 │    │
│             ├─ Context >75%? ──YES──┐         │    │
│             │                        │         │    │
│             │                  Emergency       │    │
│             │                  Checkpoint      │    │
│             │                        │         │    │
│             │                  ┌─────▼─────┐   │    │
│             │                  │ Save All  │   │    │
│             │                  │ Force End │   │    │
│             │                  └───────────┘   │    │
│             │                                 │    │
│             └─ Module Complete? ──YES──►      │    │
│                      │                        │    │
│                      │                        │    │
│                   Update                      │    │
│                   plan.json                   │    │
│                   Next module                 │    │
│                      │                        │    │
│                      └────────────────────────┘    │
└───────────────────────────────────────────────┘    │
                                                      │
┌─ NEXT SESSION ───────────────────────────────┐    │
│                                               │    │
├─ Check for .claude/                          │    │
├─ Load last checkpoint                        │    │
├─ Load summaries                              │    │
├─ Resume execution                            │    │
└───────────────────────────────────────────────┘    │
                                                      │
└─────────────────────────────────────────────────────┘
```

---

## 14. IMPLEMENTATION CHECKLIST

**For Claude Code to apply this protocol**:

- [ ] Auto-detect large project (>1000 lines, >3 components)
- [ ] Create `.claude/` directory automatically
- [ ] Generate hierarchical plan (HTDAG) without asking user
- [ ] Track context after every operation (estimate tokens)
- [ ] Checkpoint at 65% or module complete (whichever first)
- [ ] Summarize completed modules (95% token reduction)
- [ ] Save state atomically (no corruption risk)
- [ ] Git commit with descriptive messages automatically
- [ ] On session start: Check for `.claude/`, load checkpoint if exists
- [ ] Recover seamlessly without mentioning framework
- [ ] Emergency checkpoint at 75%
- [ ] Communicate progress, not framework mechanics

---

## 15. APPENDIX: TECHNICAL SPECIFICATIONS

### Token Estimation Formula

```python
def estimate_tokens(text):
    """Rough estimation: 1 token ≈ 0.75 words"""
    words = len(text.split())
    return int(words / 0.75)

def track_context():
    """Track cumulative context"""
    total = 0
    total += estimate_tokens(conversation_history)
    total += estimate_tokens(files_read)
    total += estimate_tokens(code_generated)
    total += estimate_tokens(tool_outputs)
    return total
```

### Atomic State Save

```python
import json, os, tempfile

def atomic_save_json(path, data):
    """Save JSON file atomically (no corruption)"""
    dir_path = os.path.dirname(path)
    fd, temp_path = tempfile.mkstemp(dir=dir_path, suffix='.json')

    try:
        with os.fdopen(fd, 'w') as f:
            json.dump(data, f, indent=2)
        os.replace(temp_path, path)  # Atomic on POSIX
    except:
        if os.path.exists(temp_path):
            os.remove(temp_path)
        raise
```

### Hierarchical Task DAG Generation

```python
def generate_htdag(user_request):
    """Generate hierarchical task decomposition"""

    # Level 1: Identify major components
    components = identify_components(user_request)

    # Level 2: Decompose into subsystems
    hierarchy = {}
    for component in components:
        subsystems = decompose_component(component)
        hierarchy[component] = subsystems

    # Level 3: Create implementation modules (200-300 lines each)
    modules = []
    for component, subsystems in hierarchy.items():
        for subsystem in subsystems:
            mods = create_modules(subsystem, target_size=250)
            modules.extend(mods)

    # Build dependency graph
    dependencies = analyze_dependencies(modules)

    # Topological sort for execution order
    execution_order = topological_sort(modules, dependencies)

    return {
        'components': components,
        'hierarchy': hierarchy,
        'modules': modules,
        'dependencies': dependencies,
        'execution_order': execution_order
    }
```

---

**END OF PROTOCOL**

**Application**: This protocol is automatically applied by Claude Code when large projects are detected. No user configuration required.
