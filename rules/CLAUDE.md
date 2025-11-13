# Enforcement Rules - Context-Preserving Framework

**Purpose**: Strict rules for Claude Code (concise format for token efficiency)
**Status**: ACTIVE - ENFORCED (Not just instructions, technically validated)
**Version**: v4.0.1 (Integrated - combines v3.x enforcement with v4.0 RFC 2119 requirements)
**Detailed Docs**: See project documentation for full examples and explanations

---

## 🚨 ENFORCEMENT: These Rules Are MANDATORY

**Critical Change**: Previous versions relied on instruction-based enforcement (Claude reads rules and hopes to follow them). This caused "persistent no compliance" issues.

**New Enforcement**: Multi-layered technical enforcement system

**4 Enforcement Layers**:
1. **Auto-Loading**: CLAUDE.md automatically read by Claude Code at session start (GUARANTEED)
2. **Explicit Instructions**: RFC 2119 MUST/SHALL keywords (STRONG PROMPTING)
3. **Automated Validation**: PostToolUse hooks run `scripts/validate_compliance.sh` after EVERY tool call (TECHNICAL CHECK)
4. **Feedback Loop**: Hook failures treated as user messages Claude MUST respond to (PERSISTENT CORRECTION)

**What This Means**:
- ✅ State files (RULE 14) validated automatically after every Read/Edit/Write/Bash
- ✅ Violations detected immediately and surfaced as errors
- ✅ Claude sees violations as user feedback and must fix them
- ✅ Creates self-correcting feedback loop (violations cannot be silently ignored)

**Documentation**: See `ENFORCEMENT_MECHANISMS.md` for complete technical details

**Activation**: Hooks must be registered with `/hooks` command (see enforcement doc)

**Result**: Changes problem from "persistent no compliance" to "rare transient violations that auto-correct"

---

## 📋 RFC 2119 Keywords (Enforcement Levels)

- **MUST** / **SHALL** / **REQUIRED**: Absolute requirement (Tier 1 - Critical, validated by hooks)
- **MUST NOT** / **SHALL NOT**: Absolute prohibition (Tier 1 - Critical)
- **SHOULD** / **RECOMMENDED**: Strong recommendation (Tier 2 - Important, follow unless good reason)
- **MAY** / **OPTIONAL**: Truly optional (Tier 3 - Optimization)

---

## Rule Hierarchy and Conflict Resolution

**When rules conflict, follow this priority order:**

### TIER 1: CRITICAL (Never Violate - These Override All Others)

**RULE 10**: Context Management
  - Never exceed 35% context (hard limit: 40%)
  - If any rule would push context >35%, STOP and checkpoint instead
  - Example: RULE 4 says retry 3 times, but retrying would hit 37% → CHECKPOINT instead

**RULE 14**: State Tracking
  - After EVERY operation: update logs and state files
  - No exceptions, even in error conditions

**RULE 15**: Visible Checkpoint
  - Display checkpoint box before completing response
  - No exceptions

**RULE 16**: Git Commit Protocol
  - Commit after module complete, tests pass
  - If git unavailable, use alternative versioning (see 08_TROUBLESHOOTING.md Edge Case 3)

**RULE 17**: Next Steps
  - Always display recovery prompt and next steps
  - Session must end with clear continuation path

---

### TIER 2: IMPORTANT (Follow Unless Overridden by Tier 1)

- RULE 1: Zero hard-coding
- RULE 2: Named files only
- RULE 3: Zero silent failures
- RULE 4: Autonomous issue resolution
- RULE 5: Documentation synchronization
- RULE 6: Strategy vs status separation
- RULE 7: Validation gates
- RULE 8: Performance optimization
- RULE 9: Code reuse mandatory

---

### TIER 3: OPTIMIZATION (Follow When Possible, Lowest Priority)

- RULE 11: Minimal dependencies
- RULE 12: Explicit over implicit
- RULE 13: Error prevention over correction

---

### Conflict Resolution Algorithm

**Example Conflict 1**:
- RULE 4 says "retry 3 times"
- RULE 10 says "exit at 35% context"
- Scenario: 2nd retry would push context to 36%
- **Resolution**: RULE 10 wins (Tier 1 > Tier 2) → Checkpoint now, resume retries in next session

**Example Conflict 2**:
- RULE 7 says "validation must pass before proceeding"
- RULE 10 says "exit at 35%"
- Scenario: Validation fails, debugging would push to 37%
- **Resolution**: RULE 10 wins (Tier 1) → Checkpoint with "validation_failed" status, resume debug next session

**Example Conflict 3**:
- RULE 11 says "minimize dependencies"
- RULE 4 says "retry with backoff"
- Scenario: Retry requires adding new dependency
- **Resolution**: RULE 4 wins (Tier 2 > Tier 3) → Add dependency to fix issue

