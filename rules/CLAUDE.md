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
- **SHOULD** use JIT context loading (RULE 22.1) - load only when needed, not pre-loading (NEW v4.7.0)
- **SHOULD** apply tool output filtering (RULE 22.2) - summarize verbose outputs >1K tokens (NEW v4.7.0)
- **SHOULD** apply context editing (RULE 22.3) - prune old low-signal content (NEW v4.7.0)
- **SHOULD** track compression metrics (RULE 22.4) - monitor effectiveness (NEW v4.7.0)
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

📦 Compression Stats (RULE 22 - v4.7.0+):
✅ Tokens saved: [N]K ([X]% reduction)
✅ Effective context: [N]K tokens ([X.X]% vs [theoretical_max]%)
✅ Strategies: [JIT: N uses, Filtering: N uses, Editing: N uses]

Next threshold: [35%/40%] at [N]K tokens
Operations this session: [count]

═══════════════════════════════════════════════════════════════════════
```

**This makes tracking visible and verifiable.**

**Note**: Compression stats section (v4.7.0+) shows RULE 22 effectiveness. Display only if compression_metrics.enabled=true in context_tracking.json.

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
**Enforcement**: MUST (Tier 1 - Critical for user experience)
**Action**: At END of EVERY response (AFTER checkpoint), display:

```
███████████████████████████████████████████████████████████████████████
🎯 NEXT STEPS FOR YOU (AFTER YOU EXIT AND COME BACK IN)
███████████████████████████████████████████████████████████████████████

### When You Exit This Session and Come Back:

1. **Start new Claude Code session in this directory**

