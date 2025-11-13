# Team Collaboration Guide

**How to use the framework with multiple developers**

**Estimated reading time**: 15 minutes
**Token cost**: ~10K tokens (5% context)
**When to read**: Before starting team-based development

---

## Table of Contents

1. [Team Setup](#team-setup)
2. [Collaborative Workflow Patterns](#collaborative-workflow-patterns)
3. [Handoff Procedures](#handoff-procedures)
4. [Shared State Management](#shared-state-management)
5. [Code Review with Framework](#code-review-with-framework)
6. [Conflict Resolution](#conflict-resolution)
7. [Team Communication Patterns](#team-communication-patterns)

---

## Team Setup

### Prerequisites

Before starting team collaboration:

**Each team member must**:
1. Complete framework setup per `02_SETUP_GUIDE.md`
2. Validate framework with `07_TESTING_GUIDE.md` tests
3. Understand solo workflow per `04_CORE_WORKFLOW.md`
4. Have access to shared repository

**Team lead must**:
1. Initialize framework in shared repository
2. Create initial `docs/IMPLEMENTATION_PLAN.md` with all modules
3. Define module ownership strategy (see below)
4. Set up branch protection rules
5. Configure shared state synchronization

---

### Module Ownership Strategies

Choose one strategy based on team size and project complexity:

#### Strategy 1: Module Assignment (Recommended for 2-4 developers)

**Pattern**: Each developer owns specific modules

```
docs/TEAM_ASSIGNMENTS.md:

## Module Assignments

### Developer: Alice
- Module 1.1: User authentication (Priority: High)
- Module 2.2: Profile management (Priority: Medium)
- Module 3.1: Settings UI (Priority: Low)

### Developer: Bob
- Module 1.2: Authorization (Priority: High)
- Module 2.1: User data API (Priority: High)
- Module 3.2: Notifications (Priority: Low)

### Developer: Charlie
- Module 1.3: Session management (Priority: High)
- Module 2.3: Avatar upload (Priority: Medium)
- Module 3.3: Help system (Priority: Low)
```

**Benefits**:
- Clear ownership, minimal conflicts
- Each developer can work autonomously
- Easy to track progress

**When to use**: Small teams, well-defined module boundaries

---

#### Strategy 2: Feature Branches (Recommended for 5+ developers)

**Pattern**: Developers work on feature branches, merge frequently

```
Branch structure:
- main (protected)
- develop (integration branch)
- feature/auth-alice (Alice's auth work)
- feature/api-bob (Bob's API work)
- feature/ui-charlie (Charlie's UI work)
```

**Workflow**:
1. Developer creates feature branch from `develop`
2. Works on assigned modules
3. Commits with framework format
4. Submits PR to `develop` when module(s) complete
5. Code review + CI tests
6. Merge to `develop`
7. Periodic `develop` → `main` releases

**Benefits**:
- Better for larger teams
- Enables parallel work on related modules
- Supports continuous integration

**When to use**: Larger teams, complex dependencies between modules

---

#### Strategy 3: Pair Programming with Handoffs

**Pattern**: Developers work in pairs, switch pairs frequently

**Setup**:
```
docs/PAIR_SCHEDULE.md:

## Week 1
- Mon-Wed: Alice + Bob (Modules 1.1, 1.2)
- Thu-Fri: Alice + Charlie (Module 1.3)

## Week 2
- Mon-Wed: Bob + Charlie (Modules 2.1, 2.2)
- Thu-Fri: Bob + Alice (Module 2.3)
```

**Benefits**:
- Knowledge sharing
- Real-time code review
- Reduced handoff overhead

**When to use**: Small teams, mentoring junior developers, complex modules

---

## Collaborative Workflow Patterns

### Pattern 1: Independent Modules (No Dependencies)

**Scenario**: Alice works on authentication (Module 1.1), Bob works on logging (Module 4.5) - no overlap

**Workflow**:

**Alice**:
1. Reads `docs/recovery_prompts/SESSION_ALICE_1.md` (if resuming)
2. Updates `data/state/master_state.json`: `current_module = "1.1"`, `current_developer = "alice"`
3. Implements Module 1.1 per `04_CORE_WORKFLOW.md`
4. Commits: `[Module 1.1] Implement user authentication (Alice)`
5. Creates recovery prompt: `docs/recovery_prompts/SESSION_ALICE_2.md`
6. Pushes to `main` (or submits PR if using feature branches)

**Bob** (working simultaneously):
1. Reads `docs/recovery_prompts/SESSION_BOB_1.md`
2. Updates `data/state/master_state.json`: `current_module = "4.5"`, `current_developer = "bob"`
3. Implements Module 4.5
4. Commits: `[Module 4.5] Add structured logging (Bob)`
5. Creates recovery prompt: `docs/recovery_prompts/SESSION_BOB_2.md`
6. Pushes to `main` (or submits PR)

**Conflict resolution**: Minimal conflicts expected (different modules, different files)

**State management**: Each developer updates their own module state files, master state shows both in progress

---

### Pattern 2: Dependent Modules (Sequential Work)

**Scenario**: Bob needs Alice's authentication module (1.1) before starting authorization module (1.2)

**Workflow**:

**Week 1: Alice works on Module 1.1**
1. Alice implements and completes Module 1.1
2. Commits: `[Module 1.1] Complete user authentication (Alice)`
3. Updates `data/state/master_state.json`: `modules_complete += ["1.1"]`
4. Notifies Bob: "Module 1.1 complete, auth interface at `core/auth.py:authenticate()`"
5. Creates handoff document: `docs/handoffs/MODULE_1.1_TO_1.2.md` (see template below)

**Week 2: Bob starts Module 1.2**
1. Reads handoff: `docs/handoffs/MODULE_1.1_TO_1.2.md`
2. Pulls latest `main` branch (includes Alice's Module 1.1)
3. Reviews Alice's code: `core/auth.py`
4. Starts Module 1.2 implementation, building on top of 1.1
5. If issues with 1.1 API, creates issue: `ISSUES.md` (see conflict resolution section)

**Handoff document template**:
```markdown
# Handoff: Module 1.1 (Authentication) → Module 1.2 (Authorization)

**From**: Alice
**To**: Bob
**Date**: 2025-01-11
**Git commit**: a1b2c3d

## Module 1.1 Summary

Implemented user authentication with:
- Login endpoint: `POST /api/auth/login` → returns JWT token
- Logout endpoint: `POST /api/auth/logout`
- Token validation: `core/auth.py:validate_token(token) → User | None`

## Key Files

- `core/auth.py` - Main authentication logic
- `api/auth_routes.py` - API endpoints
- `tests/test_auth.py` - 15 tests, all passing
- `data/users.db` - SQLite database (test users in `tests/fixtures/`)

## Interface for Module 1.2

```python
# Use this function to validate tokens before authorization checks
from core.auth import validate_token

def check_permission(token: str, resource: str, action: str) -> bool:
    # 1. Validate token (returns User or None)
    user = validate_token(token)
    if not user:
        return False

    # 2. Your authorization logic here
    # Check if user.role has permission for (resource, action)
    ...
```

## Dependencies Installed

- `PyJWT==2.8.0` (JWT token handling)
- `passlib==1.7.4` (password hashing)

## Known Issues

- None (all tests passing)

## Testing

Run tests: `pytest tests/test_auth.py`
Expected: 15 passed in 0.5s

## Questions?

Slack: @alice or email alice@example.com
```

---

### Pattern 3: Parallel Work on Same Module (Advanced)

**Scenario**: Large module (e.g., 500 lines, 2-3 days work) - split between Alice and Bob

**Pre-work**: Break module into sub-tasks

**Example: Module 2.1 (User Profile API) - 500 lines**

```
docs/IMPLEMENTATION_PLAN.md (Module 2.1):

Module 2.1: User Profile API (500 lines, 2-3 days)

Sub-tasks:
- 2.1a: GET /profile endpoint (Alice) - 150 lines, 4 hours
- 2.1b: PUT /profile endpoint (Bob) - 150 lines, 4 hours
- 2.1c: Profile validation logic (Alice) - 100 lines, 2 hours
- 2.1d: Profile database schema (Bob) - 100 lines, 2 hours
```

**Workflow**:

**Day 1**:
- Alice: Implements 2.1a (GET endpoint)
- Bob: Implements 2.1d (database schema)
- **Key**: Work in separate files (`api/profile_get.py` vs `db/profile_schema.py`)
- Both commit independently, no conflicts

**Day 2**:
- Alice: Implements 2.1c (validation) - depends on Bob's schema
- Bob: Implements 2.1b (PUT endpoint) - depends on Alice's validation
- **Coordination**: Daily standup, share progress
- Alice pulls Bob's schema changes before starting 2.1c
- Bob pulls Alice's validation before starting 2.1b

**Day 3**:
- Alice + Bob: Integration testing (full module)
- Joint commit: `[Module 2.1] Complete User Profile API (Alice + Bob)`

**State management**:
```json
// data/state/module_2.1_state.json
{
  "module": "2.1",
  "name": "User Profile API",
  "status": "in_progress",
  "sub_tasks": {
    "2.1a": {"owner": "alice", "status": "complete"},
    "2.1b": {"owner": "bob", "status": "in_progress"},
    "2.1c": {"owner": "alice", "status": "complete"},
    "2.1d": {"owner": "bob", "status": "complete"}
  }
}
```

---

## Handoff Procedures

### When to Create a Handoff

**Create handoff when**:
1. Finishing work on a module that another developer will build upon
2. Switching developers mid-module (e.g., Alice on vacation, Bob takes over)
3. Completing a phase (e.g., backend done, frontend developer needs handoff)
4. Pairing session ends (for pair programming teams)

### Handoff Checklist

**Before handoff, ensure**:
- [ ] All code committed and pushed
- [ ] All tests passing (`pytest`, `npm test`, etc.)
- [ ] State files updated (`master_state.json`, module state)
- [ ] Recovery prompt created
- [ ] Handoff document written (use template above)
- [ ] Documentation updated (if public interfaces changed)
- [ ] Notify next developer (Slack, email, etc.)

### Handoff Document Location

```
docs/handoffs/
├── MODULE_1.1_TO_1.2_alice_to_bob.md
├── MODULE_2.3_TO_3.1_charlie_to_alice.md
└── PHASE1_BACKEND_TO_FRONTEND_team_to_team.md
```

**Naming convention**: `[SCOPE]_[FROM]_TO_[TO]_[giver]_to_[receiver].md`

---

## Shared State Management

### State Files in Team Context

**Core principle**: State files are **source of truth** for project progress

**Challenge**: Multiple developers updating same files → merge conflicts

**Solution**: Use git merge strategy + clear update protocol

---

### Update Protocol for master_state.json

**Before starting work**:
```bash
# 1. Pull latest changes
git pull origin main

# 2. Read current state
cat data/state/master_state.json

# 3. Update state (mark your module in progress)
# Edit: current_module = "1.2", current_developer = "bob"
# Edit: modules_in_progress += ["1.2"]

# 4. Commit state change IMMEDIATELY
git add data/state/master_state.json
git commit -m "[State] Bob starting Module 1.2"
git push origin main
```

**After completing work**:
```bash
# 1. Update state (mark module complete)
# Edit: current_module = null
# Edit: modules_complete += ["1.2"]
# Edit: modules_in_progress -= ["1.2"]

# 2. Commit state + code together
git add .
git commit -m "[Module 1.2] Complete authorization (Bob)"
git push origin main
```

**Why immediate state commits?**
- Other developers see what you're working on
- Prevents duplicate work
- Enables progress tracking

---

### Handling State File Conflicts

**Scenario**: Alice and Bob both update `master_state.json` simultaneously

**Git conflict**:
```
<<<<<<< HEAD
  "current_module": "1.1",
  "current_developer": "alice",
  "modules_in_progress": ["1.1"]
=======
  "current_module": "1.2",
  "current_developer": "bob",
  "modules_in_progress": ["1.2"]
>>>>>>> main
```

**Resolution**:
```json
{
  "current_module": null,  // Multiple modules in progress
  "current_developer": null,  // Multiple developers
  "modules_in_progress": ["1.1", "1.2"],  // Merge both lists
  "last_update": "2025-01-11T10:45:00Z"
}
```

**Best practice**: Use `modules_in_progress` array to track multiple concurrent modules

---

### Locking Mechanism (Optional, for strict coordination)

**For teams requiring strict module locking** (only 1 developer per module):

**Create**: `scripts/lock_module.sh`
```bash
#!/bin/bash
# Lock a module for a developer

MODULE=$1
DEVELOPER=$2

# Check if module already locked
LOCKED=$(jq -r ".module_locks[\"$MODULE\"]" data/state/master_state.json)

if [ "$LOCKED" != "null" ] && [ "$LOCKED" != "$DEVELOPER" ]; then
  echo "❌ Module $MODULE is locked by $LOCKED"
  exit 1
fi

# Lock module
jq ".module_locks[\"$MODULE\"] = \"$DEVELOPER\"" data/state/master_state.json > tmp.json
mv tmp.json data/state/master_state.json

git add data/state/master_state.json
git commit -m "[Lock] $DEVELOPER locked Module $MODULE"
git push origin main

echo "✅ Module $MODULE locked for $DEVELOPER"
```

**Usage**:
```bash
# Bob wants to work on Module 1.2
./scripts/lock_module.sh 1.2 bob
# ✅ Module 1.2 locked for bob

# Alice tries to work on same module
./scripts/lock_module.sh 1.2 alice
# ❌ Module 1.2 is locked by bob
```

**Unlock**: `scripts/unlock_module.sh` (when module complete)

---

## Code Review with Framework

### Review Checklist for Framework Projects

When reviewing a PR/commit that uses this framework:

**1. Framework Compliance**
- [ ] Commit message follows `10_REFERENCE/commit_templates.md` format
- [ ] State files updated (`master_state.json`, module state)
- [ ] Recovery prompt created (if session ended)
- [ ] Module marked complete in state if fully done

**2. Code Quality** (standard review)
- [ ] Code follows project style guide
- [ ] Tests written and passing
- [ ] No obvious bugs or security issues
- [ ] Documentation updated

**3. Integration Concerns** (team-specific)
- [ ] No breaking changes to shared interfaces (or documented in handoff)
- [ ] Dependencies added to `requirements.txt`/`package.json`
- [ ] Database migrations included (if applicable)
- [ ] API changes documented in API docs

**4. State Integrity**
- [ ] `master_state.json` is valid JSON
- [ ] Module progression is logical (no skipped modules without reason)
- [ ] Timestamps are recent (within last session)

---

### Code Review Workflow

**Option 1: GitHub Pull Requests**

```
Workflow:
1. Developer completes module on feature branch
2. Submits PR to main/develop
3. CI runs tests automatically (GitHub Actions)
4. Reviewer uses checklist above
5. Approve + merge OR request changes
6. On merge: State files updated automatically (or manually)
```

**Example PR description** (template for developers):
```markdown
## Module 1.2: User Authorization

**Developer**: Bob
**Branch**: `feature/auth-bob`
**Module state**: Complete
**Tests**: 12 passed

### Changes
- Implemented role-based access control (RBAC)
- Added permission checks to all protected endpoints
- Created admin role and user role

### Files Changed
- `core/authorization.py` (new, 200 lines)
- `tests/test_authorization.py` (new, 150 lines)
- `api/auth_routes.py` (modified, added permission decorators)

### Dependencies
- None (uses existing PyJWT from Module 1.1)

### Testing
```bash
pytest tests/test_authorization.py
# Expected: 12 passed in 0.8s
```

### State Files Updated
- `data/state/master_state.json`: Module 1.2 marked complete
- `data/state/module_1.2_state.json`: Created with full status

### Handoff
- Created: `docs/handoffs/MODULE_1.2_TO_2.1.md`
- Next developer: Charlie (Module 2.1 - User Profile API)

### Framework Checklist
- [x] Commit message follows template
- [x] State files updated
- [x] Recovery prompt created
- [x] Tests passing
- [x] Handoff document written
```

---

**Option 2: Pair Review Sessions**

**For teams using pair programming or daily standups**:

```
Process:
1. Developer shares screen (Zoom, Slack, etc.)
2. Walks through code changes (5-10 minutes)
3. Team discusses:
   - Does code meet module requirements?
   - Any integration concerns?
   - State files correct?
4. Team approves verbally
5. Developer commits and pushes
```

**Benefits**: Faster than PR process, real-time discussion

---

## Conflict Resolution

### Types of Conflicts in Framework Projects

**1. Git Conflicts** (standard)
- **Cause**: Two developers edited same file
- **Resolution**: Standard git merge conflict resolution

**2. State File Conflicts**
- **Cause**: Two developers updated `master_state.json` simultaneously
- **Resolution**: Merge arrays (`modules_in_progress`, `modules_complete`), use latest timestamp

**3. Module Ownership Conflicts**
- **Cause**: Two developers start same module without coordination
- **Resolution**: See protocol below

**4. Interface Conflicts**
- **Cause**: Developer A changes interface that Developer B depends on
- **Resolution**: See breaking changes protocol below

---

### Module Ownership Conflict Protocol

**Scenario**: Alice and Bob both start Module 1.2 without realizing

**Detection**:
```bash
# Alice pulls latest main
git pull origin main

# Sees Bob's commit:
# [Module 1.2] Start authorization (Bob)

# But Alice also started 1.2 locally (uncommitted)
```

**Resolution**:

**Step 1: Communicate immediately**
```
Alice (Slack): "Hey @bob, I see you started Module 1.2. I also started it locally. Should I switch to another module or should we split the work?"
```

**Step 2: Choose resolution path**

**Option A: Split the module** (if work is substantial)
```
Bob: "I've implemented the RBAC logic (core/authorization.py, ~100 lines). Can you take the API integration (api/auth_routes.py)?"
Alice: "Sure, I'll do the API integration and tests."
```

**Option B: One developer switches** (if work just started)
```
Bob: "I just started, only 30 lines. Can you take 1.2? I'll switch to 1.3."
Alice: "Thanks! I'll take over 1.2."
```

**Option C: Merge work** (if both have substantial progress)
```
Bob: "I've done ~150 lines (RBAC core logic)."
Alice: "I've done ~120 lines (permission decorators)."
Bob: "Let's do a pair session, merge our work, and co-author the commit."
```

**Step 3: Update state to reflect resolution**

---

### Breaking Changes Protocol

**Scenario**: Alice changes authentication interface (Module 1.1) after Bob started authorization (Module 1.2)

**Example**:
```python
# Alice's original interface (Module 1.1):
def validate_token(token: str) -> User | None:
    ...

# Bob's Module 1.2 depends on this

# Alice's breaking change:
def validate_token(token: str) -> tuple[User | None, str | None]:
    # Now returns (user, error_message)
    ...
```

**Detection**: Bob's code breaks when Alice pushes changes

**Prevention** (ideal):
1. **Alice**: Before pushing breaking change, checks dependent modules
   ```bash
   # Check who depends on this function
   git grep "validate_token" | grep -v "core/auth.py"
   # Found: api/profile.py (Bob's work in progress)
   ```

2. **Alice**: Notifies Bob before pushing
   ```
   Alice (Slack): "@bob I need to change validate_token() to return tuple. Your profile API uses it. Can you update or should I hold off?"
   ```

3. **Bob**: Responds
   ```
   Bob: "Give me 30 mins to update my code, then push."
   ```

**Resolution** (if prevention fails):

1. **Bob**: Discovers break when pulling Alice's changes
   ```bash
   git pull origin main
   # Tests fail: TypeError in api/profile.py
   ```

2. **Bob**: Updates code to match new interface
   ```python
   # Old:
   user = validate_token(token)

   # New:
   user, error = validate_token(token)
   ```

3. **Bob**: Commits fix
   ```bash
   git commit -m "[Module 1.2] Update for new validate_token interface"
   ```

**Lesson**: Use versioning or deprecation for public interfaces in larger projects

---

## Team Communication Patterns

### Daily Standup (Recommended for teams of 3+)

**Purpose**: Coordinate work, avoid conflicts, share progress

**Duration**: 5-10 minutes

**Format**:
```
Each developer shares:
1. Yesterday: "Completed Module 1.1 (authentication)"
2. Today: "Starting Module 1.2 (authorization)"
3. Blockers: "Need Alice to finish auth before I can start"
```

**Framework-specific additions**:
- State file review: Project lead shows `master_state.json` on screen
- Context check: Any sessions approaching 35% context? (need handoff)
- Handoff needs: Any modules ready for handoff?

---

### Async Communication (Slack/Email)

**Recommended channels**:

**#dev-progress** (project progress updates)
```
Alice: ✅ Module 1.1 complete. Commit: a1b2c3d. Handoff doc: docs/handoffs/MODULE_1.1_TO_1.2.md
Bob: 🚧 Module 1.2 in progress. 60% done, on track for EOD.
Charlie: 🤔 Module 1.3 - question about session storage, see thread.
```

**#dev-blockers** (blockers and issues)
```
Bob: ⚠️ Module 1.2 blocked: Need Alice's auth interface finalized.
Alice: 👍 Auth interface is stable now (core/auth.py:validate_token). You're unblocked.
```

**#dev-reviews** (code review requests)
```
Alice: 📝 PR ready for review: Module 1.1 (authentication) - https://github.com/...
Bob: 👀 Reviewing now...
Bob: ✅ Approved, merging.
```

---

### Weekly Sync (Recommended for all teams)

**Purpose**: Review overall progress, plan next week, discuss issues

**Duration**: 30-60 minutes

**Agenda**:
1. **Progress review** (10 mins)
   - Modules completed this week
   - Modules in progress
   - Any behind schedule?

2. **State file review** (5 mins)
   - Review `master_state.json`
   - Verify all modules accounted for
   - Check for any inconsistencies

3. **Next week planning** (10 mins)
   - Assign next modules
   - Identify dependencies
   - Flag high-risk modules (need pairing?)

4. **Issues and improvements** (10 mins)
   - Review `ISSUES.md`
   - Discuss framework improvements
   - Any process changes needed?

5. **Q&A** (remaining time)

---

### Documentation for Team Projects

**Additional docs to maintain**:

**1. TEAM_ASSIGNMENTS.md** (who owns what)
```markdown
# Team Assignments

Updated: 2025-01-11

## Current Assignments

### Alice
- **In progress**: Module 2.1 (User Profile API)
- **Completed**: Module 1.1 (Authentication)
- **Next**: Module 3.1 (Settings UI)

### Bob
- **In progress**: Module 1.2 (Authorization)
- **Completed**: None
- **Next**: Module 2.2 (Profile Management)
```

**2. HANDOFFS/** (directory of handoff docs)
```
docs/handoffs/
├── MODULE_1.1_TO_1.2_alice_to_bob.md
├── MODULE_1.2_TO_2.1_bob_to_alice.md
└── README.md (index of all handoffs)
```

**3. DECISIONS.md** (architectural decisions)
```markdown
# Architecture Decisions

## Decision 1: Authentication Strategy (2025-01-05)
**Context**: Need to choose between JWT and sessions
**Decision**: Use JWT tokens (stateless)
**Rationale**: Easier to scale, no server-side session storage
**Impact**: Modules 1.1, 1.2, 1.3
**Decided by**: Team (Alice, Bob, Charlie)
```

---

## Best Practices Summary

**For smooth team collaboration**:

1. **Communicate early and often**
   - Daily standups or async updates
   - Notify before breaking changes
   - Ask questions when blocked

2. **Keep state files synchronized**
   - Pull before starting work
   - Commit state changes immediately
   - Resolve conflicts quickly

3. **Create comprehensive handoffs**
   - Use handoff template
   - Include code examples
   - Document gotchas and issues

4. **Follow review checklist**
   - Framework compliance checks
   - Test coverage verification
   - State integrity validation

5. **Use module assignments**
   - Clear ownership prevents conflicts
   - Split large modules if needed
   - Lock modules if strict coordination required

6. **Document decisions**
   - Keep DECISIONS.md updated
   - Include rationale for future reference
   - Note impacted modules

---

**Team Collaboration Guide version**: 3.3
**Last updated**: January 2025
