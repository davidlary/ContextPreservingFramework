# Chunking Large Projects - Complete Guide

**Version**: 1.0.0
**Date**: 2025-01-12
**Purpose**: Break large projects into bite-size, context-preserving chunks with clear file specifications
**Addresses**: User requirement "large project broken down into chunks clear and self-consistent at all levels"

---

## 🎯 OVERVIEW

**Problem**: Large projects (>1000 lines, >3 components, >2 hours) exceed Claude Code's context window

**Solution**: Systematic chunking with:
- Clear file specifications (which files to update)
- Module boundaries (200-300 lines per module)
- State preservation across sessions
- Self-consistent plan → execution → logging → recovery chain

**Result**: Complete large projects without context loss, file confusion, or breaking continuity

---

## 📋 WHEN TO USE CHUNKING

### Automatic Detection (RULE 1 of PROTOCOL_CORE_RULES.md)

Claude Code **MUST** activate chunking protocol when:
- ✅ Estimated **>1000 lines** of code, OR
- ✅ **>3 interconnected components**, OR
- ✅ Task **>2 hours** estimated, OR
- ✅ User says "large", "complex", "full system"

###Examples

**Requires Chunking** ✅:
- "Build a full user authentication system with database, API, and frontend"
- "Create a data processing pipeline with 5 stages"
- "Implement a complete e-commerce checkout flow"

**Doesn't Require Chunking** ❌:
- "Add a single function to existing file"
- "Fix bug in authentication.py"
- "Update README with new instructions"

---

## 🏗️ THE COMPLETE CHUNKING WORKFLOW

### Step 1: Create Project Plan (Specification Level)

**File**: `data/state/plan.json`
**Schema**: See `data/state/plan_schema.json`

**Actions**:
1. Decompose project into **modules** (target: 200-300 lines each)
2. For EACH module, specify:
   - **Exact file paths** (e.g., `src/auth.py`, not "authentication file")
   - **Action per file** ("update" vs "create")
   - **Functions to add** (e.g., `login()`, `verify_token()`)
   - **Dependencies** (which modules must complete first)
3. Generate **topological execution order**

**Example Plan**:
```json
{
  "project": "UserAuthSystem",
  "created": "2025-01-12T00:00:00Z",
  "modules": [
    {
      "id": "1.1",
      "name": "Database Schema",
      "files": [
        {
          "path": "src/database/models.py",
          "action": "create",
          "estimated_lines": 80,
          "functions": ["User", "Session"]
        }
      ],
      "tests": [
        {
          "path": "tests/test_models.py",
          "action": "create",
          "estimated_lines": 60
        }
      ],
      "status": "pending",
      "dependencies": []
    },
    {
      "id": "1.2",
      "name": "Authentication Logic",
      "files": [
        {
          "path": "src/auth/authentication.py",
          "action": "create",
          "estimated_lines": 200,
          "functions": ["login()", "logout()", "verify_token()"]
        }
      ],
      "tests": [
        {
          "path": "tests/test_auth.py",
          "action": "create",
          "estimated_lines": 150
        }
      ],
      "status": "pending",
      "dependencies": ["1.1"]
    }
  ]
}
```

**Key Points**:
- ✅ **Exact file paths** specified (not vague "create authentication file")
- ✅ **Action specified** ("create" or "update") - prevents "creating new instead of updating existing"
- ✅ **Dependencies explicit** (1.2 requires 1.1 complete)
- ✅ **Estimated lines** per file (ensures modules stay 200-300 lines)

---

### Step 2: Create File Manifest (Specification Level)

**File**: `data/state/file_manifest.json`

**Actions**:
1. List ALL authorized files from plan
2. Add documentation/test patterns to `always_allowed_patterns`
3. Enable enforcement: `"enforcement_active": true`

**Example Manifest**:
```json
{
  "project": "UserAuthSystem",
  "enforcement_active": true,
  "authorized_files": [
    "src/database/models.py",
    "src/auth/authentication.py",
    "tests/test_models.py",
    "tests/test_auth.py"
  ],
  "always_allowed_patterns": [
    "README.md",
    "CHANGELOG.md",
    "docs/**/*.md",
    "test_*.py",
    "*.test.js"
  ],
  "require_approval_for_new_files": true
}
```