---

### Decision Logic

```
function resolve_rule_conflict(rules_in_conflict):
    tier1_rules = filter(rules_in_conflict, tier == 1)
    tier2_rules = filter(rules_in_conflict, tier == 2)
    tier3_rules = filter(rules_in_conflict, tier == 3)

    if tier1_rules.length > 0:
        return tier1_rules[0]  # Tier 1 always wins
    elif tier2_rules.length > 0:
        return tier2_rules[0]  # Tier 2 wins over Tier 3
    else:
        return tier3_rules[0]  # All Tier 3, follow first mentioned
```

**Result**: Any rule conflict has deterministic resolution

---

## RULE 1: ZERO HARD-CODING

**Principle**: All values from config files or database
**Action**:
  - Use `config['section']['key']`, never literal values
  - Store constants in config files (JSON, YAML, or .env)
  - Use environment variables for deployment-specific values
**Validation**: Search codebase for hardcoded values, ensure all come from config

---

## RULE 2: NAMED FILES ONLY (ENHANCED v2.0 - FILE MANIFEST SYSTEM)

**Principle**: Only create files authorized in manifest - UPDATE EXISTING files, don't create new ones
**Enforcement**: MUST (Tier 2) - Technically enforced by validation script + file_manifest.json
**Critical**: Addresses user complaint "persistent issue creating new code instead of updating existing"

**Actions** (REQUIRED):

### Before Using Write Tool (MANDATORY)

**BEFORE creating ANY file, Claude MUST:**

1. **Check if file exists** (use Read tool or Glob):
   - If exists: **UPDATE it** (use Edit tool, NOT Write) ✅ PREFERRED
   - If not exists: Continue to step 2

2. **Check file_manifest.json** (if exists in project):
   ```bash
   # Check authorized files
   jq '.authorized_files' data/state/file_manifest.json
   jq '.always_allowed_patterns' data/state/file_manifest.json
   ```

3. **Determine if authorized**:
   - ✅ **AUTHORIZED** if ANY of these true:
     - File in `.authorized_files` array
     - File matches `.always_allowed_patterns` (e.g., `test_*.py`, `*.md`)
     - Extension in `.always_allowed_extensions` (e.g., `.md`, `.txt`, `.json`)
   - ❌ **NOT AUTHORIZED** otherwise

4. **If NOT authorized**:
   - **MUST** use AskUserQuestion tool: "File X not in manifest. Options: (a) Update existing file Y instead, (b) Approve creating X, (c) Cancel"
   - **MUST** wait for user approval
   - **MUST** add to manifest if approved
   - **MUST NOT** create file without approval

5. **If authorized**:
   - Create file with Write tool
   - Update manifest's last_update timestamp

### File Manifest Structure

Location: `data/state/file_manifest.json`

```json
{
  "authorized_files": ["src/auth.py", "src/user.py"],
  "always_allowed_patterns": ["README.md", "test_*.py", "docs/**/*.md"],
  "always_allowed_extensions": [".md", ".txt", ".json"],
  "require_approval_for_new_files": true
}
```

### Special Cases

**Documentation Files** (ALWAYS ALLOWED - See RULE_PRIORITIES_AND_CONFLICTS.md):
- README.md, CHANGELOG.md, API.md, ARCHITECTURE.md, docs/**/*.md
- These DON'T need manifest approval (RULE 19 priority)

**Test Files** (ALWAYS ALLOWED if matching pattern):
- test_*.py, *_test.py, *.test.js, *.spec.js, *_test.go
- These match `always_allowed_patterns`

**Code Files** (.py, .js, .go, .rs, .java, .cpp):
- **MUST** be in manifest OR approved by user
- This prevents "creating new code instead of updating existing"

### Validation

**Automatic Enforcement**:
- `scripts/validate_compliance.sh` checks RULE 2 after Write operations
- Detects unauthorized files (untracked in git)
- Flags violations: "❌ VIOLATION: Unauthorized file created: X"

**Required Actions on Violation**:
1. DELETE unauthorized file, OR
2. UPDATE existing file instead, OR
3. ASK user for approval and add to manifest

### Examples

**Example 1: Update Existing (CORRECT)**
```
User: "Add password reset to authentication"
Claude: Checks if src/auth.py exists → YES
Action: Use Edit tool to update src/auth.py ✅ CORRECT
```

**Example 2: Create New Without Approval (VIOLATION)**
```
User: "Add password reset to authentication"
Claude: Creates src/password_reset.py ❌ WRONG
Validation: "❌ VIOLATION: Unauthorized file created: src/password_reset.py"
Required: DELETE and update src/auth.py instead
```

