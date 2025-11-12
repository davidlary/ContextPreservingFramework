# Enforcement Rules - [PROJECT_NAME]

**Purpose**: Strict rules for Claude Code (concise format for token efficiency)
**Status**: ACTIVE
**Version**: v4.0.1 (Integrated - combines v3.x enforcement with v4.0 RFC 2119 requirements)
**Detailed Docs**: See project documentation for full examples and explanations

**Keywords** (RFC 2119):
- **MUST** / **SHALL** / **REQUIRED**: Absolute requirement (non-negotiable)
- **MUST NOT** / **SHALL NOT**: Absolute prohibition
- **SHOULD** / **RECOMMENDED**: Strong recommendation (follow unless good reason)
- **MAY** / **OPTIONAL**: Truly optional

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

## RULE 2: NAMED FILES ONLY

**Principle**: Only create files specified in architecture/module specifications
**Action**: Before creating ANY file:
  1. Check: Does file exist in documentation? If yes, update it
  2. Check: Is file in module spec? If no, ASK before creating
**Violation**: Unauthorized file creation (delete and use existing)

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