**Why This Matters**:
- ✅ Prevents Claude from creating `auth_new.py` when it should update `authentication.py`
- ✅ Enforced by `scripts/validate_compliance.sh` (RULE 2)
- ✅ Addresses user's complaint: "creating new code instead of updating existing"

---

### Step 3: Create Todo List (Execution Level)

**Tool**: `TodoWrite`

**Actions**:
1. Create todo for EACH module in plan
2. **Link todo to plan module** (reference module ID)
3. **Specify exact files** in todo description

**Example Todo List**:
```json
[
  {
    "content": "Module 1.1: Database Schema → Create src/database/models.py",
    "status": "in_progress",
    "activeForm": "Creating database models"
  },
  {
    "content": "Module 1.1: Write tests → Create tests/test_models.py (>80% coverage)",
    "status": "pending",
    "activeForm": "Writing model tests"
  },
  {
    "content": "Module 1.2: Authentication → Create src/auth/authentication.py",
    "status": "pending",
    "activeForm": "Implementing authentication"
  }
]
```

**Key Points**:
- ✅ **Module ID referenced** (`Module 1.1`) - links todo to plan
- ✅ **Exact file path** (`src/database/models.py`) - no ambiguity
- ✅ **Action specified** (`Create` vs `Update`) - clear intent
- ✅ **Requirements noted** (`>80% coverage`) - validation criteria