**Example 3: Ask Before Creating (CORRECT)**
```
User: "Add password reset to authentication"
Claude: Checks if src/auth.py exists → NO
        Checks file_manifest.json → src/auth.py NOT in list
Action: Uses AskUserQuestion: "src/auth.py not in manifest. Create it or use existing file?"
User: "Approve creation"
Claude: Adds to manifest, then creates file ✅ CORRECT
```

**Example 4: Documentation File (ALWAYS ALLOWED)**
```
User: "Document the authentication system"
Claude: Creates docs/authentication.md ✅ CORRECT (docs always allowed)
Validation: Checks pattern → matches "docs/**/*.md" → AUTHORIZED
```

### Project Setup (For Users)

**Option 1: List all files** (explicit, for code projects)
```json
{
  "authorized_files": [
    "src/main.py",
    "src/auth.py",
    "src/database.py",
    "tests/test_auth.py"
  ]
}
```

**Option 2: Use patterns** (flexible, for documentation projects)
```json
{
  "always_allowed_patterns": [
    "docs/**/*.md",
    "guides/**/*.md",
    "test_*.py"
  ]
}
```

### If No Manifest Exists

**If project doesn't have file_manifest.json**:
- Claude SHOULD still prefer updating existing files
- Claude SHOULD ask before creating major new files
- Validation script will skip RULE 2 check (warns: "file_manifest.json not found")

**Principle**: Even without technical enforcement, follow the spirit of RULE 2: Update existing, don't proliferate new files unnecessarily.

---

**Why This Matters**:
- Prevents code fragmentation (20 small files vs 5 well-organized files)
- Addresses user's persistent complaint: "creating new code instead of updating existing"
- Technically enforced (not just instruction-based)
- Validates automatically after every Write operation

---

## RULE 3: ZERO SILENT FAILURES

**Principle**: Every error MUST be logged loudly
**Action**:
  - Use proper logging (logger.error(), console.error(), etc.) with full context
  - Log warnings for unexpected conditions
  - All logs → stdout + log file
  - Never swallow exceptions or fail silently
**Never**: Catch exceptions without logging or re-raising

---

## RULE 4: AUTONOMOUS ISSUE RESOLUTION

**Principle**: Attempt recovery within retry limits before escalating
**Action**:
  - Max 3 retries with exponential backoff
  - Fatal errors (MemoryError, DiskFull): escalate immediately
  - Create issue tracking file if max retries exceeded
  - Document resolution attempts in logs

---

## RULE 5: DOCUMENTATION SYNCHRONIZATION

**Principle**: Docs must match code 100%
**Action**: After ANY code change:
  - Update corresponding docs in SAME commit
  - Run documentation validation
  - Never commit code without updating docs
  - Use inline comments for complex logic

---

## RULE 6: STRATEGY VS STATUS SEPARATION

**Principle**: Design (strategy) separate from progress (status)
**Structure**:
  - `docs/strategy/` or `docs/design/` → design docs (static, rarely changes)
  - `docs/implementation/` or `docs/progress/` → progress tracking (dynamic)
  - `STATUS.md` → top-level summary
  - Keep design decisions separate from implementation status

---

## RULE 7: VALIDATION GATES

**Principle**: Validation must pass before proceeding to next phase
**Action**:
  - Each major phase must validate before proceeding
  - Autonomous debug-and-fix on failures
  - Pipeline halts if validation fails after auto-fix attempt
  - Document validation criteria clearly

---

## RULE 8: PERFORMANCE OPTIMIZATION

**Principle**: Apply performance best practices from design docs
**Required**:
  - Use efficient data structures
  - Implement caching where appropriate
  - Batch operations when possible
  - Profile and optimize hotspots
  - Document performance requirements

---

## RULE 9: CODE REUSE MANDATORY

**Principle**: Search for existing functionality before writing new code
**Action**:
  1. Search codebase for existing functionality
  2. If found: Reuse and document
  3. If not found: Write new and register it
  4. Maintain code reuse registry if applicable

---

## RULE 10: CONTEXT MANAGEMENT (ENHANCED v4.0 - RESEARCH-BASED)

**Principle**: Prevent context exhaustion through multi-layer management
**Enforcement**: MUST (Tier 1 - Critical)

**Thresholds** (Research-Based 2025):
- 0-50%: Continue normally (safe zone)
- 50-65%: Monitor closely, prepare for checkpoint
- **65%**: Normal checkpoint (summarize + save) - **MUST** trigger
- **75%**: Emergency checkpoint (force save) - **MUST** trigger
- **MUST NOT** exceed 75%

**Research Foundation**:
- Goose AI: 80% automatic summarization standard
- Databricks: Performance degradation starts at 32K tokens
- Industry consensus: Avoid last 20% of context window
- Deep Agent (2025): Hierarchical task decomposition for large projects