2. **Paste this EXACT prompt**:
   ```
   [Exact recovery prompt with all context - SEE VERIFICATION CHECKLIST BELOW]
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

**Template reference**: `.claude/templates/recovery_prompt_template.md`
**THIS MUST BE THE LAST THING - NOTHING AFTER IT**

---

### RULE 17 SELF-VERIFICATION CHECKLIST (MANDATORY)

**BEFORE completing ANY response, Claude MUST verify:**

#### Structure Verification
- [ ] "NEXT STEPS" section exists at END of response
- [ ] Section includes subsection "Paste this EXACT prompt:"
- [ ] Section is LAST thing (nothing after it)

#### Content Verification (CRITICAL - Where violations occur)
- [ ] Subsection contains **ACTUAL PROMPT TEXT** (not suggestions, not options, not placeholders)
- [ ] Prompt includes:
  - [ ] What was completed this session (with details)
  - [ ] Current state (version, location, last commit hash)
  - [ ] What's pending (if mid-task)
  - [ ] Exact instructions for continuation
  - [ ] Original request context (if applicable)
  - [ ] Permissions statement (if autonomous work continues)
- [ ] ALL [VARIABLES] filled in with actual values (no [TBD], [TODO], [INSERT])
- [ ] File paths are ABSOLUTE (not relative)
- [ ] Commit hashes are REAL (not placeholders like [HASH])
- [ ] Version numbers are CURRENT

#### Copy/Paste Test (FINAL VERIFICATION)
- [ ] Ask yourself: "If I copy/pasted this prompt in a new session, would Claude know EXACTLY what to do WITHOUT asking clarifying questions?"
- [ ] If answer is NO → prompt is incomplete, fix it before completing response
- [ ] If answer is YES → verification passed

**Common Mistakes to Avoid**:
- ❌ Providing options/suggestions instead of actual prompt
- ❌ Showing structure without content ("paste this prompt:" with no prompt)
- ❌ Using placeholders like [CONTINUE_HERE], [PROJECT_NAME], [VERSION]
- ❌ Leaving context vague ("continue where we left off")
- ❌ Assuming Claude will remember (new session = fresh context)

**Why This Matters**:
- User should NEVER have to ask "where is the prompt?"
- Recovery should be SEAMLESS, not require clarification
- This is a P2 High rule affecting user experience and trust
- Pattern of violation damages framework credibility

**See Also**:
- `.claude/templates/recovery_prompt_template.md` for examples
- `docs/analysis/RULE_17_VIOLATION_PATTERN_ANALYSIS.md` for why this checklist exists

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

---

## RULE 21: RESERVED - SUPERSEDED BY RULE 22

**Status**: RESERVED (Not Implemented - Superseded)
**Originally Planned**: Token-Efficient Tool Usage (see docs/analysis/ENHANCEMENT_AUDIT_REPORT_20251113.md)
**Superseded By**: RULE 22 (Advanced Context Compression) - v4.7.0
**Reason**: RULE 22 provides more comprehensive token efficiency guidance

**Why Reserved**:
- RULE 21 was identified in enhancement audit (2025-11-13) as "Token-Efficient Tool Usage"
- Before implementation, v4.7.0 added RULE 22 (Advanced Context Compression)
- RULE 22 covers token efficiency more comprehensively (50-80% reduction achieved)
- RULE 22 includes 4 strategies: JIT loading, tool filtering, context editing, monitoring
- Original RULE 21 scope fully covered by RULE 22

**Note**: Maintaining RULE 21 as reserved preserves rule numbering consistency. RULE 22 remains as-is in v4.7.0 release to avoid breaking changes.

---

## RULE 22: ADVANCED CONTEXT COMPRESSION (v4.7.0 ADDITION)

**Purpose**: Minimize context usage through intelligent compression and pruning techniques
**Tier**: 2 (SHOULD - Important, follow unless good reason)
**Enforcement**: Instruction-based (guidance and best practices)
**Status**: NEW - Based on Anthropic research (2025) showing 84% token reduction achievable
**Based On**: State-of-the-art context engineering practices (see FRAMEWORK_GAP_ANALYSIS_20251113.md)

---

### The Problem

**Context Usage Inefficiencies**:
- Pre-loading files unnecessarily (not just-in-time)
- Keeping all tool outputs in context (no pruning)
- Verbose tool outputs consume excessive tokens
- Old completed work remains in context
- Repetitive content not compressed

**Research Findings** (Anthropic 2025):
- Automatic context editing enables 84% token reduction
- JIT loading reduces unnecessary context by 30-50%
- Tool output filtering saves significant tokens
- 100-turn dialogues possible with only 16% of original tokens

**Impact**: Without compression, users hit context limits 2-3x sooner than necessary

---

### Four-Strategy Framework

**Context compression uses four strategies** (Write, Select, Compress, Isolate):
1. **SELECT**: Just-In-Time (JIT) context loading - load only what's needed
2. **COMPRESS**: Tool output filtering - summarize verbose outputs
3. **ISOLATE**: Context editing - prune old low-signal content
4. **WRITE**: Real-time monitoring - track compression effectiveness

---

### 22.1 JIT Context Loading (SELECT Strategy)

**Principle**: Load only what you need, when you need it

**Pattern**: Don't pre-load → Use discovery tools → Load on demand

**Actions** (SHOULD follow):
- **Don't pre-load**: Don't read all files in a directory speculatively
- **Discovery first**: Use Grep/Glob to find relevant files before reading
- **Summary before detail**: Read summaries or headers before full content
- **Batch intelligently**: Load related files together, but not unrelated files
- **Defer detail**: Load high-level structure first, detail only if necessary

**Example Workflows**:

**BAD (Pre-loading - Wastes Context)**:
```
1. Read src/file1.py (8K tokens)
2. Read src/file2.py (6K tokens)
3. Read src/file3.py (7K tokens)
4. Read src/file4.py (9K tokens)
5. Read src/file5.py (12K tokens)
6. Analyze which file to modify → It's file2.py
7. Make changes to file2.py
Total context: 42K tokens (80% wasted)
```

**GOOD (JIT Loading - Efficient)**:
```
1. Grep "class Authentication" in src/ → Finds 2 matches (500 tokens)
2. Review grep results → file2.py looks relevant
3. Read src/file2.py (6K tokens)
4. Confirm this is the target file
5. Make changes to file2.py
Total context: 6.5K tokens (85% savings vs pre-loading)
```

**When to Use JIT Loading**:
- ✅ Exploring codebase to find relevant files
- ✅ Searching for specific functionality
- ✅ Identifying target for modifications
- ✅ Understanding project structure (start high-level)
- ❌ Already know exact file to modify (just read it)
- ❌ Need all files for comprehensive analysis

**Validation**:
- Before reading files: Ask "Do I need this content NOW, or am I speculating?"
- If exploring: Grep/Glob first, Read second
- If uncertain about relevance: Skip or load summary only

---

### 22.2 Tool Output Filtering (COMPRESS Strategy)

**Principle**: Summarize verbose tool outputs before adding to context

**Pattern**: Run tool → Evaluate output size → Summarize if >1K tokens

**Actions** (SHOULD follow):
- **Grep results >20 matches**: Summarize pattern, don't list all matches
- **File listings >10 files**: Group by type/directory, don't list all
- **Log outputs**: Extract key errors/warnings, not full logs
- **Test results**: Report pass/fail counts + coverage, not every test detail
- **Large file reads**: Use head/tail limits, or summarize after reading

**Examples**:

**Grep Results (47 matches)**:
```
❌ BAD (Lists all 47 matches):
src/auth.py:15: def login(username, password):
src/auth.py:42: def logout(session):
src/auth.py:78: def validate_token(token):
[... 44 more lines ...]
(12K tokens)