**Anti-Pattern** (DON'T DO THIS ❌):
```json
{
  "content": "Implement authentication",  // ❌ No file specified!
  "status": "pending"
}
```
This violates self-consistency: Can't log or validate without file names.

---

### Step 4: Execute Module (Execution Level)

**For EACH module**:

#### 4.1 Mark Todo In-Progress
```
TodoWrite: Mark "Module 1.1" as in_progress
```

#### 4.2 Implement Code
```
Action: Check if src/database/models.py exists
  - If exists: Use Edit tool (UPDATE existing)
  - If not exists: Check file_manifest.json
    - If authorized: Use Write tool (CREATE new)
    - If not authorized: AskUserQuestion (get approval)

Result: File created/updated with code
```

#### 4.3 Write Tests (RULE 18 - MANDATORY)
```
Action: Create tests/test_models.py
Result: Tests written with >80% coverage target
```

#### 4.4 Run Tests (RULE 18 - MANDATORY)
```
Action: pytest tests/test_models.py -v --cov=src/database
Validation: MUST be 100% passing before checkpoint
  - If failing: Debug until passing (MANDATORY)
  - If context approaching 65%: Checkpoint with "tests_failing" status
```

#### 4.5 Update Documentation (RULE 19)
```
Action: Update README.md, CHANGELOG.md, API.md (if applicable)
Result: Docs synchronized with code changes
```

#### 4.6 Update State Files (RULE 14 - MANDATORY)
```
Action: Update all state files
  1. logs/operation_log.txt: Append operation log
  2. data/state/master_state.json: Update module status
  3. data/state/context_tracking.json: Update context percentage
  4. data/state/plan.json: Mark module 1.1 as "completed"
```

#### 4.7 Git Commit (RULE 16 - MANDATORY)
```
Action: git add -A && git commit -m "[Module 1.1] Database Schema - COMPLETE"
Result: All changes committed before checkpoint
```

#### 4.8 Mark Todo Complete
```
TodoWrite: Mark "Module 1.1" as completed
```

#### 4.9 Display Checkpoint Box (RULE 15)
```
═══════════════════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC - RULES 14-17)
═══════════════════════════════════════════════════════════════════════
✅ Operation logged: Module 1.1 complete → logs/operation_log.txt
✅ State updated: data/state/master_state.json (timestamp: 12:30:15)
✅ Context tracked: 45K tokens (22.5%)
✅ Threshold check: SAFE (below 65%)
✅ Git status: abc123 (committed)
═══════════════════════════════════════════════════════════════════════
```

#### 4.10 Check Context
```
If context < 65%: Continue to next module (Module 1.2)
If context ≥ 65%: Create recovery prompt (Step 5) and checkpoint
```

---

### Step 5: Context Checkpoint (Context Preservation Level)

**When**: Context reaches 65% (or module naturally complete)

**Actions**:

#### 5.1 Summarize Completed Modules
```
Compress Module 1.1 details:
  BEFORE (45K tokens): Full code, comments, debug history
  AFTER (2K tokens): Summary
    - Module 1.1: Database Schema ✓
    - Files: src/database/models.py (80 lines), tests/test_models.py (60 lines)
    - Functions: User, Session, create_tables()
    - Tests: 12 passed, 95% coverage
    - Commit: abc123
```

#### 5.2 Create Checkpoint File
```
File: .claude/checkpoints/checkpoint_001.json
{
  "checkpoint_id": "checkpoint_001",
  "timestamp": "2025-01-12T12:30:00Z",
  "context_percent": 65.2,
  "modules_complete": ["1.1"],
  "modules_pending": ["1.2", "1.3"],
  "next_module": "1.2",
  "summary": "Module 1.1 (Database Schema) complete. Ready for Module 1.2 (Authentication Logic)."
}
```

#### 5.3 Display Next Steps (RULE 17 - MANDATORY)
```
███████████████████████████████████████████████████████████████████████
🎯 NEXT STEPS FOR YOU (AFTER YOU EXIT AND COME BACK IN)
███████████████████████████████████████████████████████████████████████

### When You Exit This Session and Come Back:

1. **Start new Claude Code session in this directory**

2. **Paste this EXACT prompt**:
   ```
   Resume UserAuthSystem project from checkpoint_001.
   Module 1.1 (Database Schema) complete.
   Continue with Module 1.2 (Authentication Logic):
   - Create src/auth/authentication.py with login(), logout(), verify_token()
   - Files from plan: See data/state/plan.json module 1.2
   - Follow RULE 2: Check file_manifest.json before creating files
   ```

3. **Verify in first response**:
   - ✅ Module 1.1 status confirmed
   - ✅ Module 1.2 started
   - ✅ Correct files from plan

4. **Then continue with**: Module 1.2 implementation

### Before You Close This Session:

- **Verify**: cat data/state/plan.json | jq '.modules[] | select(.id=="1.1")'
- **Expected**: "status": "completed"

███████████████████████████████████████████████████████████████████████
```

---

### Step 6: Recovery (Error Recovery Level)

**When**: User starts new session

**Actions**:

#### 6.1 Detect Framework
```
Session start → Claude Code checks for CLAUDE.md
Found → Loads framework rules
```

#### 6.2 Load Checkpoint
```
Check: Does .claude/checkpoints/ directory exist?
If yes:
  - Load latest checkpoint (checkpoint_NNN.json)
  - Read data/state/plan.json
  - Read data/state/master_state.json
  - Load module summaries from .claude/summaries/
```

#### 6.3 Resume Execution
```
From checkpoint:
  - Modules complete: [1.1]
  - Next module: 1.2
  - Files to create: src/auth/authentication.py (from plan)
  - Action: "create" (from plan)

Continue with Module 1.2 execution (Step 4)
```

**Key Points**:
- ✅ **No context loss**: Checkpoint provides all info
- ✅ **Exact file names**: Plan specifies src/auth/authentication.py, not "auth file"
- ✅ **Action specified**: "create" from plan, so no confusion about update vs create
- ✅ **Self-consistent**: Plan → Todo → Execution → Logging → Recovery all use same file paths

---

## 🔗 SELF-CONSISTENCY VERIFICATION

### The Complete Chain

```
SPECIFICATION (Plan + Manifest)
   ├─ plan.json: Module 1.2 → src/auth/authentication.py (action: "create")
   ├─ file_manifest.json: src/auth/authentication.py in authorized_files
   ↓
EXECUTION (Todo + Implementation)
   ├─ TodoWrite: "Module 1.2 → Create src/auth/authentication.py"
   ├─ Check manifest: File authorized? Yes
   ├─ Write tool: Create src/auth/authentication.py
   ↓
LOGGING (State Files)
   ├─ operation_log.txt: "WRITE src/auth/authentication.py (Module 1.2)"
   ├─ master_state.json: "modules_in_progress": ["1.2"]
   ├─ plan.json: "modules[1].status": "in_progress"
   ↓
VALIDATION (Enforcement)
   ├─ validate_compliance.sh: Check RULE 2
   ├─ File src/auth/authentication.py in manifest? Yes → ✅ PASS
   ├─ Tests written? Yes → ✅ PASS
   ├─ Tests passing? Yes → ✅ PASS
   ↓
PROGRESS (Checkpointing)
   ├─ plan.json: Mark module 1.2 "completed"
   ├─ checkpoint_002.json: "modules_complete": ["1.1", "1.2"]
   ├─ Summarize module 1.2
   ↓
RECOVERY (Next Session)
   ├─ Load checkpoint_002.json
   ├─ Read plan.json: Next module is 1.3
   ├─ Continue with Module 1.3: src/api/routes.py (from plan)
```

**Result**: Every level uses the EXACT SAME FILE PATHS from the plan. No ambiguity, no "creating new instead of updating existing".

---

## 🚫 COMMON ANTI-PATTERNS (AVOID THESE)

### Anti-Pattern 1: Vague File Names in Plan ❌

**WRONG**:
```json
{
  "files": [
    {"path": "authentication file", "action": "create"}  // ❌ Vague!
  ]
}
```

**RIGHT**:
```json
{
  "files": [
    {"path": "src/auth/authentication.py", "action": "create"}  // ✅ Exact!
  ]
}
```

---

### Anti-Pattern 2: Todo Without File Names ❌

**WRONG**:
```json
{
  "content": "Implement authentication",  // ❌ Which file??
  "status": "in_progress"
}
```

**RIGHT**:
```json
{
  "content": "Module 1.2: Create src/auth/authentication.py with login(), logout()",  // ✅ Clear!
  "status": "in_progress"
}
```

---

### Anti-Pattern 3: Creating Files Not in Plan ❌

**WRONG**:
```
User: "Add authentication"
Plan: Module 1.2 → src/auth/authentication.py
Claude creates: src/auth_new.py  // ❌ Not in plan!
```

**RIGHT**:
```
User: "Add authentication"
Plan: Module 1.2 → src/auth/authentication.py
Claude checks: Is src/auth/authentication.py in manifest? Yes
Claude creates: src/auth/authentication.py  // ✅ Matches plan!
```

---

### Anti-Pattern 4: Logging Without File Names ❌

**WRONG**:
```
operation_log.txt: "Module complete"  // ❌ Which files changed??
```

**RIGHT**:
```
operation_log.txt: "Module 1.2 complete: Created src/auth/authentication.py (200 lines), tests/test_auth.py (150 lines)"  // ✅ Traceable!
```

---

## 📊 EXAMPLE: COMPLETE PROJECT FROM START TO FINISH

### Initial Request

**User**: "Build a complete user authentication system with database, API endpoints, and JWT tokens. Should handle login, logout, token refresh, and password reset."

### Estimation

- Estimated lines: ~1200 lines
- Components: Database (1), Auth Logic (2), API (3), Password Reset (4) = 4 components
- Estimated time: ~4-6 hours
- **Decision**: ✅ Activate chunking protocol (>1000 lines, >3 components, >2 hours)

### Step 1: Create Plan

**File**: `data/state/plan.json`

```json
{
  "project": "UserAuthenticationSystem",
  "description": "Complete authentication with JWT, password reset",
  "created": "2025-01-12T10:00:00Z",
  "total_estimated_lines": 1200,
  "total_estimated_tokens": 38000,
  "modules": [
    {
      "id": "1.1",
      "name": "Database Models",
      "files": [
        {"path": "src/database/models.py", "action": "create", "estimated_lines": 100}
      ],
      "tests": [
        {"path": "tests/test_models.py", "action": "create", "estimated_lines": 80}
      ],
      "estimated_lines": 180,
      "status": "pending",
      "dependencies": []
    },
    {
      "id": "1.2",
      "name": "Authentication Logic",
      "files": [
        {"path": "src/auth/authentication.py", "action": "create", "estimated_lines": 250}
      ],
      "tests": [
        {"path": "tests/test_auth.py", "action": "create", "estimated_lines": 200}
      ],
      "estimated_lines": 450,
      "status": "pending",
      "dependencies": ["1.1"]
    },
    {
      "id": "1.3",
      "name": "API Endpoints",
      "files": [
        {"path": "src/api/auth_routes.py", "action": "create", "estimated_lines": 180}
      ],
      "tests": [
        {"path": "tests/test_api.py", "action": "create", "estimated_lines": 150}
      ],
      "estimated_lines": 330,
      "status": "pending",
      "dependencies": ["1.2"]
    },
    {
      "id": "1.4",
      "name": "Password Reset",
      "files": [
        {"path": "src/auth/password_reset.py", "action": "create", "estimated_lines": 120}
      ],
      "tests": [
        {"path": "tests/test_password_reset.py", "action": "create", "estimated_lines": 100}
      ],
      "estimated_lines": 220,
      "status": "pending",
      "dependencies": ["1.2"]
    }
  ]
}
```

### Step 2: Create Manifest

```json
{
  "project": "UserAuthenticationSystem",
  "enforcement_active": true,
  "authorized_files": [
    "src/database/models.py",
    "src/auth/authentication.py",
    "src/auth/password_reset.py",
    "src/api/auth_routes.py",
    "tests/test_models.py",
    "tests/test_auth.py",
    "tests/test_password_reset.py",
    "tests/test_api.py"
  ],
  "always_allowed_patterns": ["README.md", "CHANGELOG.md", "docs/**/*.md", "test_*.py"]
}
```

### Step 3-6: Execute

**Session 1** (Modules 1.1, 1.2):
- Implement 1.1 (Database Models)
- Implement 1.2 (Authentication Logic)
- Context reaches 64%
- Checkpoint: checkpoint_001

**Session 2** (Modules 1.3, 1.4):
- Resume from checkpoint_001
- Implement 1.3 (API Endpoints)
- Implement 1.4 (Password Reset)
- Complete
- Final checkpoint: checkpoint_002

---

## ✅ VERIFICATION CHECKLIST

**Use this to verify chunking is working correctly**:

### Specification Level
- [ ] plan.json created with ALL modules
- [ ] EACH module has exact file paths (not vague names)
- [ ] EACH module has action specified ("update" vs "create")
- [ ] Dependencies explicitly listed
- [ ] file_manifest.json created with authorized files

### Execution Level
- [ ] TodoWrite items reference module IDs
- [ ] TodoWrite items specify exact file paths
- [ ] Before Write: Checked if file exists (prefer Edit)
- [ ] Before Write: Checked file_manifest.json authorization
- [ ] Tests written for EACH module (>80% coverage)
- [ ] Tests 100% passing before checkpoint

### Logging Level
- [ ] operation_log.txt logs file paths and actions
- [ ] master_state.json tracks current module
- [ ] plan.json updated with module status
- [ ] Git commits reference module IDs

### Validation Level
- [ ] validate_compliance.sh checks RULE 2 (file authorization)
- [ ] No unauthorized files detected
- [ ] Tests passing (RULE 18)
- [ ] Documentation updated (RULE 19)

### Progress Level
- [ ] Checkpoint box displayed (RULE 15)
- [ ] Context percentage monitored
- [ ] Checkpoint created at 65% or module complete
- [ ] Modules summarized (45K → 2K tokens)

### Recovery Level
- [ ] Next steps displayed (RULE 17)
- [ ] Recovery prompt specifies exact file names from plan
- [ ] Next session loads checkpoint successfully
- [ ] Next session continues with correct module

**If ALL checkboxes ✅: Chunking is self-consistent at all levels!**

---

## 🎓 KEY TAKEAWAYS

1. **Always specify exact file paths** in plan, todos, and logs
2. **Use file_manifest.json** to prevent "creating new instead of updating existing"
3. **Link all levels**: Plan → Todo → Execution → Logging → Recovery
4. **Check context every operation**, checkpoint at 65%
5. **Test every module** (>80% coverage, 100% passing)
6. **Commit every module** before checkpoint
7. **Summarize completed modules** (compress 45K → 2K)
8. **Provide recovery prompts** with exact file names for next session

**Result**: Large projects complete successfully without context loss, file confusion, or session continuity breaks.

---

**Last Updated**: 2025-01-12
**Status**: Complete - All levels of chunking documented and self-consistent
**See Also**:
- `PROTOCOL_CORE_RULES.md` (high-level protocol)
- `data/state/plan_schema.json` (plan format)
- `data/state/file_manifest.json` (file authorization)
- `RULE_PRIORITIES_AND_CONFLICTS.md` (conflict resolution)