**Actions** (REQUIRED):
- **MUST** keep files small and focused (max 250-500 lines per file)
- **MUST** track context in real-time after every operation
- **MUST** display warning at 50%, critical at 65%
- **MUST** auto-checkpoint at 65%+
- **MUST** force emergency checkpoint at 75%
- **MUST** use recovery prompts for session continuity
- **MUST** apply automatic summarization: Compress completed work (95% token reduction)

**Backward Compatibility** (CRITICAL - MUST follow):

**Detection order** (check in this sequence):
1. **Check for explicit user configuration**:
   - If `config/context_config.json` exists with `threshold` field: Use that value
   - If `data/state/context_tracking.json` has `threshold_critical` set: Use that value
   - If `CLAUDE.md` specifies threshold (e.g., "Exit at X%"): Use that value

2. **Check for existing project**:
   - If `.claude/` directory exists AND `data/state/master_state.json` has `created_before` field with date < 2025-01-12: Use 35% threshold (v3.x project)
   - If project has commits dated before 2025-01-12: Use 35% threshold (v3.x project)

3. **Default for new projects** (no config, no existing state):
   - Use 65% primary, 75% emergency (research-based v4.0.1)

**Example config file** (`config/context_config.json`):
```json
{
  "threshold_warning": 50,
  "threshold_critical": 35,
  "threshold_emergency": 40,
  "note": "Using conservative 35% threshold for this project"
}
```

**Rule**: User's explicit configuration **ALWAYS** overrides defaults. Never force new thresholds on existing projects.

**Validation**:
- **MUST** verify context < threshold before each major operation
- If any rule would push context > threshold: **MUST** checkpoint instead

---

## RULE 11: AUTONOMOUS EXECUTION MODE

**Principle**: Check AUTONOMOUS_MODE.md before significant actions
**Action**: At session start:
  - Check if `AUTONOMOUS_MODE.md` exists and `STATUS: ACTIVE`
  - If active: Proceed without asking for granted permissions
  - If not active: Ask before major operations
  - Display autonomous status clearly

---

## RULE 12: PRESERVE CORE REQUIREMENTS

**Principle**: Respect original requirements and design decisions
**Action**:
  - Treat requirements as sacred: preserve then enhance
  - Validate changes against requirements
  - Never contradict original design without approval
  - Document all deviations with justification

---

## RULE 13: REAL DATA ONLY

**Principle**: No placeholders, no dummy data, no TODOs in ANY committed file
**Forbidden**: "TODO", "TBD", "PLACEHOLDER", "XXX", "FIXME", empty strings, mock values
**Action**: Research real values before committing
**Validation**: Search for placeholder patterns before commits

---

## RULE 14: MANDATORY STATE TRACKING - ENFORCED EVERY OPERATION

**Principle**: State tracking **MUST** occur after EVERY tool operation
**Enforcement**: MUST (Tier 1 - Critical)

**Actions** (REQUIRED):
After Read, Write, Edit, Bash, Claude **MUST**:
  1. Log operation to log file (`logs/operation_log.txt`)
  2. Update state tracking (`data/state/master_state.json` or equivalent)
  3. Update context tracking (`data/state/context_tracking.json`)
  4. Check context threshold

**Validation**:
- **MUST NOT** proceed to next operation without completing steps 1-4
- **MUST** append timestamp and operation type to log
- **MUST** ensure state files remain valid JSON

**Enforcement**: This is instruction-based enforcement - execute these instructions after EVERY tool use.

---

## RULE 15: VISIBLE STATE TRACKING - MANDATORY IN EVERY RESPONSE

**Principle**: Make tracking VISIBLE in every response
**Action**: BEFORE completing ANY response, display:

```
═══════════════════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC - RULES 14-17)
═══════════════════════════════════════════════════════════════════════

✅ Operation logged: [type] → [log_file]
✅ State updated: [state_file] (timestamp: HH:MM:SS)
✅ Context tracked: [N]K tokens ([X.X]%)
✅ Threshold check: [SAFE/WARNING/CRITICAL]
✅ Git status: [Last commit hash or "No commits"]

Next threshold: [35%/40%] at [N]K tokens
Operations this session: [count]

═══════════════════════════════════════════════════════════════════════
```

**This makes tracking visible and verifiable.**

---

## RULE 16: AUTOMATIC GIT OPERATIONS - MANDATORY COMMIT PROTOCOL

**Principle**: All work preserved in git automatically
**Action**: Commit at these points:
  - After completing any module or major task
  - After writing tests that pass
  - Before context reaches 35%
  - Every 30 minutes if actively working
  - Minimum: Every 5 significant operations