✅ GOOD (Summarized pattern):
"Found 47 matches across 12 files. Main patterns:
 - auth.py (15 matches): login/logout/validate functions
 - user.py (10 matches): user management
 - session.py (8 matches): session handling
 - Other files (14 matches): utility usage
 Most relevant: auth.py for authentication logic"
(500 tokens, 96% reduction)
```

**Test Results**:
```
❌ BAD (Full pytest output):
============================= test session starts ==============================
platform darwin -- Python 3.11.0, pytest-7.4.0, pluggy-1.3.0
rootdir: /Users/...
collected 127 items

tests/test_auth.py::test_login PASSED                                    [  0%]
tests/test_auth.py::test_logout PASSED                                   [  1%]
[... 125 more lines of output ...]
============================= 127 passed in 3.24s ==============================
(25K tokens)

✅ GOOD (Summarized results):
"Tests: 127/127 passed (100%). Coverage: 94% (target: >80%).
 Runtime: 3.2s. 0 failures, 0 errors, 0 warnings."
(50 tokens, 99.8% reduction)
```

**File Listings**:
```
❌ BAD (Lists all 83 files):
src/auth/login.py
src/auth/logout.py
src/auth/validate.py
[... 80 more files ...]
(8K tokens)

✅ GOOD (Grouped summary):
"Found 83 files in 7 directories:
 - src/auth/ (15 files): authentication modules
 - src/users/ (22 files): user management
 - src/api/ (18 files): API endpoints
 - src/db/ (12 files): database models
 - src/utils/ (10 files): utilities
 - tests/ (25 files): test suites
 - config/ (5 files): configuration"
(400 tokens, 95% reduction)
```

**When to Summarize**:
- ✅ Tool output >1K tokens
- ✅ Repetitive/structured output (many similar lines)
- ✅ Already saw the detail (user has visibility)
- ✅ Only need pattern/summary, not every detail
- ❌ Critical error messages (keep full message)
- ❌ Unique/non-repetitive content (can't compress safely)
- ❌ Small outputs <1K tokens (summarization overhead not worth it)

**Validation**:
- After tool use: Check output size
- If output >1K tokens: Summarize before continuing
- Keep full output in logs if user needs it later
- Verify summary captures key information

---

### 22.3 Context Editing (ISOLATE Strategy)

**Principle**: Remove low-signal content from context as work progresses

**Pattern**: Complete task → Summarize key points → Remove detailed context

**What to Prune** (SHOULD remove):
- ✅ Tool outputs from >5 operations ago (unless actively referencing)
- ✅ Completed task details (keep 2-3 sentence summary only)
- ✅ Exploration results that didn't lead to action (dead ends)
- ✅ Verbose error messages after understanding root cause
- ✅ Redundant file contents (reference file path instead of repeating content)
- ✅ Old conversation history (compress to decisions made)

**What NOT to Prune** (MUST keep):
- ❌ Current task context (actively working on)
- ❌ Recent tool outputs (last 3-5 operations)
- ❌ State tracking data (master_state.json, context_tracking.json)
- ❌ Uncommitted changes (need to remember what to commit)
- ❌ Critical error messages (still debugging)
- ❌ User instructions (original request and requirements)

**Examples**:

**Completed Task Compression**:
```
❌ BAD (Keep everything):
Operation 1: Read src/auth.py (8K tokens) - full file content
Operation 2: Read tests/test_auth.py (6K tokens) - full file content
Operation 3: Analysis of authentication flow (4K tokens) - detailed analysis
Operation 4: Write new login() function (2K tokens) - implementation
Operation 5: Write tests (3K tokens) - test code
Operation 6: Run tests (20K tokens) - full pytest output
Total context from completed work: 43K tokens

✅ GOOD (Compressed summary):
"Task complete: Added login() function to src/auth.py with JWT token generation.
 Tests: 12 new tests added, all passing (100%). Coverage: 96%.
 Commit: Ready to commit auth changes."
Total context: 100 tokens (99.7% reduction from 43K)
```

**Exploration Compression**:
```
❌ BAD (Keep all exploration):
Read src/auth.py - not the right file
Read src/session.py - not the right file
Read src/user.py - not the right file
Read src/api.py - THIS is the right file
[All 4 file contents kept in context: 30K tokens]