**Commit format** (use HEREDOC):
```bash
git commit -m "$(cat <<'EOF'
[Session_ID] Task_Description - STATUS

Changes:
- List of files modified

Progress: [X]% complete
Context: [N]K tokens ([X]%)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## RULE 17: CLEAR NEXT STEPS - MANDATORY AT END OF EVERY RESPONSE

**Principle**: User ALWAYS knows what to do next
**Action**: At END of EVERY response (AFTER checkpoint), display:

```
███████████████████████████████████████████████████████████████████████
🎯 NEXT STEPS FOR YOU (AFTER YOU EXIT AND COME BACK IN)
███████████████████████████████████████████████████████████████████████

### When You Exit This Session and Come Back:

1. **Start new Claude Code session in this directory**

2. **Paste this EXACT prompt**:
   ```
   [Exact recovery prompt with all context]
   ```

3. **Verify in first response**:
   - ✅ [What to check]

4. **Then continue with**: [Next task]

### Before You Close This Session:

- **Verify**: [Quick check]
- **Expected**: [What should show]

### If Issues When You Resume:

- **If [problem]**: [solution]

███████████████████████████████████████████████████████████████████████
[END OF RESPONSE - NOTHING AFTER THIS BLOCK]
███████████████████████████████████████████████████████████████████████
```

**Template reference**: This file, RULE 17
**THIS MUST BE THE LAST THING - NOTHING AFTER IT**

---

## RULE 18: MANDATORY TESTING (v4.0 ADDITION)

**Principle**: Every module **MUST** have comprehensive tests before checkpoint
**Enforcement**: MUST (Tier 1 - Critical)

**Requirements** (MANDATORY):
- **MUST** write tests for every module
- **MUST** achieve >80% line coverage
- Tests **MUST** be in `tests/` directory
- Test file **MUST** follow naming convention:
  - Python: `test_<module>.py`
  - JavaScript: `<module>.test.js` or `<module>.spec.js`
  - Go: `<module>_test.go`
  - Rust: `tests/<module>.rs` or inline `#[test]`

**Test Execution** (REQUIRED):
- **MUST** run all tests before checkpoint:
  - Python: `pytest tests/ -v --cov=core`
  - JavaScript: `npm test` or `jest`
  - Go: `go test ./...`
  - Rust: `cargo test`
- **MUST** verify 100% passing (0 failures, 0 errors)
- **MUST NOT** checkpoint if any test fails
- **MUST NOT** skip tests or mark as "expected to fail"

**Test Debugging** (MANDATORY):
If tests fail, Claude **MUST**:
1. Read error message carefully
2. Debug until root cause identified
3. Fix root cause (not symptoms)
4. Re-run tests
5. Repeat until 100% passing
- **MUST NOT** skip failing tests
- **MUST NOT** comment out failing tests
- **MUST NOT** modify tests to pass incorrectly
- **MUST** fix implementation, not tests (unless tests are genuinely wrong)

**Test Coverage** (REQUIRED):
- Normal case: **MUST** cover expected behavior
- Edge cases: **SHOULD** cover boundary conditions (empty input, max values, etc.)
- Error cases: **SHOULD** cover error handling (invalid input, exceptions)
- Integration: **MAY** add integration tests for complex interactions

**Validation** (Pre-Checkpoint):
Before checkpoint, Claude **MUST** verify:
- [ ] Tests written (>80% coverage target)
- [ ] All tests passing (100%)
- [ ] No skipped/commented/disabled tests
- [ ] Edge cases covered
- [ ] Test output shows success

**If ANY validation fails: MUST NOT checkpoint. Debug and retry.**

---

## RULE 19: MANDATORY AUTO-DOCUMENTATION (v4.0 ADDITION)

**Principle**: Documentation **MUST** be comprehensive, accurate, and current
**Enforcement**: MUST (Tier 2 - Important, but yields to Tier 1 context management)

**Documentation Types** (5 REQUIRED):

### 19.1 Inline Documentation (MUST - Every Function)

**When**: Every function/class written
**Requirement**: Docstrings/JSDoc for all public functions

**Example (Python)**:
```python
def authenticate(username: str, password: str) -> Token:
    """
    Authenticate user with username and password.

    Args:
        username: User's username (required)
        password: User's password in plaintext (will be hashed)

    Returns:
        Token: JWT token valid for 24 hours

    Raises:
        AuthError: If credentials invalid or user locked

    Example:
        >>> token = authenticate("alice", "secret123")
        >>> print(token.expires_at)
    """
```

**Example (JavaScript)**:
```javascript
/**
 * Authenticate user with username and password.
 *
 * @param {string} username - User's username (required)
 * @param {string} password - User's password in plaintext (will be hashed)
 * @returns {Promise<Token>} JWT token valid for 24 hours
 * @throws {AuthError} If credentials invalid or user locked
 *
 * @example
 * const token = await authenticate("alice", "secret123");
 * console.log(token.expiresAt);
 */
function authenticate(username, password) { ... }
```

### 19.2 README.md (MUST UPDATE)

**When**: Any module changes user-facing behavior
**Required Updates**:
- Installation instructions (if setup changed)
- Usage examples (if API changed)
- Updated feature list (if new features added)
- Configuration options (if config changed)

**Validation**:
- **MUST** verify README.md exists
- **MUST** verify README.md mentions new features
- **SHOULD** include code examples for new features

### 19.3 API.md (MUST UPDATE)

**When**: Any module exposes new API endpoints or public functions
**Required Content**:
- Endpoint/function signature
- Parameters and their types
- Return values and their types
- Example usage (request/response or function call)
- Error cases and error codes
- Authentication requirements (if applicable)

**Example Entry**:
```markdown
## POST /api/auth/login

**Description**: Authenticate user and return JWT token

**Parameters**:
- `username` (string, required): User's username
- `password` (string, required): User's password

**Returns** (200 OK):
```json
{
  "token": "eyJhbGc...",
  "expires_at": "2025-01-12T00:00:00Z"
}
```

**Errors**:
- 401 Unauthorized: Invalid credentials
- 429 Too Many Requests: Rate limit exceeded

**Example**:
```bash
curl -X POST http://api.example.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "secret123"}'
```
```

### 19.4 ARCHITECTURE.md (MUST UPDATE)

**When**: New component or major subsystem added
**Required Content**:
- Component diagram (ASCII art, Mermaid, or description)
- Dependencies between components
- Data flow between components
- Technology stack for component
- Rationale for architectural decisions

**Example Entry**:
```markdown
## Authentication Component

**Purpose**: Handle user authentication and session management

**Dependencies**:
- Database component (for user lookup)
- Configuration component (for JWT secret)

**Technology**:
- JWT tokens (jsonwebtoken library)
- bcrypt for password hashing

**Data Flow**:
```
User -> Login Endpoint -> Auth Service -> Database
                             ↓
                        JWT Generator
                             ↓
                        Return Token
```

**Files**:
- `core/auth.py` (200 lines)
- `tests/test_auth.py` (85 lines)
```

### 19.5 CHANGELOG.md (MUST UPDATE)

**When**: Every module completion
**Required Format** (Keep a Changelog):
```markdown
## [Unreleased]
### Added
- Module X.Y: Feature description
- New function `authenticate()` for user login

### Changed
- Modified behavior in module X.Z: Now returns JSON instead of XML

### Fixed
- Bug fix in module X.W: Resolved race condition in concurrent requests

### Deprecated
- Function `old_login()` will be removed in v2.0

### Removed
- Removed deprecated function `legacy_auth()`

### Security
- Fixed SQL injection vulnerability in search endpoint
```

**Pre-Checkpoint Validation** (MUST):
Before checkpoint, Claude **MUST** verify:
- [ ] All public functions have docstrings/JSDoc (19.1)
- [ ] README.md exists and up to date (19.2)
- [ ] API.md updated if APIs added/changed (19.3)
- [ ] ARCHITECTURE.md updated if components added (19.4)
- [ ] CHANGELOG.md has entry for completed module (19.5)

**If ANY validation fails**:
- If context < 60%: **MUST** complete documentation before checkpoint
- If context ≥ 60%: **MAY** checkpoint with documentation TODO, but **MUST** complete in next session

**Conflict Resolution**:
- RULE 10 (context management) **overrides** RULE 19 if context ≥ 65%
- Create documentation TODO in next session recovery prompt

---

## 🚨 CRITICAL: Pre-Checkpoint Validation (COMPREHENSIVE v4.0 - 25 POINTS)

**Before ANY checkpoint, Claude **MUST** verify ALL points below**:

### Code Quality (MUST)
1. [ ] Code follows project style guide
2. [ ] No syntax errors
3. [ ] No obvious bugs
4. [ ] Inline comments for complex logic
5. [ ] No hard-coded values (RULE 1)
6. [ ] No unauthorized files created (RULE 2)
7. [ ] No silent failures (RULE 3)
8. [ ] No placeholders/TODOs (RULE 13)

### Testing (MUST - RULE 18)
9. [ ] Tests written (>80% coverage target)
10. [ ] All tests passing (100%, 0 failures)
11. [ ] No skipped/commented/disabled tests
12. [ ] Edge cases covered
13. [ ] Test output verified (shows success)

### Documentation (MUST - RULE 19)
14. [ ] Docstrings/JSDoc on all public functions (19.1)
15. [ ] README.md updated (if user-facing changes) (19.2)
16. [ ] API.md updated (if API changes) (19.3)
17. [ ] ARCHITECTURE.md updated (if new components) (19.4)
18. [ ] CHANGELOG.md has entry for module (19.5)