✅ GOOD (Keep only what matters):
"Searched for API endpoint logic. Found in src/api.py (8K tokens kept).
 Other files not relevant (discarded)."
[Only src/api.py kept in context: 8K tokens, 73% reduction]
```

**When to Apply Context Editing**:
- ✅ After completing a task or sub-task
- ✅ Every 5-10 operations (periodic pruning)
- ✅ At 50% context threshold (aggressive pruning)
- ✅ After failed exploration (remove dead ends)
- ✅ After understanding error (remove verbose logs)

**Validation**:
- Before pruning: Verify content is truly complete/irrelevant
- After pruning: Can you still continue the work? (test with "what was I working on?")
- Preserve in logs: Full content should be in operation_log.txt or git
- Emergency recovery: Can restore from checkpoint if needed

---

### 22.4 Real-Time Compression Monitoring (WRITE Strategy)

**Principle**: Track compression effectiveness and adjust techniques

**Actions** (SHOULD follow):
- **Track compression ratio**: Measure actual vs potential context usage
- **Report in checkpoint box**: Show compression effectiveness
- **Adjust techniques**: If context growing too fast, increase compression
- **Document in context_tracking.json**: Log compression metrics
- **Identify inefficiencies**: Find operations consuming excessive context

**Metrics to Track**:

```json
{
  "compression_metrics": {
    "raw_context_estimate": 180000,
    "compressed_context": 45000,
    "compression_ratio": 0.75,
    "compression_pct": "75%",
    "techniques_used": ["jit_loading", "tool_filtering", "context_editing"],
    "last_compression": "2025-11-13T23:55:00Z",
    "operations_since_compression": 5
  }
}
```

**Calculation**:
- **Raw context estimate**: Sum of all potential context (if no compression)
  - All files that could have been read: 50 files × 8K = 400K tokens
  - All tool outputs at full verbosity: 80K tokens
  - All exploration dead-ends: 60K tokens
  - Total raw estimate: 540K tokens

- **Compressed context**: Actual context currently in use
  - Files actually read: 6 files × 8K = 48K tokens
  - Summarized tool outputs: 12K tokens (vs 80K raw)
  - Exploration summary: 2K tokens (vs 60K raw)
  - Total compressed: 62K tokens

- **Compression ratio**: (1 - compressed/raw) = (1 - 62K/540K) = 0.885 = 88.5%

**Enhanced Checkpoint Box**:
```
═══════════════════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC - RULES 14-17)
═══════════════════════════════════════════════════════════════════════
✅ Operation logged: Read → logs/operation_log.txt
✅ State updated: master_state.json (timestamp: 23:55:00)
✅ Context tracked: 62K tokens (31.0%)
✅ Threshold check: SAFE
✅ Git status: 19d4c8d

📦 Compression Stats (RULE 22 - v4.7.0):
✅ Raw context estimate: 540K tokens (without compression)
✅ Compressed context: 62K tokens (actual usage)
✅ Compression ratio: 88.5% (8.7:1 reduction)
✅ Techniques used: JIT loading, tool filtering, context editing
✅ Token savings: 478K tokens saved this session

Next threshold: 65% at 130K tokens
Operations this session: 42
═══════════════════════════════════════════════════════════════════════
```

**When to Adjust Compression**:
- **Compression ratio <50%**: Not compressing enough
  - Action: Increase tool output summarization
  - Action: More aggressive context editing
  - Action: Switch to JIT loading if pre-loading

- **Context growing >10K/operation**: Inefficient operations
  - Action: Identify verbose tools (which ones?)
  - Action: Add summarization to those tools
  - Action: Consider if operation truly needed

- **Compression ratio >90%**: Excellent compression
  - Action: Continue current techniques
  - Action: Verify not losing critical context
  - Action: Document what's working well

**Validation**:
- If compression ratio <50%: Review techniques, identify inefficiencies
- If context growing despite compression: Investigate root cause
- If compression ratio >90%: Verify no critical context lost

---

### Integration with Other Rules

**RULE 22 enhances**:
- **RULE 10** (Context Management): Provides compression techniques
  - RULE 10 sets thresholds (65%/75%) - MUST follow
  - RULE 22 provides methods to stay under thresholds - SHOULD follow

- **RULE 14** (State Tracking): Adds compression metrics
  - Track compression_metrics in context_tracking.json
  - Report compression stats in checkpoint box

- **RULE 17** (Next Steps): Includes compression context
  - Recovery prompts mention compression techniques used
  - Next session continues compression patterns

**RULE 22 complements**:
- **RULE 2** (Named Files Only): JIT loading supports file discovery
- **RULE 9** (Code Reuse): Finding reusable code efficiently
- **RULE 13** (Real Data Only): Compression reduces placeholder temptation

---

### Implementation Checklist

**Before using RULE 22 techniques, verify**:
- [ ] Understand four strategies: SELECT, COMPRESS, ISOLATE, WRITE
- [ ] Know when to apply JIT loading (exploration, discovery)
- [ ] Know when to summarize tool outputs (>1K tokens)
- [ ] Know what to prune (completed work, old outputs)
- [ ] Know what NOT to prune (current work, recent outputs, critical data)
- [ ] Track compression metrics in context_tracking.json
- [ ] Report compression stats in checkpoint box

**At checkpoint, verify compression**:
- [ ] Compression ratio calculated and tracked
- [ ] Compression techniques documented (which ones used?)
- [ ] Context usage below threshold despite work done
- [ ] No critical context lost (can still continue work?)
- [ ] Compression stats displayed in checkpoint box

---

### Common Mistakes to Avoid

**Mistake 1: Over-compression (Losing Critical Context)**
```
❌ Pruned current task details → Can't remember what I was doing
❌ Removed recent error messages → Can't debug issue
❌ Deleted uncommitted changes summary → Lost track of changes
Fix: Follow "What NOT to Prune" guidelines strictly
```

**Mistake 2: Under-compression (Not Applying Techniques)**
```
❌ Pre-loaded all 50 files when only needed 3
❌ Kept full 25K test output when summary was sufficient
❌ Retained all exploration dead-ends
Fix: Apply JIT loading, tool filtering, context editing consistently
```

**Mistake 3: Inconsistent Application**
```
❌ Compressed some outputs but not others
❌ Used JIT loading sometimes, pre-loading other times
❌ No pattern or consistency
Fix: Develop consistent habits, apply techniques systematically
```

**Mistake 4: Not Tracking Effectiveness**
```
❌ Don't know if compression is working
❌ No metrics tracked
❌ Can't optimize without data
Fix: Track compression_metrics, review in checkpoint box
```

---

### Expected Benefits

**Quantitative** (vs no compression):
- **Context reduction**: 50-80% fewer tokens (Anthropic research validated)
- **Session duration**: 2-3x longer before hitting 65% threshold
- **Checkpoint frequency**: Every 4-6 hours vs every 2-3 hours
- **Cost savings**: 50-80% reduction in token costs

**Qualitative**:
- Longer productive sessions (fewer interruptions)
- Less context management overhead (automatic techniques)
- Better visibility (compression metrics tracked)
- Improved recovery (compression patterns preserved)
- Industry-standard practices (aligned with Anthropic research)

---

### Troubleshooting

**Problem**: Context still growing too fast
**Solution**:
1. Check compression_metrics - what's the ratio?
2. If <50%: Increase compression (more aggressive summarization)
3. Identify verbose operations (which tools consuming most context?)
4. Apply tool output filtering to those specific tools
5. Consider if all operations truly necessary

**Problem**: Lost critical context after pruning
**Solution**:
1. Review checkpoint files (can restore from .claude/checkpoints/)
2. Check operation_log.txt (full details preserved)
3. Check git commits (code changes preserved)
4. Adjust pruning rules (be less aggressive)
5. Add to "What NOT to Prune" list

**Problem**: Don't know if compression is working
**Solution**:
1. Check compression_metrics in context_tracking.json
2. Review checkpoint box (compression stats shown)
3. Compare current vs past sessions (improvement?)
4. Calculate manually: count tokens used vs could have used
5. Document findings for future sessions

**Problem**: Techniques too complex to remember
**Solution**:
1. Start with one technique: JIT loading (biggest impact)
2. Add tool output filtering once JIT becomes habit
3. Add context editing after both become natural
4. Reference this RULE 22 section when uncertain
5. Review guides/11_CONTEXT_COMPRESSION.md for examples

---

**RULE 22 Summary**: Compress context through four strategies - SELECT (JIT loading), COMPRESS (tool filtering), ISOLATE (context editing), WRITE (monitoring). Achieves 50-80% token reduction (Anthropic-validated). Enables 2-3x longer sessions with fewer checkpoints.

**Status**: NEW in v4.7.0 - Based on 2025 state-of-the-art research
**Priority**: SHOULD (Tier 2) - Important for efficiency, but flexible application
**Integration**: Enhances RULE 10 (provides compression methods for threshold management)

---