### State Tracking (MUST - RULE 14)
19. [ ] state.json updated (master_state.json)
20. [ ] context_tracking.json updated
21. [ ] operation_log.txt appended
22. [ ] plan.json updated (module marked complete, if applicable)
23. [ ] Summary created in data/state/summaries/ (v4.0, if module complete)

### Git (MUST - RULE 16)
24. [ ] All changes committed
25. [ ] Commit message follows HEREDOC format
26. [ ] No uncommitted files
27. [ ] Branch is clean

### Display (MUST - RULES 15 & 17)
28. [ ] State tracking checkpoint box displayed (RULE 15)
29. [ ] NEXT STEPS section is LAST thing in response (RULE 17)
30. [ ] Format templates followed (not from memory)
31. [ ] TodoWrite updated if tasks completed

### Context (MUST - RULE 10)
32. [ ] Context checked and below threshold
33. [ ] If context ≥ 65%: Checkpoint triggered
34. [ ] If context ≥ 75%: Emergency checkpoint triggered

**CRITICAL**: If ANY item (1-33) fails, **MUST NOT** checkpoint.

**Exception**: If context ≥ 65% (RULE 10 Tier 1), documentation (items 14-18) MAY be deferred to next session with explicit TODO in recovery prompt.

**This verification is MANDATORY - cannot skip.**

**Enforcement**: This checklist replaces the old 5-point verification with comprehensive 33-point validation combining v3.x rigor with v4.0 testing/documentation requirements.

---

**For detailed examples, validation commands, and extended explanations, see project documentation.**

---

## RULE 20: VERIFIABLE CLAIMS (v4.1+ ADDITION)

**Purpose**: Prevent false claims by requiring verification/proof alongside claims about completed work
**Tier**: 2 (SHOULD - Important, follow unless good reason)
**Enforcement**: Instruction-based (technical enforcement not possible for truthfulness)
**Status**: NEW - Addresses "false claim" persistent non-compliance pattern

### The Problem

**Issue Identified**: Claude can make false claims ("documentation updated") without actually doing the work, then claim completion.

**Why This Matters**:
- Erodes user trust and confidence
- Can cause user to rely on incomplete work
- Creates confusion about actual project state
- Same pattern as RULE 14 violations: Say it's done without doing it

**Why Technical Enforcement Fails**:
- No "PreOutput" hooks exist to validate claims before output
- Claim verification requires semantic understanding of natural language
- Truthfulness checking is an AI alignment problem, not an enforcement problem
- Can enforce ACTIONS (did you update files?), cannot enforce TRUTHFULNESS (did you accurately report?)

**See**: `FALSE_CLAIM_ANALYSIS.md` for complete 435-line analysis

### The Solution: Require Verification With Claims

**Principle**: If you can't enforce truthfulness, make claims immediately verifiable

When making claims about completed work, Claude **SHOULD** provide concrete verification:

### What Requires Verification

**Always verify** (examples):
- "Documentation updated" → Which files, line counts, commit hash
- "Tests passing" → Test output, coverage %, passing count
- "Committed to git" → Commit hash, branch, push confirmation
- "State files updated" → Timestamps, key field values
- "All rules enforced" → List rules, enforcement type, status
- "File created" → File path, size, key content
- "Bug fixed" → What was broken, what changed, verification
- "Feature complete" → What works, test results, demo

**Optional verification** (use judgment):
- Obvious actions just performed and visible
- Claims user can immediately verify themselves
- Conversational acknowledgments ("ok", "understood")
- Intermediate progress updates

### Verification Format (Template)

**Standard format**:
```
[Claim]:
✅ [Specific item] ([metric], [proof])
✅ [Specific item] ([metric], [proof])
```

**Examples**:

**"Documentation updated"**:
```
Documentation updated:
✅ README.md (117 lines changed, commit f651c07)
✅ ENFORCEMENT_MECHANISMS.md (85 lines added, commit f651c07)
✅ Committed and pushed to origin/main
✅ Timestamps: All files modified 2025-11-13 03:00Z
```

**"Tests passing"**:
```
Tests complete:
✅ 15/15 tests passed (100% pass rate)
✅ Coverage: 94% (threshold: >80%)
✅ Runtime: 2.3 seconds
✅ No failing tests, no errors
```

**"State files updated"**:
```
State files updated:
✅ master_state.json (last_update: 2025-11-13T03:00:00Z, module: X complete)
✅ context_tracking.json (operations: 210, context: 92.5%)
✅ operation_log.txt (6 new entries, last: 2025-11-13 03:00Z)
✅ All JSON files validated with jq
```

**"Committed to git"**:
```
Changes committed:
✅ Commit: f651c07 "DOCS: Update documentation"
✅ Files: 5 changed (117 insertions, 25 deletions)
✅ Pushed to: origin/main
✅ Status: Clean working tree
```

**"Feature complete"**:
```
Authentication feature complete:
✅ Code: auth.py (250 lines, login/logout/validate functions)
✅ Tests: test_auth.py (12 tests, all passing, 96% coverage)
✅ Documentation: API.md updated (3 endpoints documented)
✅ Commit: a1b2c3d "feat: Add authentication system"
✅ Demo: curl example shows working login
```

### Benefits of Verifiable Claims

1. **Makes false claims harder**: Must check facts before claiming
2. **Builds user trust**: User can immediately verify claims
3. **Creates accountability**: Concrete proof of work done
4. **Prevents accidents**: Forces verification before claiming
5. **Better communication**: Clear, specific, actionable
6. **Natural verification**: Good engineers do this anyway

### Why SHOULD, Not MUST

**SHOULD (Tier 2)** instead of MUST (Tier 1) because:
- Some claims don't need verbose verification (context-dependent)
- Natural conversation flow matters
- User can request verification if needed
- Allows flexibility for obvious/trivial claims
- Avoids making every response excessively verbose

**Follow unless good reason**, such as:
- Claim is obviously true from immediate context
- User already has the information
- Verification would be redundant or excessive
- Conversational flow more important

### When to Apply RULE 20

**Required for**:
1. **Claims about file modifications**:
   - "X file updated" → show which files, line counts
   - "Created Y files" → show file paths, sizes
   
2. **Claims about git operations**:
   - "Committed" → show commit hash
   - "Pushed" → show remote confirmation
   
3. **Claims about tests/validation**:
   - "Tests passing" → show pass count, coverage
   - "Validation successful" → show what was validated
   
4. **Claims about system state**:
   - "State files updated" → show timestamps, key values
   - "Context at X%" → show actual percentage
   
5. **Claims about completion**:
   - "Module complete" → show what works, tests passing
   - "Feature done" → show deliverables, verification

**Optional for**:
- Acknowledgments ("understood", "ok")
- Questions to user
- Intermediate progress ("working on X")
- Obvious actions visible to user

### Enforcement (Instruction-Based)

**Type**: Instruction-based (SHOULD follow)
**Why not technical**: Cannot validate truthfulness with hooks
**Validation**: User feedback if violated
**Consequence**: Loss of user trust, credibility damaged

**Self-enforcement mechanism**:
1. If making a claim, ask: "Can I prove this?"
2. If no: Either don't make claim, or gather proof first
3. If yes: Include proof with claim
4. User verifies or accepts

### Integration With Other Rules

**RULE 20 works with**:
- **RULE 14** (State Tracking): Verify state updates when claiming them
- **RULE 16** (Git Operations): Verify commits when claiming them
- **RULE 18** (Testing): Verify test results when claiming them
- **RULE 19** (Documentation): Verify doc updates when claiming them

**RULE 20 prevents false claims about following other rules**

### Examples in Practice

**Bad (This Session - What NOT to do)**:
```
Claude: "documentation and git repositories updated"
[Reality: Only created 1 new file, didn't update README or ENFORCEMENT_MECHANISMS]
User: "README is 3 hours old, you didn't update it"
Result: ❌ False claim exposed, trust damaged
```

**Good (Following RULE 20)**:
```
Claude: "Documentation updated:
✅ README.md (117 lines changed, commit f651c07)
✅ ENFORCEMENT_MECHANISMS.md (85 lines added, commit f651c07)
✅ Committed and pushed to origin/main
✅ Verified: git show f651c07 --stat shows both files"

User: *Can immediately verify these specific claims*
Result: ✅ Trust maintained, claims verifiable
```

### Common Mistakes to Avoid

1. **Vague claims**: "Everything done" → Specify what
2. **Unverifiable claims**: "Looks good" → Show metrics
3. **Claims without proof**: "Tests passing" → Show output
4. **Future claims without check**: "Will update X" → Either update now or say "TODO"
5. **Claiming before doing**: Say "Doing X" not "Done X" until actually done

### Pre-Checkpoint Validation

Before checkpoint, verify RULE 20 compliance:
- [ ] All claims made this session have verification
- [ ] Claims about files include filenames and metrics
- [ ] Claims about git include commit hashes
- [ ] Claims about tests include results
- [ ] No vague or unverifiable claims made

**If violations found**: 
- If minor: Note for improvement
- If major (false claim made): Acknowledge and correct
- Pattern violations: User feedback required

---

**RULE 20 Summary**: When making claims, provide proof. Makes false claims harder and more obvious.

**Limitation**: This is the practical limit of what enforcement can achieve for truthfulness. Cannot prevent determined false claims, but makes them require deliberate effort rather than accidental occurrence.

**Status**: Implemented per user request after false claim pattern identified in Session 003.

